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

wget "https://github.com/varnishcache/varnish-cache/archive/varnish-$VERSION.tar.gz"
tar -xzf "varnish-$VERSION.tar.gz"

cd "varnish-cache-varnish-$VERSION"
export VARNISHSRC=$(pwd)
./autogen.sh && ./configure && make

cd ..

./autogen.sh
./configure VARNISHSRC=$VARNISHSRC
make
