
#!/bin/bash
cd "$(dirname "$0")"
DIR="$(pwd)"
DEPLOY_SCRIPT="$DIR/deploy.sh"
cd ../
export TZ=Europe/London
echo "$(date): Fetching remote repository..." > $DIR/logs/timestamp.log
# set all log from this script to deployment_log.log
exec > >(tee -a $DIR/logs/deployment_log.log)
exec 2>&1

git fetch
UPSTREAM=${1:-'@{u}'}
LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse "$UPSTREAM")
BASE=$(git merge-base @ "$UPSTREAM")

DEPLOYMENT_FILE="/var/www/deployments/status.txt"
DEPLOYMENT_LOG="/var/www/deployments/deployment_$REMOTE.log"

mkdir -p /var/www/deployments
# if DEPLOYMENT_FILE not exist, create it
if [ ! -f $DEPLOYMENT_FILE ]; then
    echo "READY TO DEPLOY" > $DEPLOYMENT_FILE
fi

DEPLOYING_STATUS=$(cat $DEPLOYMENT_FILE)

# if status is not READY TO DEPLOY, wait until it is
while [ "$DEPLOYING_STATUS" != "READY TO DEPLOY" ]; do
    echo "$(date): Waiting for deployment to be ready..."
    sleep 5
    DEPLOYING_STATUS=$(cat $DEPLOYMENT_FILE)
done

echo "DEPLOYING" > $DEPLOYMENT_FILE

if [ $LOCAL = $REMOTE ]; then
    echo "$(date): No changes detected in git"

elif [ $LOCAL = $BASE ]; then
    BUILD_VERSION=$(git rev-parse HEAD)
    echo "$(date): Changes detected, deploying new version: $BUILD_VERSION"
    git checkout . && git pull
    chmod +x $DEPLOY_SCRIPT
    $DEPLOY_SCRIPT > $DEPLOYMENT_LOG 2>&1

elif [ $REMOTE= $BASE ]; then
    echo "$(date): Local changes detected, stashing"
    git stash
    git pull
    chmod +x $DEPLOY_SCRIPT
    $DEPLOY_SCRIPT > $DEPLOYMENT_LOG 2>&1

else
    echo "$(date): Git is diverged, this is unexpected."
    echo "READY TO DEPLOY" > $DEPLOYMENT_FILE
    exit 1
fi

echo "READY TO DEPLOY" > $DEPLOYMENT_FILE