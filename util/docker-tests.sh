#!/usr/bin/env bash
repodir="$( cd ${0%/*}/.. ; echo $PWD )"

queryfilter_test() {
    cd ${repodir}
    docker build . \
        --build-arg "VARNISH_VERSION=${VARNISH_VERSION:-"7.2.1"}" \
        -t libvmod-queryfilter:local-${VARNISH_VERSION}
}

for VARNISH_VERSION in ${VARNISH_VERSIONS[@]}; do
    export VARNISH_VERSION
    queryfilter_test
done

