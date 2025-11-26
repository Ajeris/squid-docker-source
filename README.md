# Squid 6.12 Docker Container

Optimized Docker container for Squid Proxy Server version 6.12 built on Debian 12-slim with SSL bump, LDAP, and Kerberos authentication support.

[![Docker Build](https://img.shields.io/badge/docker-build-blue.svg)](https://docker.com)
[![Squid Version](https://img.shields.io/badge/squid-6.12-green.svg)](http://www.squid-cache.org/)
[![Debian](https://img.shields.io/badge/debian-12--slim-red.svg)](https://debian.org)

## ✨ Features

- **Squid 6.12** - Latest stable release with security patches
- **SSL Bump** - HTTPS traffic interception and inspection capabilities
- **LDAP Authentication** - Active Directory/LDAP integration for user authentication
- **Kerberos Authentication** - Single Sign-On (SSO) authentication support
- **SNMP Monitoring** - Built-in proxy status monitoring and statistics
- **Log Rotation** - Automatic log rotation with compression
- **Minimal Size** - Optimized build with removed unnecessary dependencies
- **Timezone Support** - Configured for Asia/Qyzylorda timezone
- **AD Time Sync** - Automatic time synchronization with Active Directory

## 📋 Requirements

- Docker Engine 20.10+
- Docker Compose 2.0+
- Network interface for macvlan configuration
- Active Directory server (for authentication)

## 🚀 Quick Start

### 1. Clone Repository

```bash
# Build and start the container (first time setup)
docker compose -f docker-compose.build.yml up -d --build

# OR use pre-built image
docker compose up -d

# Check container status
docker compose ps

# View logs
docker compose logs -f
```

## 📁 Directory Structure

├── Dockerfile # Container build configuration
├── docker-compose.yml # Container orchestration
├── entrypoint.sh # Container initialization script
├── setup_project.sh # Project setup and SSL certificate generation
├── config/ # Configuration files
│ ├── squid.conf # Main Squid configuration
│ ├── ssl_cert/ # SSL certificates
│ └── acl/ # Access control lists
├── logs/ # Squid log files (excluded from git)
├── cache/ # Squid cache

```

## ⚙️ Configuration

### Main Configuration File

The main Squid configuration is located at `config/squid.conf`. Key features:

- **HTTP Port**: 3128 with SSL bump enabled
- **SSL Certificate**: Auto-generated certificates for HTTPS inspection
- **Authentication**: LDAP and Kerberos support
- **Access Control**: Flexible ACL system

### Docker Compose Configuration

- **Macvlan Network**: Direct network access for AD authentication
- **Volume Mounts**: Persistent logs and cache storage
- **Environment Variables**: Timezone and NTP configuration
- **Health Checks**: Automatic container health monitoring

### Log Configuration

- **Access Logs**: `/var/log/squid/access.log`
- **Cache Logs**: `/var/log/squid/cache.log`  
- **Log Rotation**: Daily rotation with 7-day retention
- **External Access**: Logs are readable by external monitoring tools

## 🔧 Advanced Usage

### Custom Configuration

```bash
# Build and start the container (first time setup)
docker compose -f docker-compose.build.yml up -d --build

# OR use pre-built image
docker compose up -d
```

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 💬 Support

For issues and questions:

1. Check the troubleshooting section
2. Review container logs
3. Open an issue on GitHub
4. Provide detailed error information and configuration

---

**Note**: This container is optimized for Active Directory environments and requires proper network configuration for authentication to work correctly.
