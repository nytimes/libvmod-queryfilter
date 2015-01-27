libvmod-queryfilter
===================
This is a simple VMOD for Varnish Cache which provides query string filtering
using a list of parmeters.


Usage
-----
Rewrite URL so that the query string only contains parameter name/value pairs
for the "q" and "id" parameters:

    import queryfilter
    set req.url = queryfilter.filterparams(req.url, "q,id");


Notes
-----
Currently, there is only support for the Varnish 3.x API.

