# Menggunakan Node.js v22 (Syarat script install.sh)
FROM node:22-bookworm-slim

# Metadata
LABEL maintainer="Chairul Anam <anam@acodemy.id>"
LABEL description="OpenClaw Isolated Container (Custom Fork)"

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
    nano \
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

# --- KONFIGURASI INSTALLER ---
# Silent Mode / Non-Interactive
ENV OPENCLAW_NO_ONBOARD=1
ENV OPENCLAW_NO_PROMPT=1

# ⚠️ PERHATIAN: Pastikan script install.sh di repo Anda mendukung metode ini.
# Jika Anda ingin install source code fork, biasanya metode 'npm' akan menarik dari registry publik (bukan fork).
# Jika script Anda sudah dimodif untuk pull dari git, variabel ini mungkin diabaikan atau perlu disesuaikan.
ENV OPENCLAW_INSTALL_METHOD=npm

# Path agar binary bisa dipanggil global
ENV PATH="/home/openclaw/.npm-global/bin:${PATH}"

# 4. Switch User & Directory
USER openclaw
WORKDIR /home/openclaw

# 5. Jalankan Install Script Custom (Fork)
# Menggunakan URL raw dari repo Acodemy-id
RUN curl -fsSL --proto '=https' --tlsv1.2 https://raw.githubusercontent.com/Acodemy-id/openclaw/refs/heads/main/install.sh | bash

# 6. Buat Folder Config untuk Persistensi
RUN mkdir -p /home/openclaw/.openclaw

# 7. Expose Port
# Port Gateway OpenClaw
EXPOSE 18789

# 8. Entrypoint (Tetap gunakan dumb-init)
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

# 9. Command Final
# Menjalankan gateway secara langsung
# CMD ["tail", "-f", "/dev/null"]

CMD ["openclaw", "gateway", "run", "--bind", "lan", "--port", "18789"]
