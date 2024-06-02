# docker run with volumn .env and firebase-service-account.json
docker run --platform linux/amd64 --rm -p 8080:8080 -p 3399:3399 -p 3001:3001 -e GIT_REPO="https://gitlab-ci-token:glpat-eJdQw54hXqxLVsFJJxRz@gitlab.personify.tech/bottled-goose/personify-micro-apis.git" lequanghuylc/c9sdk-pm2-ubuntu:latest
