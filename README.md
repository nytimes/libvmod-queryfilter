libvmod-queryfilter
===================

Overview
--------
This is a simple VMOD for [Varnish Cache](https://www.varnish-cache.org/) which
provides query string filtering. It accepts a whitelist of parameter names and
returns the request URL with only the provided parameters and their values.

### Sort and Filter Functionality
The order of query string parameters is typically not considered, so an
effective caching strategy involves sorting the querystring parameters so that
identical name/value pairs that are in a different order for a given URL do not
create multiple cache records.

Libvmod-queryfilter does not require separate sort and filter calls because it
works by traversing the provided parameters and filtering as it goes.
The output contains parameter names in the same order that they were provided
to the VMOD, so by passing in parameter names in a consistent manner (e.g.,
alphabetical order), a resulting filtered request URL will be unique for its
combination of parameter names and values.

Usage
-----
Rewrite the request URL so that the query string only contains parameter
name/value pairs for the "id" and "q" parameters:

    import queryfilter;
    set req.url = queryfilter.filterparams(req.url, "id,q");

Building
--------
Libvmod-queryfilter attempts to be 100% C99 conformant. You should, therefore,
be able to build it without issue on most major compilers. However, it has only
been thorougly tested with the following compilers and targets:
 * gcc-4.4.7 (CentOS release 6.5 x86_64)
 * gcc-4.9.2p1 (x86_64-apple-darwin13.4.0)
 * clang-600.0.57 (x86_64-apple-darwin13.4.0)

### Setup
Before anything else is done, your source directory has to be initialized:

```Shell
./autogen.sh
```

### Configuration
This vmod must be compiled against a pre-built Varnish Cache 3.x source tree.
The path to the Varnish Cache source tree is specified via the *VARNISHSRC*
variable at configure time, e.g.:

```Shell
./configure VARNISHSRC=path/to/varnish-3.0.6 && make check
```

Additional configuration variables and options can be found by invoking
`configure --help`.

#### Query Arrays
By default, libvmod-queryfilter assumes query parameters are individual
name/value pairs (e.g. `a=1&b=2...`). Optional support for arrays in query
parameters (see [this Stackoverflow Question](http://stackoverflow.com/questions/6243051/how-to-pass-an-array-within-a-query-string))
can be enabled by passing the `--enable-query-arrays` at configure time.

### Check Targets
Libvmod-queryfilter provides a set of simple unittests driven by *varnishtest*.
They can be executed as part of the build process by invoking `make check`.

Notes
-----
Currently, there is only support for the Varnish 3.x API.

