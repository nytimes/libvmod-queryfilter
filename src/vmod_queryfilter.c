/*=============================================================================
 * libvmod-queryfilter: Simple VMOD for filtering/sorting query strings
 *
 * Copyright © 2014-2020 The New York Times Company
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

#include "config.h"
#include <stdarg.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

/*--- Varnish 3.x: ---*/
#if VARNISH_API_MAJOR == 3
#include "vrt.h"
#include "vcc_if.h"
#include "cache.h"
typedef struct sess req_ctx;
#endif /* VARNISH_API_MAJOR == 3 */

/*--- Varnish 4.x and 5.x ---*/
#if (VARNISH_API_MAJOR == 4 || VARNISH_API_MAJOR == 5 )
#include "vrt.h"
#include "vcc_if.h"
#include "vre.h"
#include "cache/cache.h"
typedef const struct vrt_ctx req_ctx;
#endif /* (VARNISH_API_MAJOR == 4 || VARNISH_API_MAJOR == 5 ) */

/*--- Varnish 6.x ---*/
#if (VARNISH_API_MAJOR == 6 || VARNISH_API_MAJOR == 7)
#include "cache/cache.h"
#include "vcl.h"
#include "vre.h"
#include "vas.h"
#include "vsb.h"
#include "vcc_if.h"
typedef const struct vrt_ctx req_ctx;
#endif /* VARNISH_API_MAJOR == 6 */

/* WS_Reserve was deprecated in Varnish 6.3.0: */
#if (VARNISH_API_MAJOR < 6) || (VARNISH_API_MAJOR == 6 && VARNISH_API_MINOR < 3)
#define WS_ReserveAll(ws) \
    WS_Reserve(ws, 0)
#endif /* Varnish Version >= 6.3 */


/** Alignment macros ala varnish internals: */
#define PALIGN_SIZE     (sizeof(void*))
#define PALIGN_DELTA(p) (PALIGN_SIZE - (((uintptr_t)p) % PALIGN_SIZE))

/** Simple struct used for one-time query parameter tokenization. */
typedef struct query_param {
    char* name;
    char* value;
} query_param_t;

/** Query string tokenizer. This function takes a query string as input, and
 * yields array of name/value pairs. Allocation happens inside the
 * reserved workspace, pointed to by *ws_free. On error, no space is consumed.
 *
 * @param result pointer to query_param_t* at the head of the array
 * @param ws_free pointer to char* at the head of the reserved workspace
 * @param ws_remain the amount of reserved workspace remaining, in bytes
 * @return the number of non-empty query params or -1 on OOM
 */
static int
tokenize_querystring(query_param_t** result, char** ws_free, unsigned* remain, char* query_str)
{
    int no_param = 0;
    char* save_ptr;
    char* param_str;

    /* Temporary copies of workspace head + allocation counter: */
    char* ws_free_temp = *ws_free;
    unsigned remain_temp = *remain;
    query_param_t* head = NULL;

    /* Move the free pointer up so that query_param_t objects allocated on
     * WS storage are properly aligned: */
    unsigned align_adjust = PALIGN_DELTA(ws_free_temp);
    ws_free_temp += align_adjust;
    remain_temp -= align_adjust;

    /* Tokenize the query parameters into an array: */
    for(param_str = strtok_r(query_str, "&", &save_ptr); param_str;
        param_str = strtok_r(NULL, "&", &save_ptr))
    {
        /* If we run out of space at any point, just bail.
         * Note that in this case, we don't update ws_free or remain so that
         * the space we've consumed thus far is returned to the workspace. */
        if( remain_temp < sizeof(query_param_t) ) {
            (*result) = NULL;
            return -1;
        };

        /* "Allocate" space at the head of the workspace and place a node: */
        query_param_t* param = (query_param_t*)ws_free_temp;
        param->name = param_str;
        /* TODO: will varnish filter malformed queries, e.g.: "?=&"? 
         * Else: this needs some more rigor:
         */
        param->value = strchr(param_str,'=');
        if( param->value ) {
            *(param->value++) = '\0';

            /* If the actual value is the end of the string
             * or the beginning of another parameter, set the
             * parameter to NULL.
             */
            if( *(param->value) == '\0' || *(param->value) == '&') {
                param->value = NULL;
            };
        };

        if( !head ) {
            head = param;
        };
        remain_temp -= sizeof(query_param_t);
        ws_free_temp += sizeof(query_param_t);
        no_param++;
    };

    (*result) = head;
    (*ws_free) = ws_free_temp;
    (*remain) = remain_temp;
    return no_param;
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
 * 2. Tokenize the querystring *once* and store it as an array
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
vmod_filterparams(req_ctx* sp, const char* uri, const char* params_in, unsigned arrays_enabled)
{
    char* saveptr;
    char* new_uri;
    char* new_uri_end;
    char* query_str;
    char* params;
    char* ws_free;
    struct ws* workspace = sp->ws;
    query_param_t* head;
    query_param_t* current;
    const char* filter_name;
    int i;
    int no_param;
    unsigned ws_remain;
    char sep = '?';

    /* Right off, do nothing if there's no query string: */
    query_str = strchr(uri, '?');
    if( query_str == NULL ) {
        return uri;
    }

    /* Reserve the *rest* of the workspace - it's okay, we're gonna release
     * almost all of it in the end ;) */
    ws_remain = WS_ReserveAll(workspace);
    ws_free = workspace->f;

    /* Duplicate the URI, bailing on OOM: */
    new_uri = strtmp_append(&ws_free, &ws_remain, uri);
    if( new_uri == NULL ) {
        goto release_bail;
    };

    /* Terminate the URI at the beginning of the query string: */
    new_uri_end = new_uri + (query_str - uri);
    *new_uri_end = '\0';
    query_str = new_uri_end+1;

    /* If there are no query params, return the sanitized URI: */
    if( *query_str == '\0' ) {
        goto release_okay;
    };

    /* Copy the query string to the head of the workspace: */
    query_str = strtmp_append(&ws_free, &ws_remain, query_str);
    if( !query_str ) {
        goto release_bail;
    };

    /* Copy the params to the head of the workspace: */
    params = strtmp_append(&ws_free, &ws_remain, params_in);
    if( !params) {
        goto release_bail;
    };

    /* Now, tokenize the query string and copy only matching params: */
    no_param = tokenize_querystring(&head, &ws_free, &ws_remain, query_str);
    /* If we ran out of memory. Bail out. */
    if( no_param < 0 ) {
        goto release_bail;
    };

    /* If we only had empty tokens (e.g. "?a=&b=") we're done! */
    if( no_param == 0 ) {
        goto release_okay;
    };

    /* Iterate over the list of parameters, looking for matches and appending
     * them. */
    for(filter_name = strtok_r(params, ",", &saveptr); filter_name;
        filter_name = strtok_r(NULL, ",", &saveptr))
    {
        for(i=0, current=head; i<no_param; ++i, ++current)
        {
            if(strcmp(filter_name, current->name)) {
                continue;
            };

            if(current->value && (*current->value) != '\0') {
                new_uri_end += sprintf(new_uri_end, "%c%s=%s",
                    sep, current->name, current->value);
            } else {
                /* Empty params have been excluded, so this
                 * is a flag-style query param: */
                new_uri_end += sprintf(new_uri_end, "%c%s",
                    sep, current->name);
            };

            /* After the first param, swap the separator: */
            sep = '&';

            /* If arrays are not enabled (default), we just break after the
             * first match to avoid unnecessary checks. However, for arrays it
             * is necessary to keep iterating through the list to find
             * additional matches. A side effect of this is that all elements of
             * a given array will be rewritten in sequence next to each other in
             * the output array: */
            if( !arrays_enabled ) {
                break;
            }
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

