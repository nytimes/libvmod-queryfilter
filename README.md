libvmod-queryfilter
===================
## Overview
This is a simple VMOD for [Varnish Cache](https://www.varnish-cache.org/) which provides query string filtering. It accepts a whitelist of parameter names and returns the request URL with only the provided parameters and their values.

### Sort and Filter Functionality
The order of query string parameters is typically not considered, so an effective caching strategy involves sorting the querystring parameters so that identical name/value pairs that are in a different order for a given URL do not create multiple cache records.

libvmod-queryfilter does not require separate sort and filter calls because it works by traversing the provided parameters and filtering as it goes. The output contains parameter names in the same order that they were provided to the VMOD, so by passing in parameter names in a consistent manner (e.g., alphabetical order), a resulting filtered request URL will be unique for its combination of parameter names and values.

Usage
-----
Rewrite the request URL so that the query string only contains parameter name/value pairs for the "id" and "q" parameters:

    import queryfilter;
    set req.url = queryfilter.filterparams(req.url, "id,q");


Notes
-----
Currently, there is only support for the Varnish 3.x API.

