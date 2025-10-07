# Quick Start Guide

## Prerequisites
- Docker Engine 20.10+
- Docker Compose 2.0+

## Setup (30 seconds)

1. **Setup project structure**
   ```bash
   ./setup_project.sh
   ```

2. **Configure network** (edit docker-compose.yml)
   - Change `parent: eth0` to your network interface
   - Adjust IP addresses for your network

3. **Start container**
   ```bash
   docker compose up -d
   ```

4. **Check status**
   ```bash
   docker compose ps
   docker compose logs -f
   ```

## Usage

- **Proxy URL**: `http://192.168.10.22:3128`
- **SSL Certificate**: `config/ssl_cert/squid_ca.crt` (install in browsers)

## Common Commands

```bash
# View logs
docker compose logs -f

# Restart container
docker compose restart

# Stop container
docker compose down

# Update configuration
nano config/squid.conf
docker compose restart
```

See [README.md](README.md) for detailed documentation.
