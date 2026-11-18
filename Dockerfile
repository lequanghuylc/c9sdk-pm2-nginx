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

# c9sdk fork with sub path (C9_SUB_PATH) + new Node.js support
ARG C9SDK_REPO=https://github.com/lequanghuylc/c9sdk.git
ARG C9SDK_BRANCH=feature/sub-path-node22
RUN git clone --branch "$C9SDK_BRANCH" "$C9SDK_REPO" c9sdk

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

ARG DEBIAN_FRONTEND=noninteractive
RUN rm /bin/sh && ln -s /bin/bash /bin/sh
ENV NVM_DIR /usr/local/nvm
# Node.js used by the IDE server, its file/terminal worker and as default node in the container
ARG NODE_VERSION=24

RUN mkdir -p "$NVM_DIR"; \
    curl -o- \
        "https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh" | \
        bash \
    ; \
    source $NVM_DIR/nvm.sh; \
    nvm install $NODE_VERSION && nvm alias default $NODE_VERSION && ln -s "$NVM_DIR/versions/node/$(nvm version)/bin/node" "/usr/local/bin/node" && ln -s "$NVM_DIR/versions/node/$(nvm version)/bin/npm" "/usr/local/bin/npm" && ln -s "$NVM_DIR/versions/node/$(nvm version)/bin/npx" "/usr/local/bin/npx" && ln -s "$NVM_DIR/versions/node/$(nvm version)/bin/pm2" "/usr/local/bin/pm2" && ln -s "$NVM_DIR/versions/node/$(nvm version)/bin/yarn" "/usr/local/bin/yarn"

RUN npm i -g pm2 yarn

# Cloud9 dependencies in ~/.c9. The official installer would download node v6 and build
# pty.js for it (no longer installable). Instead ~/.c9/node points to the Node.js above and
# the installer only sets up tmux + nak ("collab" is disabled in standalone mode).
RUN source $NVM_DIR/nvm.sh \
  && mkdir -p /root/.c9 \
  && ln -s "$NVM_DIR/versions/node/$(nvm version)" /root/.c9/node \
  && curl -fsSL https://raw.githubusercontent.com/c9/install/master/install.sh | bash -s install tmux nak

# Terminal support: node-pty built for the Node.js above (node-gyp needs python3)
ARG NODE_PTY_VERSION=1.1.0
RUN apt-get update && apt-get install -y python3 \
  && mkdir -p /tmp/node-pty && cd /tmp/node-pty \
  && npm init -y > /dev/null \
  && npm install --no-audit --no-fund node-pty@$NODE_PTY_VERSION \
  && cp -r node_modules/node-pty node_modules/node-addon-api /root/.c9/node_modules/ \
  && cd / && rm -rf /tmp/node-pty \
  && /root/.c9/node/bin/node -e "require('/root/.c9/node_modules/node-pty'); console.log('node-pty OK on', process.version)"

# install the IDE's node modules (global deps are already in ~/.c9)
# NO_PULL: keep the cloned fork as is (don't merge upstream c9/core)
RUN NO_PULL=1 scripts/install-sdk.sh

COPY ./nginx/c9-ide.conf /etc/nginx/snippets/c9-ide.conf
COPY ./nginx/project.conf /etc/nginx/sites-enabled/

RUN rm /etc/nginx/sites-enabled/project.conf.template

ARG C9SDK_PASSWORD=password

# The IDE is served at http://<domain>/ide/ (see nginx/c9-ide.conf), the root path is
# left for the main application (sample app in /root/sample-app until a GIT_REPO is deployed)
ENV C9_SUB_PATH=/ide

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
COPY sample-app /root/sample-app
RUN chmod +x /root/sample-app/start.sh

RUN apt update && apt install rsync -y

WORKDIR /root
COPY initial_command.sh .
COPY prepare_supervisord.sh .
RUN chmod +x initial_command.sh prepare_supervisord.sh

WORKDIR /root/pm2-server-managers
RUN chmod a+x detect-git-repo-deployment.sh ensure-ide-route.sh


# export all env to /env.sh file at build time
RUN touch /env.sh
RUN printenv | while IFS='=' read -r k v; do printf 'export %s="%s"\n' "$k" "$(printf '%s' "$v" | sed 's/"/\\"/g')"; done > /env.sh
RUN chmod +x /env.sh

# Re-run envsubst at start so runtime secrets (e.g. C9SDK_PASSWORD) land in supervisord.conf
CMD /root/prepare_supervisord.sh && printenv | while IFS='=' read -r k v; do printf 'export %s="%s"\n' "$k" "$(printf '%s' "$v" | sed 's/"/\\"/g')"; done > /env.sh && supervisord -c /etc/supervisor/conf.d/supervisord.conf
EXPOSE 8080