#!/bin/bash

# Unified setup script for Squid Docker container
# Combines directory setup and SSL certificate generation
# Creates all necessary project structure with proper permissions

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

# Configuration variables
SSL_DIR="${SSL_DIR:-${SCRIPT_DIR}/config/ssl_cert}"
CA_KEY="${CA_KEY:-$SSL_DIR/squid_ca.key}"
CA_CRT="${CA_CRT:-$SSL_DIR/squid_ca.crt}"
CA_SUBJECT="${CA_SUBJECT:-/CN=proxy-4.tp.oil/O=Squid Qzld/C=KZ}"
KEY_SIZE="${KEY_SIZE:-4096}"
CERT_DAYS="${CERT_DAYS:-3650}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_info "Setting up Squid Docker project structure..."

# Function to create directories
create_directories() {
    print_info "Creating project directories..."
    
    # Essential directories only (removed auth and certs as they're not used)
    local dirs=(
        "${SCRIPT_DIR}/config"
        "${SCRIPT_DIR}/config/ssl_cert"  
        "${SCRIPT_DIR}/config/acl"
        "${SCRIPT_DIR}/logs"
        "${SCRIPT_DIR}/cache"
    )
    
    for dir in "${dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
            print_info "Created: $dir"
        else
            print_info "Already exists: $dir"
        fi
    done
}

# Function to set permissions
set_permissions() {
    print_info "Setting directory permissions..."
    
    # Set permissions for logs directory (readable by external programs)
    if [ -d "${SCRIPT_DIR}/logs" ]; then
        chmod 755 "${SCRIPT_DIR}/logs"
        chown 13:13 "${SCRIPT_DIR}/logs" 2>/dev/null || print_warning "Could not set owner for logs directory (run as root if needed)"
        print_success "Logs directory permissions set"
    fi
    
    # Set permissions for cache directory
    if [ -d "${SCRIPT_DIR}/cache" ]; then
        chmod 755 "${SCRIPT_DIR}/cache"
        chown 13:13 "${SCRIPT_DIR}/cache" 2>/dev/null || print_warning "Could not set owner for cache directory (run as root if needed)"
        print_success "Cache directory permissions set"
    fi
    
    # Set permissions for SSL certificate directory
    if [ -d "$SSL_DIR" ]; then
        chmod 755 "$SSL_DIR"
        chmod 644 "$SSL_DIR"/* 2>/dev/null || true
        print_success "SSL certificate directory permissions set"
    fi
    
    # Set permissions for ACL directory
    if [ -d "${SCRIPT_DIR}/config/acl" ]; then
        chmod 755 "${SCRIPT_DIR}/config/acl"
        chmod 644 "${SCRIPT_DIR}/config/acl"/* 2>/dev/null || true
        print_success "ACL directory permissions set"
    fi
    
    # Set permissions for configuration files
    chmod 644 "${SCRIPT_DIR}/config"/*.conf 2>/dev/null || true
    print_success "Configuration files permissions set"
}

# Function to create .gitkeep files
create_gitkeep() {
    print_info "Creating .gitkeep files for empty directories..."
    
    touch "${SCRIPT_DIR}/logs/.gitkeep"
    touch "${SCRIPT_DIR}/cache/.gitkeep"
    
    print_success ".gitkeep files created"
}

# Function to generate SSL certificates
generate_ssl_cert() {
    print_info "Checking SSL certificate setup..."
    
    # Check if OpenSSL is available
    if ! command -v openssl &> /dev/null; then
        print_error "OpenSSL is not installed or not in PATH"
        exit 1
    fi
    
    if [ ! -f "$CA_KEY" ] || [ ! -f "$CA_CRT" ]; then
        print_info "Generating new SSL certificate..."
        print_info "  Key size: $KEY_SIZE bits"
        print_info "  Validity: $CERT_DAYS days"  
        print_info "  Subject: $CA_SUBJECT"
        
        # Generate private key
        openssl genrsa -out "$CA_KEY" $KEY_SIZE
        
        # Generate self-signed certificate
        openssl req -new -x509 -days $CERT_DAYS \
            -key "$CA_KEY" \
            -out "$CA_CRT" \
            -subj "$CA_SUBJECT"
        
        # Set correct permissions
        chmod 600 "$CA_KEY"
        chmod 644 "$CA_CRT"
        
        print_success "SSL certificate generated:"
        print_info "  Private key: $CA_KEY"
        print_info "  Certificate: $CA_CRT"
        
        # Show certificate info
        echo ""
        print_info "Certificate details:"
        openssl x509 -in "$CA_CRT" -text -noout | grep -E "(Subject|Issuer|Not Before|Not After)" | sed 's/^/  /'
        
        echo ""
        print_warning "IMPORTANT: Install $CA_CRT as trusted CA in browsers to avoid SSL warnings"
        
    else
        print_success "SSL certificate already exists:"
        print_info "  Private key: $CA_KEY"
        print_info "  Certificate: $CA_CRT"
        
        # Check expiration
        if openssl x509 -checkend 86400 -noout -in "$CA_CRT" >/dev/null; then
            print_success "Certificate is valid"
        else
            print_warning "Certificate is expiring soon or expired!"
        fi
    fi
    
    # Show certificate fingerprint
    echo ""
    print_info "Certificate fingerprint (SHA256):"
    openssl x509 -noout -fingerprint -sha256 -in "$CA_CRT" | sed 's/.*=/  /'
}

# Function to clean up unused directories  
cleanup_unused() {
    print_info "Cleaning up unused directories..."
    
    # Remove auth and certs directories if they exist and are empty
    local unused_dirs=("${SCRIPT_DIR}/config/auth" "${SCRIPT_DIR}/config/certs")
    
    for dir in "${unused_dirs[@]}"; do
        if [ -d "$dir" ]; then
            if [ -z "$(ls -A "$dir")" ]; then
                rmdir "$dir"
                print_info "Removed empty unused directory: $dir"
            else
                print_warning "Directory $dir is not empty, skipping removal"
            fi
        fi
    done
}

# Main execution
main() {
    echo "=================================================="
    echo "    Squid Docker Project Setup Script v2.0"
    echo "=================================================="
    echo ""
    
    create_directories
    echo ""
    
    set_permissions  
    echo ""
    
    create_gitkeep
    echo ""
    
    generate_ssl_cert
    echo ""
    
    cleanup_unused
    echo ""
    
    print_success "Project setup completed successfully!"
    echo ""
    echo "Directory structure:"
    echo "  - ${SCRIPT_DIR}/config          (Configuration files)"
    echo "  - ${SCRIPT_DIR}/config/ssl_cert (SSL certificates)"
    echo "  - ${SCRIPT_DIR}/config/acl      (Access control lists)"  
    echo "  - ${SCRIPT_DIR}/logs            (Squid log files - readable by external programs)"
    echo "  - ${SCRIPT_DIR}/cache           (Squid cache files - readable by external programs)"
    echo ""
    echo "Next steps:"
    echo "  1. Review configuration files in config/ directory"
    echo "  2. Start container: docker compose up -d"
    echo "  3. Check logs: docker compose logs -f"
    echo ""
}

# Run main function
main "$@"
