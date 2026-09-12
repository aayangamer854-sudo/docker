FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    bash \
    ca-certificates \
    curl \
    wget \
    git \
    sudo \
    nano \
    unzip \
    jq \
    gnupg \
    lsb-release \
    software-properties-common \
    apt-transport-https \
    python3 \
    python3-pip \
    python3-venv \
    build-essential \
    ttyd \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 20.x
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get update \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install Docker CLI only
RUN install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
       -o /etc/apt/keyrings/docker.asc \
    && chmod a+r /etc/apt/keyrings/docker.asc \
    && echo \
       "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
       $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
       > /etc/apt/sources.list.d/docker.list \
    && apt-get update \
    && apt-get install -y docker-ce-cli \
    && rm -rf /var/lib/apt/lists/*

# Install cloudflared
RUN mkdir -p --mode=0755 /usr/share/keyrings \
    && curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg \
       -o /usr/share/keyrings/cloudflare-main.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared any main" \
       > /etc/apt/sources.list.d/cloudflared.list \
    && apt-get update \
    && apt-get install -y cloudflared \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root terminal user
RUN useradd -m -s /bin/bash terminal \
    && echo "terminal ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/terminal \
    && chmod 0440 /etc/sudoers.d/terminal

# Working directory
WORKDIR /home/terminal

# Copy startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh \
    && chown terminal:terminal /start.sh /home/terminal

USER terminal

EXPOSE 7681

CMD ["/start.sh"]
