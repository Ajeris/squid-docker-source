#!/bin/bash
set -e

cleanup() {
    echo "Shutting down Squid..."
    if [ -f /var/run/squid/squid.pid ]; then
        /usr/local/squid/sbin/squid -k shutdown 2>/dev/null || true
        sleep 2
    fi
    exit 0
}

trap cleanup TERM INT

# Ensure required directories and base ownerships
mkdir -p /var/cache/squid /var/log/squid /var/run/squid /etc/squid/ssl_cert
chown -R proxy:proxy /var/cache/squid /var/log/squid /var/run/squid 2>/dev/null || true

# Initialize SSL DB if SSL bump is configured in squid.conf
if grep -Eqi "(^|\s)sslcrtd_program|(^|\s)ssl[-_]?bump|generate-host-certificates=on" /etc/squid/squid.conf 2>/dev/null; then
    echo "SSL bump detected, ensuring SSL database exists..."
    SSL_DB_DIR=/var/cache/squid/ssl_db
    if [ ! -f "$SSL_DB_DIR/index.txt" ]; then
        echo "Initializing SSL certificate database at $SSL_DB_DIR ..."
        # security_file_certgen expects to create the target dir itself
        rm -rf "$SSL_DB_DIR" 2>/dev/null || true
        /usr/local/squid/libexec/security_file_certgen -c -s "$SSL_DB_DIR" -M 4MB
        echo "SSL certificate database initialized."
    fi
    chown -R proxy:proxy "$SSL_DB_DIR" || true
fi

# Remove any stale PID file
rm -f /var/run/squid/squid.pid

# Test configuration
echo "Testing Squid configuration..."
if ! /usr/local/squid/sbin/squid -k parse -f /etc/squid/squid.conf; then
    echo "ERROR: Squid configuration is invalid!"
    exit 1
fi

echo "Configuration test passed."

# Initialize cache if configured and not present
if [ ! -d "/var/cache/squid/00" ] && grep -q "^cache_dir" /etc/squid/squid.conf 2>/dev/null; then
    echo "Initializing Squid cache..."
    /usr/local/squid/sbin/squid -z -f /etc/squid/squid.conf
    echo "Cache initialization completed."
fi

# Ensure no lingering PID file
rm -f /var/run/squid/squid.pid

# Start Squid in foreground
echo "Starting Squid in foreground mode..."
exec /usr/local/squid/sbin/squid -f /etc/squid/squid.conf -N "$@"
