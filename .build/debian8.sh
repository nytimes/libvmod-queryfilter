#!/bin/bash

# Take a copy of the source files to build in an isolated directory
mkdir -p /build
cp -R /vmod-queryfilter/* /build
cd /build

curl -L https://packagecloud.io/varnishcache/varnish52/gpgkey | apt-key add -

cat << EOF > /etc/apt/sources.list.d/varnish.list
deb https://packagecloud.io/varnishcache/varnish5/ubuntu/ trusty main
deb-src https://packagecloud.io/varnishcache/varnish5/ubuntu/ trusty main
EOF

apt-get update -y
apt-get install varnish varnish-dev -y --force-yes

./autogen.sh
./configure VARNISHSRC=/usr/include/varnish/
make
