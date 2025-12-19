# ================================
# Minecraft Bedrock Server Dockerfile
# ================================
FROM ubuntu:24.04 AS base

# Labels for better metadata
LABEL author="Nathan Snow"
LABEL description="Minecraft Bedrock Edition server running in Docker"
LABEL version="2.0"
LABEL maintainer="Nathan Snow"
LABEL org.opencontainers.image.source="https://github.com/japtain-cack/bedrock-server"

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV LD_LIBRARY_PATH=.
ENV PYTHONUNBUFFERED=1
ENV NODE_ENV=production

# Arguments for build-time configuration
ARG BEDROCK_VERSION=""
ENV BEDROCK_VERSION=${BEDROCK_VERSION}
ARG UID=10001
ARG GID=10001
ENV UID=${UID}
ENV GID=${GID}

# ================================
# Dependency Installation Stage
# ================================
FROM base AS deps

# Enable additional Ubuntu repositories for GUI libraries
RUN apt-get update && apt-get install -y software-properties-common && \
    add-apt-repository universe && \
    add-apt-repository restricted && \
    add-apt-repository multiverse && \
    rm -rf /var/lib/apt/lists/*

# Install system dependencies and clean up in single layer
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    wget \
    unzip \
    python3.12 \
    python3-pip \
    pipx \
    gnupg \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install Chrome dependencies for Puppeteer (required for version detection)
# Install Google Chrome from official repository
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends google-chrome-stable && \
    rm -rf /var/lib/apt/lists/*

# Install Node.js 20.x LTS (more stable than 24.x for server environments)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm@latest

# ================================
# Application Setup Stage
# ================================
FROM deps AS app

# Create non-root user
RUN groupadd -g ${GID} minecraft && \
    useradd -s /bin/bash -d /app -m -u ${UID} -g minecraft minecraft

# Set working directory
WORKDIR /app

# Copy package files first for better layer caching
COPY --chown=${UID}:${GID} package*.json ./

# Install Node.js dependencies
RUN npm ci --only=production && npm cache clean --force

# Install EnvForge for configuration templating from GitLab
RUN pipx install envforge --index-url https://gitlab.com/api/v4/projects/77183458/packages/pypi/simple

# ================================
# Runtime Stage (Final Image)
# ================================
FROM deps AS runtime

# Copy user and group from app stage
COPY --from=app /etc/group /etc/group
COPY --from=app /etc/passwd /etc/passwd
COPY --from=app /etc/shadow /etc/shadow

# Copy application files
COPY --from=app --chown=${UID}:${GID} /app /app

# Create data directory and set permissions
RUN mkdir -p /app/data && \
    chown -R ${UID}:${GID} /app

# Copy application files
COPY --chown=${UID}:${GID} files/get_version.js /app/
COPY --chown=${UID}:${GID} files/entrypoint.sh /app/
COPY --chown=${UID}:${GID} templates/ /app/templates/

# Make scripts executable
RUN chmod +x /app/entrypoint.sh

# Pre-render configuration templates (will be overridden at runtime if needed)
USER ${UID}:${GID}
WORKDIR /app/data
RUN envforge render -c /app/templates/envforge.yaml || true

# Expose Minecraft Bedrock ports
EXPOSE 19132/tcp 19132/udp 19133/tcp 19133/udp

# Add health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD pgrep bedrock_server || exit 1

# Define volumes
VOLUME ["/app/data"]

# Set entrypoint
ENTRYPOINT ["/app/entrypoint.sh"]
