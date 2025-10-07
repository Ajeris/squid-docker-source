# WARP.md - AI Agent Project Context

## Project Overview

This is a **Squid 6.12 Docker Container** project designed to provide a production-ready, enterprise-grade proxy server solution with advanced security and authentication features. The project creates a minimal, optimized Docker container based on Debian 12-slim for deployment in Active Directory environments.

## Core Architecture

### Container Components

1. **Base Image**: `debian:12-slim`
   - Minimalist Debian distribution for reduced attack surface
   - Optimized for container environments
   - Small footprint while maintaining functionality

2. **Squid Proxy Server 6.12**
   - Built from source code for maximum optimization
   - Compiled with specific feature flags for security and authentication
   - Custom configuration for enterprise environments

3. **Authentication Stack**
   - **LDAP Integration**: Direct Active Directory authentication
   - **Kerberos Support**: Single Sign-On (SSO) capabilities
   - **SSL/TLS**: HTTPS traffic inspection via SSL bump

### Key Features

- **SSL Bump Technology**: Intercepts and inspects HTTPS traffic
- **Active Directory Integration**: Seamless user authentication
- **Log Management**: Automated rotation and external access
- **Network Optimization**: Macvlan for direct network access
- **Time Synchronization**: NTP integration with domain controllers
- **Health Monitoring**: Built-in health checks and SNMP support

## Technical Implementation

### Build Process

The container uses a **multi-stage build**:

1. **Builder Stage**: 
   - Downloads Squid 6.12 source code
   - Compiles with security and authentication features
   - Removes build artifacts

2. **Runtime Stage**:
   - Copies only necessary binaries
   - Installs runtime dependencies
   - Configures timezone and logging

### Configuration Management

- **Main Config**: `config/squid.conf` - Primary proxy configuration
- **SSL Certificates**: `config/ssl_cert/` - TLS certificates for HTTPS inspection
- **Access Control**: `config/acl/` - Domain-based filtering rules
- **Authentication**: LDAP and Kerberos configuration

### Directory Structure

```
squid_docker/
????????? Dockerfile                 # Multi-stage container build
????????? docker-compose.yml         # Orchestration with macvlan network
????????? entrypoint.sh             # Container initialization script
????????? setup_project.sh      # Host directory preparation
????????? setup_project.sh      # SSL certificate generation
????????? config/                   # Configuration files
???   ????????? squid.conf            # Main Squid configuration
???   ????????? ssl_cert/             # SSL/TLS certificates
???   ????????? acl/                  # Access control lists
????????? logs/                     # Runtime logs (git-ignored)
????????? cache/                    # Proxy cache (git-ignored)
????????? README.md                 # User documentation
```

## Security Implementation

### SSL/TLS Handling

- **Certificate Authority**: Self-signed CA for HTTPS inspection
- **Dynamic Certificates**: Generated on-demand for visited sites
- **SSL Bump**: Transparent HTTPS proxy with certificate replacement
- **Certificate Storage**: Persistent certificate database

### Access Control

- **Network ACLs**: IP-based access restrictions
- **Domain Filtering**: Allow/block lists for web content
- **Authentication Required**: User-based access control
- **Time-based Rules**: Access scheduling capabilities

### Authentication Flow

1. **Client Connection**: User connects to proxy (port 3128)
2. **Authentication Challenge**: LDAP/Kerberos credential request
3. **Directory Lookup**: Query Active Directory for user validation
4. **Access Decision**: Apply ACLs based on user/group membership
5. **Traffic Processing**: Filter and log allowed requests

## Network Architecture

### Macvlan Configuration

- **Direct Network Access**: Container gets IP on host network
- **No Port Forwarding**: Direct communication with clients
- **AD Communication**: Unobstructed access to domain controllers
- **IP Assignment**: Static IP configuration (192.168.10.22)

### Service Discovery

- **DNS Resolution**: Uses host DNS configuration
- **AD Discovery**: Automatic domain controller location
- **Time Services**: NTP synchronization with domain controllers
- **Health Checks**: Built-in service monitoring

## Operational Features

### Log Management

- **Access Logs**: Detailed request/response logging
- **Cache Logs**: Performance and cache hit statistics
- **Error Logs**: Debugging and troubleshooting information
- **Log Rotation**: Daily rotation with compression (7-day retention)
- **External Access**: Logs readable by monitoring systems

### Performance Optimization

- **Cache Configuration**: Intelligent caching algorithms
- **Memory Management**: Optimized memory usage
- **Connection Pooling**: Efficient connection handling
- **Resource Limits**: Configurable CPU/memory constraints

### Monitoring Integration

- **Health Checks**: Docker health monitoring
- **SNMP Support**: Network management system integration
- **Metrics Export**: Performance statistics
- **Alert Integration**: Error condition notifications

## Deployment Scenarios

### Enterprise Environment

- **Domain Integration**: Part of Windows Active Directory
- **User Authentication**: SSO with domain credentials
- **Content Filtering**: Corporate policy enforcement
- **Traffic Monitoring**: Security and compliance logging

### Development/Testing

- **Local Testing**: Development environment proxy
- **SSL Debugging**: HTTPS traffic analysis
- **API Testing**: Web service development support
- **Network Simulation**: Various network condition testing

## Maintenance Operations

### Regular Tasks

1. **Certificate Rotation**: Update SSL certificates
2. **Log Analysis**: Monitor access patterns and errors
3. **Performance Tuning**: Adjust cache and memory settings
4. **Security Updates**: Update base image and dependencies
5. **Configuration Changes**: Modify ACLs and authentication

### Troubleshooting Areas

- **Authentication Issues**: LDAP/Kerberos connectivity problems
- **SSL Problems**: Certificate validation failures
- **Network Connectivity**: Macvlan configuration issues
- **Performance Issues**: Cache efficiency and memory usage
- **Configuration Errors**: Squid syntax and logic problems

## Integration Points

### External Systems

- **Active Directory**: User authentication and group membership
- **DNS Servers**: Name resolution and service discovery  
- **NTP Servers**: Time synchronization for security protocols
- **Monitoring Systems**: Health checks and performance metrics
- **Log Aggregation**: Centralized logging and analysis

### Container Ecosystem

- **Docker Engine**: Container runtime environment
- **Docker Compose**: Multi-container orchestration
- **Volume Management**: Persistent data storage
- **Network Configuration**: Macvlan and bridge networking
- **Registry Integration**: Container image management

## Technical Specifications

### Resource Requirements

- **CPU**: Minimum 0.25 cores, recommended 1+ cores
- **Memory**: Minimum 256MB, recommended 1GB+
- **Storage**: 10GB+ for cache and logs
- **Network**: Direct network access via macvlan

### Supported Protocols

- **HTTP/1.1**: Standard web traffic
- **HTTPS/TLS**: Encrypted web traffic with SSL bump
- **SNMP v1/v2c**: Monitoring protocol support
- **LDAP v3**: Directory service authentication
- **Kerberos v5**: Single sign-on authentication

This project represents a production-ready solution for organizations requiring advanced proxy capabilities with enterprise authentication and security features.
