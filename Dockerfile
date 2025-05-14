FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /var/www/html

# 安裝必要套件與 PHP 擴充
RUN apt update && \
    apt install -y \
        git \
        zip \
        curl \
        software-properties-common \
        supervisor \
        nginx \
        php8.3 \
        php8.3-fpm \
        php8.3-cli \
        php8.3-dev \
        php8.3-curl \
        php8.3-mbstring \
        php8.3-xml \
        php8.3-zip \
        php8.3-mysql \
        php8.3-gd \
        php8.3-bcmath \
        php8.3-redis \
        php-pear \
        unixodbc-dev

# 安裝 Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# 設定 www-data UID 為 1000，避免宿主機權限問題
RUN existing_uid=$(id -u www-data) && \
    if [ "$existing_uid" != "1000" ]; then \
        existing_user=$(getent passwd 1000 | cut -d: -f1); \
        [ -n "$existing_user" ] && usermod -u 2000 "$existing_user"; \
        usermod -u 1000 www-data; \
    fi

# 建立 php-fpm 的 socket 路徑
RUN mkdir -p /run/php && chown www-data:www-data /run/php

# 建立 PHP log 目錄，避免 php-fpm 無法啟動
RUN mkdir -p /var/log/php && \
    touch /var/log/php/php-fpm.log && \
    chown -R www-data:www-data /var/log/php

# 複製設定檔
COPY dockerfiles/fpm/pool.d/www.conf /etc/php/8.3/fpm/pool.d/www.conf
COPY dockerfiles/fpm/php-fpm.conf /etc/php/8.3/fpm/php-fpm.conf
COPY dockerfiles/supervisord.conf /etc/supervisor/supervisord.conf
COPY dockerfiles/nginx/default.conf /etc/nginx/conf.d/default.conf
COPY dockerfiles/nginx/nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
