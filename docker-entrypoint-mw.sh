#!/bin/bash
# Microweber initialization script - runs before Apache starts

echo "Starting Microweber initialization..."

# Ensure storage directories exist and are writable
mkdir -p /var/www/html/storage/framework/{cache,sessions,views}
mkdir -p /var/www/html/storage/logs
mkdir -p /var/www/html/bootstrap/cache
chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache 2>/dev/null || true

# Create .env file with proper Laravel format if it doesn't exist or is missing APP_KEY format
if [ ! -f /var/www/html/.env ] || ! grep -q "^APP_KEY=" /var/www/html/.env; then
    echo "Creating Laravel .env file..."
    cat > /var/www/html/.env << EOF
APP_NAME=Microweber
APP_ENV=${APP_ENV:-production}
APP_KEY=${APP_KEY:-}
APP_DEBUG=${APP_DEBUG:-false}
APP_URL=${APP_URL:-https://localhost}

DB_CONNECTION=mysql
DB_HOST=${DB_HOST:-mariadb}
DB_PORT=${DB_PORT:-3306}
DB_DATABASE=${DB_DATABASE:-${DB_NAME:-laravel}}
DB_USERNAME=${DB_USERNAME:-${DB_USER:-laravel}}
DB_PASSWORD=${DB_PASSWORD:-${DB_PASS:-laravel}}

LOG_CHANNEL=stack
LOG_LEVEL=debug

BROADCAST_DRIVER=log
CACHE_DRIVER=file
FILESYSTEM_DISK=local
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
SESSION_LIFETIME=120
EOF
else
    # Update APP_KEY in existing .env if set in environment
    if [ -n "$APP_KEY" ]; then
        if grep -q "^APP_KEY=" /var/www/html/.env; then
            sed -i "s|^APP_KEY=.*|APP_KEY=${APP_KEY}|" /var/www/html/.env
        else
            echo "APP_KEY=${APP_KEY}" >> /var/www/html/.env
        fi
    fi
fi

echo ".env file created/updated"

# Clear caches (allow failure)
echo "Clearing caches..."
php /var/www/html/artisan config:clear 2>/dev/null || true
php /var/www/html/artisan cache:clear 2>/dev/null || true
php /var/www/html/artisan view:clear 2>/dev/null || true

echo "Microweber initialization complete."
