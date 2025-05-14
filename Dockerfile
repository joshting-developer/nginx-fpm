FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /var/www/html

# 安裝必要套件
RUN apt update && \
    apt install -y \
        git zip curl apt-utils \
        software-properties-common lsb-release gnupg2 \
        supervisor nginx php-pear unixodbc-dev

# 安裝 PHP 7.4 與擴充
RUN add-apt-repository -y ppa:ondrej/php && \
    apt update && \
    apt install -y \
        php7.4 php7.4-fpm php7.4-cli php7.4-dev \
        php7.4-curl php7.4-mbstring php7.4-xml \
        php7.4-zip php7.4-mysql php7.4-gd \
        php7.4-bcmath php7.4-redis

# 安裝 Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# 設定 www-data UID 為 1000（避免宿主機權限問題）
RUN usermod -u 1000 www-data

# 建立 .sock 路徑
RUN mkdir -p /run/php && chown www-data:www-data /run/php

# 複製設定檔
COPY dockerfiles/fpm/pool.d/www.conf /etc/php/7.4/fpm/pool.d/www.conf
COPY dockerfiles/fpm/php-fpm.conf /etc/php/7.4/fpm/php-fpm.conf
COPY dockerfiles/supervisord.conf /etc/supervisor/supervisord.conf
COPY dockerfiles/nginx/default.conf /etc/nginx/conf.d/default.conf


EXPOSE 80

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
