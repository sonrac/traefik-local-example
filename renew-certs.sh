#!/usr/bin/env bash

certbot renew --dry-run \
  --dns-cloudflare \
  --dns-cloudflare-credentials ~/.cloudfare_credentials/credentials.ini \
  --logs-dir ~/.letsencrypt/log \
  --work-dir ~/.letsencrypt/workingdir \
  --config-dir ~/.letsencrypt/config

docker restart traefik
