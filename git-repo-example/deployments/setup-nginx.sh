#!/bin/bash

mkdir -p /var/www/deployments;

cd "$(dirname "$0")" && cd ../
PROJECT_DIR="$(pwd)"

cd $PROJECT_DIR/deployments

# if env DOMAIN_NAME is not set, use "_"
# NOTE: exported so envsubst (a child process) sees the "_" fallback,
# otherwise the template gets an empty "server_name ;" and nginx -t fails.
# Old line (rollback):
# DOMAIN_NAME=${DOMAIN_NAME:-_}
export DOMAIN_NAME=${DOMAIN_NAME:-_}
# find .template file and use envsubst to replace env variables
for file in $(find . -name "*.template"); do
  # NOTE: only substitute $DOMAIN_NAME. A plain `envsubst` replaces every $var,
  # including nginx variables like $uri / $host / $http_upgrade in the template
  # (they become empty, e.g. "try_files  /index.html;") and nginx -t fails.
  # Old line (rollback):
  # envsubst < $file > /etc/nginx/sites-enabled/${file%.template}
  envsubst '$DOMAIN_NAME' < $file > /etc/nginx/sites-enabled/${file%.template}
done
# if nginx -t detects any error, it will not reload
nginx -t && nginx -s reload

