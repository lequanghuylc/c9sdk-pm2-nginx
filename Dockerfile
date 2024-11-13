# Use the official Ubuntu 22.04 LTS base image
FROM ubuntu:22.04

# Install nginx
RUN apt-get update && \
  apt-get install -y nginx

# Remove the default nginx configuration
RUN rm /etc/nginx/sites-enabled/default

# Optional: Add a custom nginx configuration file
# You can create a file named 'nginx.conf' and add it to the container
COPY ./nginx/project.conf.template /etc/nginx/sites-enabled/

RUN apt-get update && apt-get install -y -q --no-install-recommends \
  apt-transport-https \
  build-essential \
  ca-certificates \
  curl \
  git \
  libssl-dev \
  wget \
  && rm -rf /var/lib/apt/lists/*
RUN apt-get update
RUN apt-get install -y vim nano

RUN apt-get update \
  && apt-get install -y gnupg \
  && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
  && apt-get update \
  && apt-get install -y google-chrome-stable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf libxss1 \
  --no-install-recommends \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /root

RUN git clone https://github.com/c9/core.git c9sdk

WORKDIR /root/c9sdk

ARG PYTHON_VERSION=2.7.5
RUN apt-get update \
  && apt-get install -y wget gcc make openssl libffi-dev libgdbm-dev libsqlite3-dev libssl-dev zlib1g-dev \
  && apt-get clean

WORKDIR /tmp/
# Build Python from source
RUN wget https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tgz \
  && tar --extract -f Python-$PYTHON_VERSION.tgz \
  && cd ./Python-$PYTHON_VERSION/ \
  && ./configure --enable-optimizations --prefix=/usr/local \
  && make && make install \
  && cd ../ \
  && rm -r ./Python-$PYTHON_VERSION*

RUN python --version

WORKDIR /root/c9sdk

RUN apt install -y lld libevent-dev libbsd-dev

RUN apt install -y locales-all

RUN scripts/install-sdk.sh

# RUN npm i -g pm2

COPY ./nginx/project.conf /etc/nginx/sites-enabled/

ARG DEBIAN_FRONTEND=noninteractive
RUN rm /bin/sh && ln -s /bin/bash /bin/sh
ENV NVM_DIR /usr/local/nvm

RUN mkdir -p "$NVM_DIR"; \
    curl -o- \
        "https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh" | \
        bash \
    ; \
    source $NVM_DIR/nvm.sh; \
    nvm install 12 && ln -s "$NVM_DIR/versions/node/$(nvm version)/bin/node" "/usr/local/bin/node" && ln -s "$NVM_DIR/versions/node/$(nvm version)/bin/npm" "/usr/local/bin/npm" && ln -s "$NVM_DIR/versions/node/$(nvm version)/bin/pm2" "/usr/local/bin/pm2" && ln -s "$NVM_DIR/versions/node/$(nvm version)/bin/yarn" "/usr/local/bin/yarn"

RUN npm i -g pm2 yarn

RUN rm /etc/nginx/sites-enabled/project.conf.template

ARG C9SDK_PASSWORD=password

COPY .bashrc /tmp/.bashrc
RUN cat /tmp/.bashrc >> /root/.bashrc

RUN apt install cron sudo zip ruby-full -y
RUN gem install bundler

COPY .profile /tmp/.profile
RUN cat /tmp/.profile >> /root/.profile

# CMD pm2 start server.js --name="c9sdk" -- -w / -l 0.0.0.0 -p 3399 -a c9sdk:${C9SDK_PASSWORD} && nginx -c /etc/nginx/nginx.conf && pm2 log 0

# install envsubst & supervisor
RUN apt install -y supervisor gettext-base
# use envsubst to convert supervisord.conf.template to supervisord.conf
COPY supervisord.conf.template /etc/supervisor/conf.d/
RUN envsubst < /etc/supervisor/conf.d/supervisord.conf.template > /etc/supervisor/conf.d/supervisord.conf
COPY pm2-server-managers /root/pm2-server-managers

WORKDIR /root
COPY initial_command.sh .
RUN chmod +x initial_command.sh

WORKDIR /root/pm2-server-managers
RUN chmod a+x detect-git-repo-deployment.sh


# export all env to /env.sh file at build time
RUN touch /env.sh
RUN eval $(printenv | awk -F= '{print "export " "\""$1"\"""=""\""$2"\"" }' >> /env.sh)
RUN chmod +x /env.sh

# export env again at run time
CMD eval $(printenv | awk -F= '{print "export " "\""$1"\"""=""\""$2"\"" }' > /env.sh) && supervisord -c /etc/supervisor/conf.d/supervisord.conf
EXPOSE 8080