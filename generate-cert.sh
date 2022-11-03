#!/usr/bin/env bash

mkdir -p ~/.letsencrypt/log \
        ~/.letsencrypt/workingdir \
        ~/.letsencrypt/config

certbot certonly \
  --dns-cloudflare \
  --dns-cloudflare-credentials ~/.cloudfare_credentials/credentials.ini \
  --logs-dir ~/.letsencrypt/log \
  --work-dir ~/.letsencrypt/workingdir \
  --config-dir ~/.letsencrypt/config \
  -d "*.$LOCAL_DOMAIN"

cp ~/.letsencrypt/config/live/$LOCAL_DOMAIN/privkey.pem ./certs/privkey.pem
cp ~/.letsencrypt/config/live/$LOCAL_DOMAIN/fullchain.pem ./certs/cert.pem
