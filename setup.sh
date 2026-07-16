#!/bin/bash
set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

echo "=================================================="
echo "    Setting up WordPress Server Benchmark         "
echo "=================================================="

# 1. Download WordPress Master
if [ ! -d "wordpress_master" ]; then
    echo "Downloading WordPress core..."
    mkdir -p wordpress_master_tmp
    curl -L https://wordpress.org/latest.tar.gz | tar -xz -C wordpress_master_tmp --strip-components=1
    mv wordpress_master_tmp wordpress_master
    echo "WordPress downloaded successfully."
else
    echo "WordPress master folder already exists. Skipping download."
fi

# 1.1. Download WP-CLI
if [ ! -f "wordpress_master/wp-cli.phar" ]; then
    echo "Downloading WP-CLI..."
    curl -o wordpress_master/wp-cli.phar https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wordpress_master/wp-cli.phar
fi

# 1.5. Generate Self-Signed SSL Certificates
echo "Generating self-signed SSL certificates..."
mkdir -p ssl
if [ ! -f "ssl/server.crt" ] || [ ! -f "ssl/server.key" ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
      -keyout ssl/server.key -out ssl/server.crt \
      -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"
    echo "SSL certificates generated successfully."
else
    echo "SSL certificates already exist."
fi

# 2. Copy WordPress to individual server folders
SERVERS=("ols" "nginx" "apache" "caddy")

for server in "${SERVERS[@]}"; do
    dest_dir="wordpress_${server}"
    if [ ! -d "$dest_dir" ]; then
        echo "Creating WordPress directory for $server ($dest_dir)..."
        cp -r wordpress_master "$dest_dir"
    else
        echo "WordPress directory for $server already exists."
    fi

    # Create dedicated wp-config.php
    echo "Creating wp-config.php for $server..."
    cat <<EOF > "$dest_dir/wp-config.php"
<?php
/**
 * The base configuration for WordPress
 */

define( 'DB_NAME', 'wp_${server}' );
define( 'DB_USER', 'wp_user' );
define( 'DB_PASSWORD', 'wp_password' );
define( 'DB_HOST', 'db' );
define( 'DB_CHARSET', 'utf8' );
define( 'DB_COLLATE', '' );

// Enable WordPress page caching
define( 'WP_CACHE', true );

// Authentication Unique Keys and Salts.
define( 'AUTH_KEY',         'put your unique phrase here' );
define( 'SECURE_AUTH_KEY',  'put your unique phrase here' );
define( 'LOGGED_IN_KEY',    'put your unique phrase here' );
define( 'NONCE_KEY',        'put your unique phrase here' );
define( 'AUTH_SALT',        'put your unique phrase here' );
define( 'SECURE_AUTH_SALT', 'put your unique phrase here' );
define( 'LOGGED_IN_SALT',   'put your unique phrase here' );
define( 'NONCE_SALT',       'put your unique phrase here' );

\$table_prefix = 'wp_';

define( 'WP_DEBUG', false );

// If behind a proxy/reverse proxy, detect HTTPS
if (isset(\$_SERVER['HTTP_X_FORWARDED_PROTO']) && \$_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {
    \$_SERVER['HTTPS'] = 'on';
}

if ( ! defined( 'ABSPATH' ) ) {
    define( 'ABSPATH', __DIR__ . '/' );
}

require_once ABSPATH . 'wp-settings.php';
EOF

    # Create dedicated index-uncached.php to bypass all caching plugins/layers
    echo "Creating index-uncached.php for $server..."
    cat <<EOF > "$dest_dir/index-uncached.php"
<?php
/**
 * Uncached WordPress Loader
 * Forces WordPress to load the homepage dynamically without invoking caching plugins.
 */
define('DONOTCACHEPAGE', true);
define('WP_CACHE', false);

// Pretend we are requesting the homepage index.php to prevent 404 redirects
\$_SERVER['SCRIPT_NAME'] = '/index.php';
\$_SERVER['PHP_SELF'] = '/index.php';
\$_SERVER['REQUEST_URI'] = '/';

// Load the normal WordPress index
require_once __DIR__ . '/index.php';
EOF

    # Set permissions
    echo "Setting permissions for $dest_dir..."
    chmod -R 777 "$dest_dir"
done

# Clean up old single wordpress directory if it exists
if [ -d "wordpress" ]; then
    echo "Removing legacy wordpress directory..."
    rm -rf wordpress
fi

echo "Setup complete! Run './setup-wp.sh' after starting containers to install WordPress."
