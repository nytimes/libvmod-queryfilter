# syntax=docker/dockerfile:1
#===============================================================================
# NOTE: This docker file is a quick hack to provide a way to test the vmod
#       against multiple varnish versions, in preparation of moving to CI
#       (drone).
#
#-------------------------------------------------------------------------------
# vmod-queryfilter-dev-base: tooling required to build varnish + vmod
#-------------------------------------------------------------------------------

FROM gcc:latest AS vmod-queryfilter-dev-base

RUN apt-get update
RUN apt-get install -y \
	pip
RUN pip install \
	docutils \
	sphinx

#-------------------------------------------------------------------------------
# vmod-queryfilter-varnish: fresh varnish install from source
#-------------------------------------------------------------------------------
ARG VARNISH_VERSION=7.2.1
FROM vmod-queryfilter-dev-base AS vmod-queryfilter-varnish
ENV VARNISH_VERSION=${VARNISH_VERSION}
ENV VARNISHSRC=/src/varnish-cache-varnish-${VARNISH_VERSION}
ENV CFLAGS="-Wno-error=format-overflow"

# Download and prep source:
RUN mkdir -p /src \
	&& cd /src \
	&& wget https://github.com/varnishcache/varnish-cache/archive/refs/tags/varnish-${VARNISH_VERSION}.tar.gz \
	&& tar -xzf varnish-${VARNISH_VERSION}.tar.gz \
	&& cd varnish-cache-varnish-${VARNISH_VERSION} \
	&& ./autogen.sh \
	&& ./configure \
		--prefix=/usr/local \
	&& make \
	&& make install

#-------------------------------------------------------------------------------
# vmod-queryfilter-vmod: build and test the vmod
#-------------------------------------------------------------------------------
FROM vmod-queryfilter-varnish AS vmod-queryfilter-test

COPY . /src/libvmod-queryfilter

RUN cd /src/libvmod-queryfilter \
	&& ./autogen.sh

RUN mkdir -p /src/build \
	&& cd /src/build \
	&& ../libvmod-queryfilter/configure \
		--prefix=/usr/local \
	&& make \
	&& make check
