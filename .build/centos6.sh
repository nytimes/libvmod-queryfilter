#!/bin/bash

# Take a copy of the source files to build in an isolated directory
mkdir -p /build
cp -R /vmod-queryfilter/* /build
cd /build

cat << EOF > /etc/yum.repos.d/varnish.repo
[varnish]
name=Varnish Repository
baseurl=https://packagecloud.io/varnishcache/varnish41/el/6/\$basearch
enabled=1
fastestmirror_enabled=0
gpgcheck=0
gpgkey=https://packagecloud.io/varnishcache/varnish41/gpgkey
EOF

yum -q makecache -y --disablerepo='*' --enablerepo='varnish'
yum install varnish -y

# Varnish version installed
VERSION=$(rpm --queryformat "%{VERSION}" -q varnish)

# Grab the source for the Varnish version installed
wget "https://github.com/varnishcache/varnish-cache/archive/varnish-$VERSION.tar.gz"
tar -xzf "varnish-$VERSION.tar.gz"

# Build the source
cd "varnish-cache-varnish-$VERSION"
export VARNISHSRC=$(pwd)
./autogen.sh && ./configure && make

cd ..

# Build the vmod
./autogen.sh
./configure VARNISHSRC=$VARNISHSRC
make
make install

# Copy the vmod to where CentOS 6.x wants it
cp -R /usr/local/lib/varnish/vmods/* /usr/lib64/varnish/vmods/.

# Add a varnish file configured to use the plugin
cat << EOF > /etc/varnish/default.vcl
vcl 4.0;

import queryfilter;

backend default {
    .host = "127.0.0.1";
    .port = "8080";
}

sub vcl_recv {
    set req.url = queryfilter.filterparams(req.url, "id,q");
}
EOF

service varnish start
