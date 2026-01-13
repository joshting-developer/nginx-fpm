# nginx-fpm

整合 Nginx + PHP-FPM + Supervisor + Cron 的單一容器環境，預設搭配 Laravel 使用。

## 立意
當初是因為把 Nginx 跟 FPM 分開成兩個容器部署時，靜態資源的存取容易出現問題，所以才建立這個 `nginx-fpm` 專案，讓同一容器內直接處理靜態資源與 PHP 請求。

## 特色
- 單一容器同時跑 Nginx、PHP-FPM、Queue、Scheduler（Cron）
- PHP 8.4.10、Composer 預裝
- Nginx 預設 `public/` 為網站根目錄，並優先處理靜態資源

## 快速開始
```bash
docker compose up --build
```

瀏覽：`http://localhost:49999`

## 目錄與設定
- Nginx 設定：`dockerfiles/nginx/default.conf`
- PHP-FPM 設定：`dockerfiles/fpm/php-fpm.conf`、`dockerfiles/fpm/pool.d/www.conf`
- Supervisor 設定：`dockerfiles/supervisord.conf`
- Cron 排程：`dockerfiles/cron/laravel-scheduler`

## 日誌位置（容器內）
- PHP-FPM：`/var/log/php/php-fpm.log`、`/var/log/php/php-fpm.err.log`
- Nginx：`/var/log/nginx.log`、`/var/log/nginx.err.log`
- Queue：`/var/log/laravel-queue.log`、`/var/log/laravel-queue.err.log`
- Scheduler：`/var/log/laravel-scheduler.log`、`/var/log/laravel-scheduler.err.log`
- Supervisor：`/var/log/supervisord.log`

## 注意事項
- Queue 與 Scheduler 以 Laravel Artisan 指令為預設，如非 Laravel 專案請調整 `dockerfiles/supervisord.conf` 與 `dockerfiles/cron/laravel-scheduler`。
- `docker-compose.yml` 會把專案掛載到 `/var/www/html`，請確保專案根目錄含 `public/`。
