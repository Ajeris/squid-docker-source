FROM debian:12-slim as builder

ARG SQUID_VER=6.13
ARG DEBIAN_FRONTEND=noninteractive

# Install build dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        gcc \
        g++ \
        make \
        curl \
        ca-certificates \
        libssl-dev \
        libldap2-dev \
        libkrb5-dev \
        libsasl2-dev \
        build-essential \
        wget && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /tmp/build

# Download and extract Squid source code
RUN SQUID_TAG=$(echo "$SQUID_VER" | tr "." "_") && \
    curl -fSsL "https://github.com/squid-cache/squid/releases/download/SQUID_$SQUID_TAG/squid-${SQUID_VER}.tar.gz" -o squid.tar.gz && \
    tar --strip 1 -xzf squid.tar.gz

# Configure and build Squid with SSL bump, LDAP, and Kerberos support
RUN CFLAGS="-O2 -g0" CXXFLAGS="-O2 -g0" LDFLAGS="-s" \
    ./configure \
        --prefix=/usr/local/squid \
        --sysconfdir=/etc/squid \
        --localstatedir=/var \
        --with-logdir=/var/log/squid \
        --with-pidfile=/var/run/squid/squid.pid \
        --with-default-user=proxy \
        --with-openssl \
        --with-ldap \
        --enable-ssl-crtd \
        --enable-snmp \
        --enable-auth-basic="LDAP" \
        --enable-auth-negotiate="kerberos" \
        --enable-external-acl-helpers="LDAP_group,kerberos_ldap_group" \
        --disable-auth-digest \
        --disable-auth-ntlm \
        --disable-htcp \
        --disable-ident-lookups \
        --disable-dependency-tracking && \
    make -j$(nproc) && \
    make install

# Final production image
FROM debian:12-slim

ARG DEBIAN_FRONTEND=noninteractive

# Install ONLY runtime dependencies (?????????????????????? ???????????????? ???????????????????? ?????????? 4)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libssl3 \
        libldap-2.5-0 \
        libkrb5-3 \
        libgssapi-krb5-2 \
        libk5crypto3 \
        libkrb5support0 \
        libsasl2-2 \
        ca-certificates \
        tzdata && \
    rm -rf /var/lib/apt/lists/*

# Set timezone to Asia/Qyzylorda as specified in technical requirements
ENV TZ=Asia/Qyzylorda
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Create necessary directories with proper permissions
RUN mkdir -p /var/cache/squid /var/log/squid /var/run/squid /etc/squid /etc/squid/ssl_cert && \
    chown -R proxy:proxy /var/cache/squid /var/log/squid /var/run/squid

# Copy Squid binaries and configuration from builder stage
COPY --from=builder /usr/local/squid/ /usr/local/squid/
COPY --from=builder /etc/squid/ /etc/squid/

# Set proper permissions
RUN chown -R root:root /usr/local/squid/ && \
    chmod +x /usr/local/squid/sbin/squid

# Add entrypoint script for time synchronization and initialization
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose Squid port
EXPOSE 3128

# Use custom entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/usr/local/squid/sbin/squid", "-f", "/etc/squid/squid.conf", "-N"]
