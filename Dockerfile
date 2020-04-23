FROM cntrump/ubuntu-ffmpeg:latest

ARG NGINX_VERSION=1.18.0

ARG DEP_PKGS="libpcre3-dev zlib1g-dev"

RUN apt-get update && apt-get install ${DEP_PKGS} -y && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN git clone -b v1.2.7 --depth=1 https://github.com/winshining/nginx-http-flv-module.git \
    && curl -O https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
    && tar -zxvf ./nginx-${NGINX_VERSION}.tar.gz && rm ./nginx-${NGINX_VERSION}.tar.gz \
    && cd ./nginx-${NGINX_VERSION} \
    && ./configure --prefix=/usr/local \
                   --with-threads \
                   --with-file-aio \
                   --with-http_v2_module \
                   --with-http_ssl_module \
                   --add-module=../nginx-http-flv-module \
    && make && make install && cd .. && rm -rf ./nginx-http-flv-module && rm -rf ./nginx-${NGINX_VERSION}

EXPOSE 1935
EXPOSE 80
EXPOSE 443

COPY nginx.conf /usr/local/conf/nginx.conf

RUN mkdir -p /opt/data && mkdir /www
ADD static /www/static

RUN /usr/local/sbin/nginx -t

CMD ["/usr/local/sbin/nginx"]
