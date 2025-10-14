##############################################
# STAGE 1: BUILD SQUID FROM SOURCE
##############################################
FROM debian:12-slim AS builder

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
        libsasl2-modules-gssapi-mit \
        ldap-utils \
        build-essential \
        wget && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /tmp/build

# Download and extract Squid source
RUN SQUID_TAG=$(echo "$SQUID_VER" | tr "." "_") && \
    curl -fSsL "https://github.com/squid-cache/squid/releases/download/SQUID_$SQUID_TAG/squid-${SQUID_VER}.tar.gz" -o squid.tar.gz && \
    tar --strip 1 -xzf squid.tar.gz

# Configure and build Squid with SSL, LDAP, and Kerberos support
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


##############################################
# STAGE 2: RUNTIME IMAGE
##############################################
FROM debian:12-slim

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Qyzylorda
ENV PATH="/usr/local/squid/sbin:/usr/local/squid/bin:$PATH"

# Install runtime dependencies (include SASL + LDAP)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libssl3 \
        libldap-2.5-0 \
        libkrb5-3 \
        libgssapi-krb5-2 \
        libk5crypto3 \
        libkrb5support0 \
        libsasl2-2 \
        libsasl2-modules-gssapi-mit \
        ldap-utils \
        ca-certificates \
        tzdata && \
    rm -rf /var/lib/apt/lists/*

# Set timezone
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Create required directories
RUN mkdir -p /var/cache/squid /var/log/squid /var/run/squid /etc/squid/ssl_cert && \
    chown -R proxy:proxy /var/cache/squid /var/log/squid /var/run/squid

# Copy built Squid binaries and configs
COPY --from=builder /usr/local/squid/ /usr/local/squid/
COPY --from=builder /etc/squid/ /etc/squid/

# Verify SASL GSSAPI module presence (diagnostic)
RUN ls -l /usr/lib/x86_64-linux-gnu/sasl2/libgssapiv2.so || echo "❌ SASL GSSAPI module not found"

# Copy and enable entrypoint
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose Squid port
EXPOSE 3128

# Set entrypoint and command
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["squid", "-f", "/etc/squid/squid.conf", "-N"]
