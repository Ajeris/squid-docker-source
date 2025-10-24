Squid 6.12 Docker Container

Optimized Docker container for Squid Proxy Server 6.12 built on Debian 12-slim with SSL bump, LDAP, and Kerberos authentication support.


Features

    Squid 6.12 — stable release with security updates

    SSL Bump — HTTPS interception and inspection

    LDAP Authentication — Active Directory / LDAP integration

    Kerberos Authentication — Single Sign-On (SSO) support

    SNMP Monitoring — proxy monitoring and statistics

    Log Rotation — automatic rotation with compression

    Minimal Image Size — optimized build with unnecessary packages removed

    Timezone Support — configurable (example: Asia/Qyzylorda)

    AD Time Sync — optional time synchronization with Active Directory

Requirements

    Docker Engine 20.10+

    Docker Compose 2.0+ (or docker compose v2)

    Network interface for macvlan (optional, depending on topology)

    Active Directory or LDAP server (for authentication features)

Quick Start
1. Clone repository
git clone <repository-url>
cd <repository-directory>
2. Build and start (first-time build)
# Build and start using the build compose file
docker compose -f docker-compose.build.yml up -d --build

# Or start using pre-built image
docker compose up -d

# Check container status
docker compose ps

# Follow logs
docker compose logs -f
Directory structure (example)
squid_docker/
├── Dockerfile                # Container build configuration
├── docker-compose.yml        # Container orchestration
├── docker-compose.build.yml  # Optional: build-time compose file
├── entrypoint.sh             # Container initialization script
├── setup_project.sh          # Project setup and SSL certificate generation
├── config/                   # Configuration files
│   ├── squid.conf            # Main Squid configuration
│   ├── ssl_cert/             # SSL certificates (CA & keys)
│   └── acl/                  # Access control lists and rules
├── logs/                     # Squid log files (commonly excluded from VCS)
├── cache/                    # Squid cache files (commonly excluded from VCS)
└── README.md                 # This file
Configuration
Main configuration file

The main Squid configuration is located at config/squid.conf. Key points:

    HTTP Proxy Port: 3128 (example) with SSL bump enabled

    SSL Certificate: auto-generated or user-provided certificates for HTTPS inspection

    Authentication: LDAP and Kerberos helpers are supported and configurable

    Access Control: ACLs are used to define who can access the Internet and how

Docker Compose details

    Network: macvlan is supported for direct network access (useful for AD integration); bridge mode also works depending on your network

    Volumes: persistent storage for logs and cache

    Environment variables: timezone and NTP settings can be passed via environment:

    Healthchecks: container-level health monitoring to restart unhealthy containers

Logs

    Access log: /var/log/squid/access.log

    Cache log: /var/log/squid/cache.log

    Log rotation: daily rotation with configurable retention (example: 7 days)

    Ensure logs are accessible to external monitoring tools if required

Advanced usage

You can provide custom configuration or additional helpers by mounting files into the config/ directory or extending the Dockerfile.
# Rebuild after changes
docker compose -f docker-compose.build.yml up -d --build
License

This project is licensed under the MIT License — see the LICENSE file for details.
Contributing

    Fork the repository

    Create a feature branch

    Make your changes

    Test thoroughly

    Submit a pull request

Support / Troubleshooting

    Check the troubleshooting section in this repository (if present)

    Inspect container logs (docker compose logs -f)

    Open an issue on GitHub with detailed information: logs, config snippets, environment
