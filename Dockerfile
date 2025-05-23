FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /var/www/html

# 安裝必要套件與 PHP 擴充
RUN apt update && \
    apt install -y \
        cron \
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

RUN mkdir -p /var/log/php /var/log/supervisor /run/php /var/run/supervisor /var/www/html/storage/logs \
    && touch /var/log/php/php-fpm.log /var/log/php/php-fpm.err.log \
             /var/log/nginx.log /var/log/nginx.err.log \
             /var/log/laravel-queue.log /var/log/laravel-queue.err.log \
             /var/log/laravel-scheduler.log /var/log/laravel-scheduler.err.log \
             /var/log/supervisord.log \
    && chown -R www-data:www-data /var/log /run/php /var/run/supervisor /var/www/html/storage/logs
   

# 複製設定檔
COPY dockerfiles/fpm/pool.d/www.conf /etc/php/8.3/fpm/pool.d/www.conf
COPY dockerfiles/fpm/php-fpm.conf /etc/php/8.3/fpm/php-fpm.conf
COPY dockerfiles/supervisord.conf /etc/supervisor/supervisord.conf
COPY dockerfiles/nginx/default.conf /etc/nginx/conf.d/default.conf
COPY dockerfiles/nginx/nginx.conf /etc/nginx/nginx.conf

# 調整資料夾權限
COPY dockerfiles/bash/fix-permissions.sh /init/fix-permissions.sh
RUN chmod +x /init/fix-permissions.sh

# 複製排程進入 cron.d
COPY dockerfiles/cron/laravel-scheduler /etc/cron.d/laravel-scheduler
RUN chmod 0644 /etc/cron.d/laravel-scheduler


EXPOSE 80

ENTRYPOINT ["/init/fix-permissions.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
