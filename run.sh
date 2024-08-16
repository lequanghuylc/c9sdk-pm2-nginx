# docker run with volumn .env and firebase-service-account.json
docker run --platform linux/amd64 --rm -p 8080:8080 -p 3399:3399 -p 3001:3001 -e GIT_REPO="https://gitlab-ci-token:glpat-7jfg18NytD64z2QzdREx@gitlab.personify.tech/bottled-goose/personify-micro-apis.git" lequanghuylc/c9sdk-pm2-ubuntu:latest




docker run --platform linux/amd64 --rm -p 8888:8080 -v /Users/mac/Documents/Code/Codesigned/Personify/print-manager/backend:/root/backend lequanghuylc/c9sdk-pm2-ubuntu:latest