# Squid 6.12 Docker Container

Optimized Docker container for Squid Proxy Server v6.12 based on Debian
12-slim with SSL Bump, LDAP, and Kerberos authentication support.

[![Docker
Build](https://img.shields.io/badge/docker-build-blue.svg)](https://docker.com)
[![Squid
Version](https://img.shields.io/badge/squid-6.12-green.svg)](http://www.squid-cache.org/)
[![Debian](https://img.shields.io/badge/debian-12--slim-red.svg)](https://debian.org)

## Features

-   Squid 6.12 --- Latest stable release with security updates
-   SSL Bump --- HTTPS traffic interception and inspection
-   LDAP Authentication --- Integration with Active Directory / LDAP
-   Kerberos Authentication --- SSO (Single Sign-On) support
-   SNMP Monitoring --- Proxy status and statistics monitoring
-   Log Rotation --- Automatic log rotation with compression
-   Minimal Image Size --- Optimized build with unnecessary packages
    removed
-   Timezone Support --- Configured for Asia/Qyzylorda
-   AD Time Sync --- Automatic time synchronization with Active
    Directory

## Requirements

-   Docker Engine 20.10+
-   Docker Compose 2.0+
-   Network with macvlan support
-   Active Directory server

## Quick Start

### Clone repository

\`\`\`bash git clone `<repo-url>`{=html} cd `<repo-dir>`{=html} \`\`\`

### Build and start

\`\`\`bash docker compose -f docker-compose.build.yml up -d --build \#
or docker compose up -d \`\`\`

### Logs

\`\`\`bash docker compose logs -f \`\`\`

## Directory Structure

\`\`\` squid_docker/ ├── Dockerfile ├── docker-compose.yml ├──
docker-compose.build.yml ├── entrypoint.sh ├── setup_project.sh ├──
structure_setup.sh ├── config/ │ ├── squid.conf │ ├── ssl_cert/ │ └──
acl/ ├── logs/ ├── cache/ └── README.md \`\`\`

## Configuration

### Main config: config/squid.conf

-   Port 3128 with SSL Bump
-   SSL certificates
-   LDAP + Kerberos authentication
-   ACL rules

### Compose configuration

-   Macvlan network
-   Persistent logs & cache
-   Timezone & NTP
-   Health checks

### Logs

-   /var/log/squid/access.log
-   /var/log/squid/cache.log

## License

MIT License

## Contributing

1.  Fork repo
2.  Create feature branch
3.  Commit changes
4.  Test
5.  PR

## Support

-   Check troubleshooting
-   docker compose logs
-   Open GitHub issue
