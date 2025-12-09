#!/bin/bash
set -e

# Create .env if it doesn't exist
if [ ! -f /var/www/html/.env ]; then
    echo "Creating .env file..."
    if [ -f /var/www/html/.env.example ]; then
        cp /var/www/html/.env.example /var/www/html/.env
    else
        cat > /var/www/html/.env << 'EOF'
APP_NAME=Microweber
APP_ENV=production
APP_DEBUG=false
APP_URL=${APP_URL:-https://localhost}

DB_CONNECTION=mysql
DB_HOST=${DB_HOST:-mariadb}
DB_PORT=${DB_PORT:-3306}
DB_DATABASE=${DB_NAME:-laravel}
DB_USERNAME=${DB_USER:-laravel}
DB_PASSWORD=${DB_PASS:-laravel}
EOF
    fi
fi

# Generate APP_KEY if not set
if ! grep -q "APP_KEY=base64:" /var/www/html/.env 2>/dev/null; then
    echo "Generating APP_KEY..."
    php /var/www/html/artisan key:generate --force || true
fi

# Ensure directories exist with proper permissions
mkdir -p /var/www/html/storage/framework/{cache,sessions,views}
mkdir -p /var/www/html/storage/logs
mkdir -p /var/www/html/bootstrap/cache

# Clear caches
php /var/www/html/artisan config:clear 2>/dev/null || true
php /var/www/html/artisan cache:clear 2>/dev/null || true

echo "Microweber initialization complete."

# Execute the original entrypoint
exec /usr/local/bin/docker-entrypoint.sh "$@"
