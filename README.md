# :information_source: the default branch has been moved to `main`

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

LICENSE
-------
Copyright © 2014-2020 The New York Times Company.
Licensed under the Apache 2.0 License. See [LICENSE](./LICENSE) for more information.

See the [NOTICE](./NOTICE) file for a list of contributors.

(To list individual developers, try `git shortlog -s` or [this page](https://github.com/NYTimes/libvmod-queryfilter/graphs/contributors)).

Usage
-----
Rewrite the request URL so that the query string only contains parameter
name/value pairs for the "id" and "q" parameters:

##### Query Arrays Disabled

```
import queryfilter;
set req.url = queryfilter.filterparams(req.url, "id,q", false);
```

##### Query Arrays Enabled

```
import queryfilter;
set req.url = queryfilter.filterparams(req.url, "id,q,vals[]", true);
```

#### Query Arrays
When query arrays are disabled, libvmod-queryfilter assumes query parameters are
individual name/value pairs (e.g. `a=1&b=2...`). Support for arrays in query
parameters - e.g. `a[]=1&a[]=2...` (see [this Stackoverflow Question](http://stackoverflow.com/questions/6243051/how-to-pass-an-array-within-a-query-string) or [Issue #2](https://github.com/NYTimes/libvmod-queryfilter/issues/2)
for more examples) can be enabled by passing `true` for the `arrays_enabled`
argument. When this option is enabled, array parameters will be
preserved - in order - in the output URI.

Building
--------
Libvmod-queryfilter attempts to be 100% C99 conformant. You should, therefore,
be able to build it without issue on most major compilers. The vmod can be
built against a compiled varnish source, or against an installed
`varnish-dev/-devel` package which includes the appropriate `.pc` files.

### Setup
Before anything else is done, your source directory has to be initialized:

```sh
./autogen.sh
```

### Configuration
To build against a standard varnish development package, you should be able to
simply invoke:
```sh
./configure && make && make check
```
(See `./configure --help` for configure-time options)

This vmod can also be compiled against a pre-built Varnish Cache 3.x/4.x/5.x/6.x
source by indicating the path to the (pre-compiled!) varnish source using the
`VARNISHSRC` configuration variable, like so:

```sh
./configure VARNISHSRC=path/to/varnish-M.m.p && make && make check
```

Additional configuration variables and options can be found by invoking
`configure --help`.

### Check Targets
Libvmod-queryfilter provides a set of simple unit tests driven by
**varnishtest**. They can be executed as part of the build process by
invoking `make check`.
