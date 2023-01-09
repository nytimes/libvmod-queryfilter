v1.0.1 2022/0109:
-----------------

### Updates to fix issue #6:

 - Add support for Varnish 7.x
 - Add some docker-based test utilities (this is a pre-CI HACK)
 - Add tests to check flag-style parameters with arrays disabled.
 - Add additional tests to verify logic for parameters with no values.
 - Fix issue#6

v1.0.0 2020/03/02
-----------------

### Features
 - Build against pre-installed dev packages or source for varnish 3 through 6
 - Make query param arrays runtime configurable.
 - Updated documentation

### Miscellaneous
 - Move check for empty query string up
 - Remove superfluous var checks/initialization
 - Fix PATH for test run
 - Remove `flag` and `next` from `query_param_t`

v0.2.3 2018/01/15
-----------------
 - _NOTICE file added to track contributors!_
 - Handle flag-like parameters in query string

v0.2.2 2018/01/14
-----------------
 - Varnish 5 support

v0.2.1 2016/06/10
-----------------
 - VCC 4 module docs
 - Changes for migration to NYTimes account
 - Macro docs for custom m4 files

v0.2.0 2016/06/09
-----------------
 - Varnish 4.x support added
 - autoconf macros refactored and cleaned up to allow each component to be
   specified individually, when desired

v0.1.1 2015/07/20
-----------------
 - Added additional m4 macros for backwards compatibility with older versions
   of autoconf and pkg-config (pulled from m4sh and pkg.m4).

v0.1.0 2015/07/09
-----------------
 - Added the `--enable-query-arrays` feature to resolve Issue #2.
 - Updated workspace usage to guarantee proper alignment for structs
 - General configuration and doc cleanup
 - Query parameters are now search in forward order, instead of reverse. This
   only makes a difference for query arrays (i.e. it guarantees arrays aren't
   re-ordered)
 - Use md2man (when available) to generate manpage for make dist


v0.0.4 2015/02/06
-----------------
Remove a kludge and save a few bytes of WS on success.

v0.0.3 2015/02/03
-----------------
### Bugfixes
Check for empty query parameter values.


v0.0.2 2015/01/29
-----------------
### Bugfixes
Removed linked list node removal to patch bug where match search could run off the end of the list.


v0.0.1 2015/01/27
-----------------
### Optimizations
On matching query parameter, remove matching item from linked list to reduce
superfluous node traversal.

### Bugfixes
#### Single query param results in filtering error
The following config:
    
    set req.url = queryfilter.filterparams(req.url, "q,tag");
    
Was failing for URI's containing only one of the query terms, e.g.:
    
    curl "http://my_host/?q=1"
    

v0.0.0 2015/01/26
-----------------
Initial version.

