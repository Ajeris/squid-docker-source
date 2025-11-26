Squid 6.12 Docker Container

Optimized Docker container for Squid Proxy Server v6.12 based on Debian 12-slim with SSL Bump, LDAP, and Kerberos authentication support.

Docker Build badge: https://img.shields.io/badge/docker-build-blue.svg


Squid Version badge: https://img.shields.io/badge/squid-6.12-green.svg

Debian badge: https://img.shields.io/badge/debian-12--slim-red.svg

Features:

Squid 6.12 — Latest stable release with security updates

SSL Bump — HTTPS traffic interception and inspection

LDAP Authentication — Integration with Active Directory / LDAP

Kerberos Authentication — SSO (Single Sign-On) support

SNMP Monitoring — Proxy status and statistics monitoring

Log Rotation — Automatic log rotation with compression

Minimal Image Size — Optimized build with unnecessary packages removed

Timezone Support — Configured for Asia/Qyzylorda

AD Time Sync — Automatic time synchronization with Active Directory

Requirements:

Docker Engine 20.10+

Docker Compose 2.0+

Network with macvlan support

Active Directory server (for authentication)

Quick Start:

Clone the repository:
git clone <repo-url>
cd <repo-dir>

Build and start (first-time setup):
docker compose -f docker-compose.build.yml up -d --build

Or start using pre-built image:
docker compose up -d

Check container status:
docker compose ps

View logs:
docker compose logs -f

Directory Structure:

squid_docker/
├── Dockerfile — Container build configuration
├── docker-compose.yml — Container orchestration
├── docker-compose.build.yml — Build/CI configuration (optional)
├── entrypoint.sh — Container initialization script
├── setup_project.sh — Project setup and SSL certificate generation
├── structure_setup.sh — Directory structure creation script (optional)
├── config/ — Configuration files
│ ├── squid.conf — Main Squid configuration
│ ├── ssl_cert/ — SSL certificates
│ └── acl/ — Access control lists
├── logs/ — Squid log files (excluded from git)
├── cache/ — Squid cache (excluded from git)
└── README.md — This file

Configuration:

Main configuration file: config/squid.conf

Includes:

HTTP port (default 3128) with SSL Bump

SSL certificates (auto-generated if needed)

LDAP and Kerberos authentication

ACL rules for access control

Docker Compose configuration:

Macvlan network for direct AD connectivity

Persistent storage for logs and cache

Environment variables for timezone and NTP configuration

Health checks for container monitoring

Logging paths:
Access log: /var/log/squid/access.log
Cache log: /var/log/squid/cache.log
Daily log rotation enabled
Logs can be accessed by external monitoring tools

Advanced Usage:

Rebuild the container:
docker compose -f docker-compose.build.yml up -d --build
or
docker compose up -d

Customize configuration:

Edit config/squid.conf

Place SSL certificates in config/ssl_cert/

Modify macvlan settings for AD/Kerberos

License:
This project is licensed under the MIT License.

Contributing:

Fork the repository

Create a feature branch

Make your changes

Test locally

Submit a pull request

Support:

Check troubleshooting documentation

Review logs using "docker compose logs"

Open an issue on GitHub

Provide error details, logs, and configuration if reporting a problem

Note:
This container is optimized for Active Directory environments and requires correct network settings for authentication to function properly.
---

**Note**: This container is optimized for Active Directory environments and requires proper network configuration for authentication to work correctly.
