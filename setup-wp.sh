#!/bin/bash
set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

echo "=================================================="
echo "    Installing WordPress on all Web Servers       "
echo "=================================================="

# Function to check if db is ready
wait_for_db() {
    echo "Waiting for MariaDB database to be ready..."
    until docker compose exec db mysql -u root -p"root_password" -e "SHOW DATABASES;" 2>/dev/null | grep -q "wp_ols"; do
        sleep 2
    done
    echo "MariaDB databases are fully initialized!"
}

# 1. Start containers (except benchmarker)
echo "Starting services..."
docker compose up -d db ols php-fpm-nginx nginx apache php-fpm-caddy caddy

# 2. Wait for db
wait_for_db

# 3. Run WordPress installation for each database via wp-cli.phar natively
echo "Installing WordPress for OpenLiteSpeed (wp_ols)..."
docker compose exec -w /var/www/vhosts/localhost/html ols php wp-cli.phar core install \
    --url="http://ols" \
    --title="WordPress OpenLiteSpeed" \
    --admin_user="admin" \
    --admin_password="admin_password" \
    --admin_email="admin@example.com" \
    --skip-email \
    --allow-root

echo "Installing LiteSpeed Cache plugin for OpenLiteSpeed..."
docker compose exec -w /var/www/vhosts/localhost/html ols php wp-cli.phar plugin install litespeed-cache --activate --allow-root

echo "Installing WordPress for Nginx (wp_nginx)..."
docker compose exec -w /var/www/html php-fpm-nginx php wp-cli.phar core install \
    --url="http://nginx" \
    --title="WordPress Nginx" \
    --admin_user="admin" \
    --admin_password="admin_password" \
    --admin_email="admin@example.com" \
    --skip-email \
    --allow-root

echo "Installing WordPress for Apache (wp_apache)..."
docker compose exec -w /var/www/html apache php wp-cli.phar core install \
    --url="http://apache" \
    --title="WordPress Apache" \
    --admin_user="admin" \
    --admin_password="admin_password" \
    --admin_email="admin@example.com" \
    --skip-email \
    --allow-root

echo "Installing WP Super Cache plugin for Apache..."
docker compose exec -w /var/www/html apache php wp-cli.phar plugin install wp-super-cache --activate --allow-root
docker compose exec -w /var/www/html apache php -r "define('WP_USE_THEMES', false); require('wp-load.php'); if (function_exists('wp_cache_enable')) { wp_cache_enable(); }"

echo "Installing WordPress for Caddy (wp_caddy)..."
docker compose exec -w /var/www/html php-fpm-caddy php wp-cli.phar core install \
    --url="http://caddy" \
    --title="WordPress Caddy" \
    --admin_user="admin" \
    --admin_password="admin_password" \
    --admin_email="admin@example.com" \
    --skip-email \
    --allow-root

echo "Installing WP Super Cache plugin for Caddy..."
docker compose exec -w /var/www/html php-fpm-caddy php wp-cli.phar plugin install wp-super-cache --activate --allow-root
docker compose exec -w /var/www/html php-fpm-caddy php -r "define('WP_USE_THEMES', false); require('wp-load.php'); if (function_exists('wp_cache_enable')) { wp_cache_enable(); }"

echo "=================================================="
echo " WordPress installation completed successfully!    "
echo "=================================================="
echo "OpenLiteSpeed: http://localhost:8081"
echo "Nginx:         http://localhost:8082"
echo "Apache:        http://localhost:8083"
echo "Caddy:         http://localhost:8084"
echo "=================================================="
