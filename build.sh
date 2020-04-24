#!/bin/sh

set -e

NGINX_VERSION=1.18.0

DEP_PKGS="libpcre3-dev libperl-dev zlib1g-dev"

sudo apt-get update && sudo apt-get install ${DEP_PKGS} -y

git clone -b v1.2.7 --depth=1 https://github.com/winshining/nginx-http-flv-module.git \
    && curl -O https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
    && tar -zxvf ./nginx-${NGINX_VERSION}.tar.gz && rm ./nginx-${NGINX_VERSION}.tar.gz \
    && cd ./nginx-${NGINX_VERSION} \
    && ./configure --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib/nginx/modules \
                   --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log \
                   --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp \
                   --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
                   --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
                   --with-perl_modules_path=/usr/lib/perl5/vendor_perl --user=nginx --group=nginx --with-compat --with-file-aio --with-threads \
                   --with-http_addition_module --with-http_auth_request_module --with-http_dav_module --with-http_flv_module \
                   --with-http_gunzip_module --with-http_gzip_static_module --with-http_mp4_module --with-http_random_index_module \
                   --with-http_realip_module --with-http_secure_link_module --with-http_slice_module --with-http_ssl_module \
                   --with-http_stub_status_module --with-http_sub_module --with-http_v2_module --with-mail --with-mail_ssl_module \
                   --with-stream --with-stream_realip_module --with-stream_ssl_module --with-stream_ssl_preread_module \
                   --with-cc-opt='-Os -fomit-frame-pointer' --with-ld-opt=-Wl,--as-needed \
                   --add-module=../nginx-http-flv-module \
    && make && sudo make install && cd .. && rm -rf ./nginx-http-flv-module && rm -rf ./nginx-${NGINX_VERSION} && sudo mkdir -p /var/cache/nginx

sudo groupadd --force --system --gid 101 nginx \
    && sudo useradd --system -g nginx --no-create-home --home /nonexistent --shell /bin/false --non-unique --uid 101 nginx
