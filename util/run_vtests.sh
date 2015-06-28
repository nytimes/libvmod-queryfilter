#!/bin/bash
if [ -z "${VARNISHSRC}" ] ; then
    echo "Usage: VARNISHSRC=<path to varnish source> $(basename $0) TEST"
    exit 1
fi

${VARNISHSRC}/bin/varnishtest/varnishtest \
    -Dvarnish_source=${VARNISHSRC} \
    -Dvarnishd=${VARNISHSRC}/bin/varnishd/varnishd \
    -Dvmod_topbuild=$(pwd) $*

# EOF

