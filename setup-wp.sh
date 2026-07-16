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
    until docker compose exec db mysqladmin ping -h"localhost" -u"root" -p"root_password" --silent > /dev/null 2>&1; do
        sleep 2
    done
    echo "MariaDB is ready!"
}

# 1. Start containers (except benchmarker)
echo "Starting services..."
docker compose up -d db ols php-fpm-nginx nginx apache php-fpm-caddy caddy

# 2. Wait for db
wait_for_db

# 3. Run WordPress installation for each database via wp-cli
echo "Installing WordPress for OpenLiteSpeed (wp_ols)..."
docker compose exec -e WP_DB=wp_ols php-fpm-nginx wp core install \
    --url="http://ols" \
    --title="WordPress OpenLiteSpeed" \
    --admin_user="admin" \
    --admin_password="admin_password" \
    --admin_email="admin@example.com" \
    --skip-email \
    --allow-root

echo "Installing WordPress for Nginx (wp_nginx)..."
docker compose exec -e WP_DB=wp_nginx php-fpm-nginx wp core install \
    --url="http://nginx" \
    --title="WordPress Nginx" \
    --admin_user="admin" \
    --admin_password="admin_password" \
    --admin_email="admin@example.com" \
    --skip-email \
    --allow-root

echo "Installing WordPress for Apache (wp_apache)..."
docker compose exec -e WP_DB=wp_apache php-fpm-nginx wp core install \
    --url="http://apache" \
    --title="WordPress Apache" \
    --admin_user="admin" \
    --admin_password="admin_password" \
    --admin_email="admin@example.com" \
    --skip-email \
    --allow-root

echo "Installing WordPress for Caddy (wp_caddy)..."
docker compose exec -e WP_DB=wp_caddy php-fpm-nginx wp core install \
    --url="http://caddy" \
    --title="WordPress Caddy" \
    --admin_user="admin" \
    --admin_password="admin_password" \
    --admin_email="admin@example.com" \
    --skip-email \
    --allow-root

echo "=================================================="
echo " WordPress installation completed successfully!    "
echo "=================================================="
echo "OpenLiteSpeed: http://localhost:8081"
echo "Nginx:         http://localhost:8082"
echo "Apache:        http://localhost:8083"
echo "Caddy:         http://localhost:8084"
echo "=================================================="
