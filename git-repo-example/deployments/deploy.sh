#!/bin/bash

source ~/.profile # to load nvm
cd "$(dirname "$0")" && cd ../
PROJECT_DIR="$(pwd)"
nvm install
cd $PROJECT_DIR/backend
# nvm install
# npm i -g pm2 yarn
yarn
pm2 delete the-project && pm2 start pm2.config.js
cd $PROJECT_DIR/cms
# nvm install
# npm i -g pm2 yarn
yarn
yarn nd
