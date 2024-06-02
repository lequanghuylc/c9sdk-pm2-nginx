## Intro

This Docker container is a IDE / Code editor, built from [C9 SDK](https://github.com/c9/core). With C9 IDE you can set up development environments in the cloud. It comes with [nvm](https://nvm.sh/), [pm2](https://pm2.keymetrics.io/) and [nginx](https://www.nginx.com/) that can help you publish your application pulically accessible to the world.

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/template/EjubUu?referralCode=kmHOLH)

## Variable

- `C9SDK_PASSWORD`: password for basic auth. it would be publically accessible if this env is not defined
- `GIT_REPO`: automatic git repo deployment
- `GIT_BRANCH`: target branch, if not present, default branch will be used.

## What is the best use case for this?

- Online - cross device development. it is an alternative to [code-server](https://github.com/coder/code-server). it is lighter than code-server which will be more resouce (cost) effective.
- Run any real world application without Docker (DinD is not yet supported in Railway)
- Gitlab Runner Shell executor for Gitlab CI/CD 

## Instructions to run real world application

- Run your application at some local port. for example: __python -m SimpleHTTPServer 9000__ to start a static web server at port 9000.
- Prepare your domain and add to __Service settings -> networking__. make sure the DNS record is setup.
- Add a nginx conf files to __/etc/nginx/sites-enabled__ to reserve proxy your application. make sure to use __server_name your_domain;__
- Run __nginx -t__ to test your .conf file
- Run __nginx -s reload__ to apply changes.
- Your application should be pulically accessible now.

### Auto Git Repo Deployment
- The start script checks the environment variable `GIT_REPO` (and `GIT_BRANCH`) and automatically clones and deploys the repository.
- `GIT_REPO` should be `https` url containing access token key
- The repo will be cloned to `/root/the-project`.
- The repo needs to have the following deployment structure, which is: 
    - `depoyments`: folder
    - - `deploy.sh`: suppose to install project deps and start the project
    - - `setup-cron.sh` suppose to setup cron for automatically checking new commit and pull and re-deploy
    - - `setup-nginx.sh` suppose to setup nginx reserve proxy with production domain name

