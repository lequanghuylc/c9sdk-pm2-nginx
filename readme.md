## Intro

- Put C9 IDE in Docker for debugging convenient
- PM2 and NGINX reserve proxy to add more real applications
- [TODO]: PM2 server managers to turn on/off c9sdk for security

## Deploy

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/template/EjubUu?referralCode=kmHOLH)

## Variable

- `PORT`: please enter `8080` (nginx port)
- `C9SDK_PASSWORD`: password for basic auth. it would be publically accessible if this env is not defined

## What to do after deployment

- add more nginx `.conf` files to `/etc/nginx/sites-enabled` to reserve proxy your application





