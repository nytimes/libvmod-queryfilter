v0.1.0 2015/07/09
-----------------

 - Added the `--enable-query-arrays` feature to resolve Issue #2.
 - Updated workspace usage to guarantee proper alignment for structs
 - General configuration and doc cleanup
 - Query parameters are now search in forward order, instead of reverse. This
   only makes a difference for query arrays (i.e. it guarantees arrays aren't
   re-ordered)


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

