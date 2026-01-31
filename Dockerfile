# Menggunakan Node.js v22 (Syarat script install.sh)
FROM node:22-bookworm-slim

# Metadata
LABEL maintainer="Chairul Anam <ceo@acodemy.id>"
LABEL description="OpenClaw Isolated Container"

# 1. Install System Dependencies
# Chromium: Agar bot tidak perlu download chrome sendiri (hemat RAM/Storage)
# Procps: Untuk monitoring process
# Dumb-init: Process manager agar container bisa distop dengan graceful
RUN apt-get update && apt-get install -y \
    chromium \
    git \
    curl \
    wget \
    python3 \
    python3-pip \
    dumb-init \
    procps \
    ca-certificates \
    libnss3 \
    libatk-bridge2.0-0 \
    libx11-xcb1 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    libgbm1 \
    libasound2 \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# 2. Setup Security: User 'openclaw' (Non-Root)
RUN groupadd -r openclaw && useradd -r -g openclaw -G audio,video -m -d /home/openclaw openclaw

# 3. Environment Variables Kunci
ENV NODE_ENV=production
# Config Puppeteer agar pakai Chromium sistem
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium
# Config Install Script (Silent Mode / Non-Interactive)
ENV OPENCLAW_NO_ONBOARD=1
ENV OPENCLAW_NO_PROMPT=1
ENV OPENCLAW_INSTALL_METHOD=npm
# Path agar binary bisa dipanggil global
ENV PATH="/home/openclaw/.npm-global/bin:${PATH}"

# 4. Switch User & Directory
USER openclaw
WORKDIR /home/openclaw

# 5. Jalankan Install Script Resmi (via Pipe)
# Script ini akan menginstall OpenClaw ke folder user
RUN curl -fsSL --proto '=https' --tlsv1.2 https://openclaw.ai/install.sh | bash

# 6. Buat Folder Config untuk Persistensi
# Folder ini nanti akan kita mount ke Volume Dokploy
RUN mkdir -p /home/openclaw/.openclaw

# 7. Expose Port
# Port default dashboard/webhook OpenClaw biasanya 3000
EXPOSE 3000

# 8. Entrypoint
# Menggunakan dumb-init untuk menangani PID 1
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

# Command default: Menjalankan daemon
CMD ["openclaw", "daemon"]
