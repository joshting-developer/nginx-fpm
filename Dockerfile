FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /var/www/html

# 安裝必要套件與 PHP 8.4.10
RUN apt update && \
    apt install -y \
        lsb-release \
        ca-certificates \
        apt-transport-https \
        software-properties-common && \
    add-apt-repository ppa:ondrej/php -y && \
    apt update && \
    apt install -y \
        passwd \
        cron \
        git \
        zip \
        curl \
        jpegoptim \
        optipng \
        pngquant \
        gifsicle \
        supervisor \
        nginx \
        php8.4 \
        php8.4-fpm \
        php8.4-cli \
        php8.4-dev \
        php8.4-curl \
        php8.4-mbstring \
        php8.4-xml \
        php8.4-zip \
        php8.4-mysql \
        php8.4-gd \
        php8.4-bcmath \
        php8.4-redis \
        php8.4-sqlite3 \
        php8.4-intl\
        php-pear \
        unixodbc-dev

# 安裝 Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# 設定 www-data UID
RUN userdel -r ubuntu || true && \
    usermod -u 1000 www-data


RUN mkdir -p /var/log/php /var/log/supervisor /run/php /var/run/supervisor /var/www/html/storage/logs \
    && touch /var/log/php/php-fpm.log /var/log/php/php-fpm.err.log \
             /var/log/nginx.log /var/log/nginx.err.log \
             /var/log/laravel-queue.log /var/log/laravel-queue.err.log \
             /var/log/laravel-scheduler.log /var/log/laravel-scheduler.err.log \
             /var/log/supervisord.log \
    && chown -R www-data:www-data /var/log /run/php /var/run/supervisor /var/www/html/storage/logs

# 複製設定檔
COPY dockerfiles/fpm/pool.d/www.conf /etc/php/8.4/fpm/pool.d/www.conf
COPY dockerfiles/fpm/php-fpm.conf /etc/php/8.4/fpm/php-fpm.conf
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
