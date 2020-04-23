#!/bin/sh

set -e

NGINX_VERSION=1.18.0

DEP_PKGS="libpcre3-dev zlib1g-dev"

sudo apt-get update && sudo apt-get install ${DEP_PKGS} -y


git clone -b v1.2.7 --depth=1 https://github.com/winshining/nginx-http-flv-module.git \
    && curl -O https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
    && tar -zxvf ./nginx-${NGINX_VERSION}.tar.gz && rm ./nginx-${NGINX_VERSION}.tar.gz \
    && cd ./nginx-${NGINX_VERSION} \
    && ./configure --prefix=/usr/local \
                   --with-threads \
                   --with-file-aio \
                   --with-http_v2_module \
                   --with-http_ssl_module \
                   --add-module=../nginx-http-flv-module \
    && make && sudo make install && cd .. && rm -rf ./nginx-http-flv-module && rm -rf ./nginx-${NGINX_VERSION}
