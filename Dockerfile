FROM node:20-slim

# Install Python, pip, Chromium, and locale
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    make \
    git \
    chromium \
    locales \
    && rm -rf /var/lib/apt/lists/* \
    && sed -i '/ja_JP.UTF-8/s/^# //g' /etc/locale.gen \
    && locale-gen

# Set Japanese locale
ENV LANG=ja_JP.UTF-8
ENV LC_ALL=ja_JP.UTF-8

# Set Chromium path for vivliostyle
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

# Install vivliostyle CLI
RUN npm install -g @vivliostyle/cli

# Install pandoc-embedz (from git for latest features)
RUN pip install --break-system-packages git+https://github.com/tecolicom/pandoc-embedz.git

WORKDIR /app

# Copy template, styles, and assets
COPY nenga.emz Makefile Makefile.local ./
COPY style*.css ./
COPY hagaki-bg.svg grid.svg sample.csv ./
COPY entrypoint.sh ./
RUN chmod +x /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]
CMD []
