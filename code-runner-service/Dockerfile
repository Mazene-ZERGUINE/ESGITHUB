FROM ubuntu:latest

# Install required tools and libraries
RUN apt-get update && \
    apt-get install -y nodejs npm python3 python3-pip python3-venv python3-dev  g++ php php-cli php-mbstring php-xml php-gd php-zip php-curl \
    build-essential curl wget git zip unzip libfreetype6-dev libjpeg-dev libssl-dev libffi-dev autoconf automake libtool && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Python block
COPY resources/python/requirements.txt .

RUN python3 -m venv /app/.venv && \
    /app/.venv/bin/pip install numpy --no-build-isolation && \
    /app/.venv/bin/pip install --upgrade pip && \
    /app/.venv/bin/pip install -r requirements.txt

# JS block
COPY resources/javascript/package.json ./resources/javascript/package-lock.json* ./
RUN npm install

# PHP block
COPY resources/php/composer.json /app/resources/php/composer.json
WORKDIR /app/resources/php
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    COMPOSER_ALLOW_SUPERUSER=1 composer install

# Set the default work directory back to /app
WORKDIR /app

# ENV for Node.js modules
ENV PATH="/app/node_modules/.bin:$PATH"
ENV PHP_AUTOLOAD_PATH="/app/resources/php/vendor/autoload.php"

RUN chmod -R 777 /app/resources
RUN mkdir -p /app/temp && chmod -R 777 /app/temp

# Set the default command
CMD ["bash"]