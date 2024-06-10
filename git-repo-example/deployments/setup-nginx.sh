#!/bin/bash

mkdir -p /var/www/deployments;

cd "$(dirname "$0")" && cd ../
PROJECT_DIR="$(pwd)"

cd $PROJECT_DIR/deployments

# if env DOMAIN_NAME is not set, use "_"
DOMAIN_NAME=${DOMAIN_NAME:-_}
# find .template file and use envsubst to replace env variables
for file in $(find . -name "*.template"); do
  envsubst < $file > /etc/nginx/sites-enabled/${file%.template}
done
# if nginx -t detects any error, it will not reload
nginx -t && nginx -s reload

