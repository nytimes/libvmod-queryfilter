/*=============================================================================
 * libvmod-queryfilter: Simple VMOD for filtering/sorting query strings
 *
 * Copyright 2016 The New York Times Company
 * Modifications copyright 2017 Norsk Rikskringkasting AS
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * 
 *===========================================================================*/

#include "vmod_queryfilter_config.h"
#include <stdarg.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#include "vrt.h"
#include "vcc_if.h"

/* Varnish 4.x */
#if VARNISH_API_MAJOR == 4
#include "vre.h"
#include "cache/cache.h"
typedef const struct vrt_ctx req_ctx;

/* Varnish 3.x: */
#elif VARNISH_API_MAJOR == 3
#include "cache.h"
typedef struct sess req_ctx;

#endif /* VARNISH_API_MAJOR == 4 */


/** Simple struct used for one-time query parameter tokenization.
 * Stores name and value and serves as the node-type for a crude linked list.
 */
typedef struct query_param {
    char* name;
    char* value;
    long flag;
    struct query_param* next;
} query_param_t;

/** Query string tokenizer. This function takes a query string as input, and
 * yields a linked list of name/value pairs. Allocation happens inside the
 * reserved workspace, pointed to by *ws_free. On error, no space is consumed.
 *
 * @param ws_free pointer to char* at the head of the reserved workspace
 * @param ws_remain the amount of reserved workspace remaining, in bytes
 * @return on success the pointer to the head of the list; NULL on failure
 *
 * @TODO alignment for query_param_t structs!
 */
static query_param_t*
tokenize_querystring(char** ws_free, unsigned* remain, char* query_str)
{
    char* save_ptr;
    char* param_str;
    char* ws_free_temp = *ws_free; /* Temporary copy of workspace head */
    unsigned remain_temp = *remain; /* Temporary allocation counter */
    query_param_t* head = NULL;
    query_param_t* tail = NULL;

    /* Move the free pointer up so that query_param_t objects allocated on
     * WS storage are properly aligned: */
    size_t align_remain = (size_t)ws_free_temp % sizeof(char*);
    if( align_remain ) {
        ws_free_temp += (sizeof(char*) - align_remain);
        remain_temp -= (sizeof(char*) - align_remain);
    };

    /* Tokenize the query parameters into a linked list: */
    for(param_str = strtok_r(query_str, "&", &save_ptr); param_str;
        param_str = strtok_r(NULL, "&", &save_ptr))
    {
        /* If we run out of space at any point, just bail.
         * Note that in this case, we don't update ws_free or remain so that
         * the space we've consumed thus far is returned to the workspace. */
        if( remain_temp < sizeof(query_param_t) ) {
            return NULL;
        };

        /* "Allocate" space at the head of the workspace and place a node: */
        query_param_t* param = (query_param_t*)ws_free_temp;
        remain_temp -= sizeof(query_param_t);
        ws_free_temp += sizeof(query_param_t);

        param->name = param_str;
        param->value = strchr(param_str,'=');
        param->next = NULL;
        param->flag = 0;
        if( param->value ) {
            *(param->value++) = '\0';
            if( *(param->value) == '\0' ) {
                param->value = NULL;
            };
        }
        else {
            param->flag = 1;
            param->value = NULL;
        };

        if( tail ) {
            tail->next = param;
            tail = param;
        }
        else {
            head = tail = param;
        };
    };

    (*ws_free) = ws_free_temp;
    (*remain) = remain_temp;
    return head;
}

/* Hacky workspace string copy. We pray for inline. ;)
 *
 * @param ws_free pointer to char* at the head of the reserved workspace
 * @param ws_remain the amount of reserved workspace remaining, in bytes
 * @return on success the pointer to the new string
 */
inline static char*
strtmp_append(char** ws_free, unsigned* remain, const char* str_in)
{
    char* dst = NULL;
    size_t buf_size = strlen(str_in) + 1;
    if( buf_size <= *remain ) {
        memcpy(*ws_free,str_in,buf_size);
        dst = *ws_free;
        *ws_free += buf_size;
        *remain -= buf_size;
    };
    return dst;
}

/** Entrypoint for filterparams.
 *
 * Notes:
 * 1. We copy the URI as working space for the output URI, assuming that the
 *    filtered URI will always be less than or equal to the input URI size.
 * 2. Tokenize the querystring *once* and store it as a linked list
 * 3. Tokenize and iterate over the input parameters, copying matching query
 *    parameters to the end of our allocated space; the terms end up sorted
 *    as a byproduct.
 * 4. On success, release all but the space occupied by new_uri; on failure
 *    release all workspace memory that was allocated.
 *
 * @param sp Varnish Session Pointer
 * @param uri The input URI
 * @param params_in a comma separated list of query parameters to *include*
 * @return filtered URI on success; NULL on failure
 */
const char*
vmod_filterparams(req_ctx* sp, const char* uri, const char* params_in)
{
    char* saveptr;
    char* new_uri = NULL;
    char* new_uri_end;
    char* query_str;
    char* params;
    char* ws_free;
    unsigned ws_remain;
    struct ws* workspace = sp->ws;
    query_param_t* head = NULL;
    query_param_t* current;
    const char* filter_name;
    int params_seen = 0;

    /* Reserve the *rest* of the workspace - it's okay, we're gonna release
     * all of it in the end ;) */
    ws_remain = WS_Reserve(workspace, 0); /* Reserve some work space */
    ws_free = workspace->f;

    /* Duplicate the URI, bailing on OOM: */
    new_uri = strtmp_append(&ws_free, &ws_remain, uri);
    if( new_uri == NULL ) {
        goto release_bail;
    };

    /* Find the query string, if present: */
    query_str = strchr(new_uri, '?');
    if( query_str == NULL ) {
        new_uri_end = new_uri + strlen(uri);
        goto release_okay;
    };

    /* Terminate the existing URI at the beginning of the query string: */
    new_uri_end = query_str;
    *(query_str++) = '\0';

    /* Copy the query string to the head of the workspace: */
    query_str = strtmp_append(&ws_free, &ws_remain, query_str);
    if( !query_str ) {
        goto release_bail;
    };

    /* If there's no query params, return the truncated URI: */
    if( *query_str == '\0' ) {
        goto release_okay;
    };

    /* Copy the params to the head of the workspace: */
    params = strtmp_append(&ws_free, &ws_remain, params_in);
    if( !params) {
        goto release_bail;
    };

    /* Now, tokenize the query string and copy only matching params: */
    head = tokenize_querystring(&ws_free, &ws_remain, query_str);
    if( !head ) {
        goto release_bail;
    };

    /* Iterate over the list of parameters, looking for matches and appending
     * them. */
    for(filter_name = strtok_r(params, ",", &saveptr); filter_name;
        filter_name = strtok_r(NULL, ",", &saveptr))
    {
        for(current = head; current != NULL; current=current->next)
        {
            if(current->value && !strcmp(filter_name,current->name)) {
                new_uri_end += sprintf(new_uri_end, "%c%s=%s",
                    params_seen++ > 0 ? '&' : '?',
                    current->name, current->value);
/* If arrays are not enabled (default), we just break after the first match
 * to avoid unnecessary checks. However, for arrays it is necessary to keep
 * iterating through the list to find additional matches. A side effect of this
 * is that all elements of a given array will be rewritten in sequence next to
 * each other in the output array: */
#if !VMOD_QUERYFILTER_ARRAYS_ENABLED
                break;
#endif /* VMOD_QUERYFILTER_ARRAYS_ENABLED */
            } else if (current->flag && !strcmp(filter_name,current->name)) {
                new_uri_end += sprintf(new_uri_end, "%c%s",
                    params_seen++ > 0 ? '&' : '?',
                    current->name);
            };
        };
    };

release_okay:
    WS_Release(workspace, (new_uri_end-new_uri));
    return new_uri;

release_bail:
    WS_Release(workspace, 0);
    return NULL;
}

/* EOF */

