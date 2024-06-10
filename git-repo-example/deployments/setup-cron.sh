#!/bin/bash

cd "$(dirname "$0")"
DIR="$(pwd)"
apt install cron -y
crontab -l > mycron
echo "*/1 * * * * $DIR/pull-n-deploy.sh" >> mycron
crontab mycron
rm mycron