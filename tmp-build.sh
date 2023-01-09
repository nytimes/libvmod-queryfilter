#!/usr/bin/env bash

# Print input args to STDERR and exit 1
err_bail() {
    printf '\n\e[00;03;31mERROR: %s\e[00m\n' "$*" >&2
    exit 1
}

log_info() {
    printf '\e[00;02mINFO: \e[00m%s\e[00m\n' "$*" >&2
}

run_cmd() {
    local cmd
    cmd="$1" ; shift
    printf '\e[00;02mEXEC: \e[00;32m%s %s\e[00m\n' "${cmd}" "$*" >&2
    ${DRY} ${cmd} "$@"
}

repodir="$( cd ${0%/*} ; echo $PWD )"

cd ${repodir}

run_cmd docker build . \
    --build-arg "VARNISH_VERSION=${VARNISH_VERSION:-"7.2.1"}" \
    -t libvmod-queryfilter:local-${VARNISH_VERSION}
