#!/bin/bash
set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

echo "=================================================="
echo "    Setting up WordPress Server Benchmark         "
echo "=================================================="

# 1. Download WordPress
if [ ! -d "wordpress" ]; then
    echo "Downloading WordPress core..."
    curl -L https://wordpress.org/latest.tar.gz | tar -xz
    echo "WordPress downloaded successfully."
else
    echo "WordPress folder already exists. Skipping download."
fi

# 2. Create dynamic wp-config.php
echo "Creating dynamic wp-config.php..."
cat <<'EOF' > wordpress/wp-config.php
<?php
/**
 * The base configuration for WordPress
 *
 * @link https://wordpress.org/support/article/editing-wp-config-php/
 *
 * @package WordPress
 */

define( 'DB_USER', 'wp_user' );
define( 'DB_PASSWORD', 'wp_password' );
define( 'DB_HOST', 'db' );
define( 'DB_CHARSET', 'utf8' );
define( 'DB_COLLATE', '' );

// Select database based on environment variable
$wp_db = getenv('WP_DB');
if (!$wp_db) {
    // Fallback to hostname/port-based selection if env var is not set
    $host = $_SERVER['HTTP_HOST'] ?? '';
    if (strpos($host, '8081') !== false || strpos($host, 'ols') !== false) {
        $wp_db = 'wp_ols';
    } elseif (strpos($host, '8082') !== false || strpos($host, 'nginx') !== false) {
        $wp_db = 'wp_nginx';
    } elseif (strpos($host, '8083') !== false || strpos($host, 'apache') !== false) {
        $wp_db = 'wp_apache';
    } elseif (strpos($host, '8084') !== false || strpos($host, 'caddy') !== false) {
        $wp_db = 'wp_caddy';
    } else {
        $wp_db = 'wp_ols'; // default
    }
}

define( 'DB_NAME', $wp_db );

// Authentication Unique Keys and Salts.
define( 'AUTH_KEY',         'put your unique phrase here' );
define( 'SECURE_AUTH_KEY',  'put your unique phrase here' );
define( 'LOGGED_IN_KEY',    'put your unique phrase here' );
define( 'NONCE_KEY',        'put your unique phrase here' );
define( 'AUTH_SALT',        'put your unique phrase here' );
define( 'SECURE_AUTH_SALT', 'put your unique phrase here' );
define( 'LOGGED_IN_SALT',   'put your unique phrase here' );
define( 'NONCE_SALT',       'put your unique phrase here' );

$table_prefix = 'wp_';

define( 'WP_DEBUG', false );

// If behind a proxy/reverse proxy, detect HTTPS
if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {
    $_SERVER['HTTPS'] = 'on';
}

if ( ! defined( 'ABSPATH' ) ) {
    define( 'ABSPATH', __DIR__ . '/' );
}

require_once ABSPATH . 'wp-settings.php';
EOF

# 3. Set permissions
echo "Setting permissions for WordPress folder..."
chmod -R 777 wordpress

echo "Setup complete! Run './setup-wp.sh' after starting containers to install WordPress."
