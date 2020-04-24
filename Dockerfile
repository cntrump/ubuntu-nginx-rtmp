FROM cntrump/ubuntu-ffmpeg:latest

ARG NGINX_VERSION=1.18.0

ARG DEP_PKGS="libpcre3-dev libperl-dev"

RUN apt-get update && apt-get install ${DEP_PKGS} -y && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN git clone -b v1.2.7 --depth=1 https://github.com/winshining/nginx-http-flv-module.git \
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
    && make && make install && cd .. && rm -rf ./nginx-http-flv-module && rm -rf ./nginx-${NGINX_VERSION}

RUN groupadd --force --system --gid 101 nginx && useradd --system -g nginx --no-create-home --home /nonexistent --shell /bin/false --non-unique --uid 101 nginx

EXPOSE 1935
EXPOSE 80
EXPOSE 443

COPY nginx.conf /etc/nginx/nginx.conf

RUN mkdir -p /var/cache/nginx && mkdir -p /opt/data && mkdir /www
ADD static /www/static

RUN /usr/sbin/nginx -t && /usr/sbin/nginx -V

CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
