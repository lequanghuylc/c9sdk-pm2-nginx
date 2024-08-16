#!/bin/bash
source ~/.profile # to load nvm
PROJECT_DIR="$(pwd)"

# check if env GIT_REPO is set
if [ -z "$GIT_REPO" ]; then
  echo "GIT_REPO is not set"
  exit 0
fi

# set all log from this script to deployment_log.log
exec > >(tee -a $DIR/deloyments.log)
exec 2>&1

# check if env GIT_BRANCH is set, if yes, clone that branch, if not, clone default

cd /root && git clone $GIT_REPO the-project
cd /root/the-project
if [ -z "$GIT_BRANCH" ]; then
  git checkout $GIT_BRANCH
fi

cd the-project
# check if deployments dir is present
if [ ! -d "deployments" ]; then
  echo "deployments dir not found, existing."
  exit 0
fi
cd deployments
# check if deploy.sh is present
if [ -f "deploy.sh" ]; then
  echo "deploy.sh found, executing.."
  chmod a+x deploy.sh
  ./deploy.sh || echo "Seems like there is an error in deploy.sh"
  echo "deploy.sh executed"
fi
# check if setup-nginx is present
if [ -f "setup-nginx.sh" ]; then
	echo "setup-nginx.sh found, executing.."
  chmod a+x setup-nginx.sh
  ./setup-nginx.sh || echo "Seems like there is an error in setup-nginx.sh"
	echo "setup-nginx.sh executed"
fi
# check if setup-cron is present
if [ -f "setup-cron.sh" ]; then
	echo "setup-cron.sh found, executing.."
  chmod a+x setup-cron.sh
  ./setup-cron.sh || echo "Seems like there is an error in setup-cron.sh"
	echo "setup-cron.sh executed"
fi