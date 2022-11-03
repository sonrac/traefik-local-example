# Init docker

## Goal

Get trusted https-certificates clear and locally with real domain.

## Requirements

1. Installed [docker](https://docker.com)
2. Installed [python](https://python.org)
3. Registered domain with [certbot plugin supported](https://github.com/search?q=certbot+plugin)

## Prepare certificates

### Before start

In this configuration we will skip [traefik dns challenges](https://doc.traefik.io/traefik/user-guides/docker-compose/acme-dns/) for letsencrypt certificates.  Before start container we will must create wildcard certificate for all subdomains manually.

### Install certbot

```bash
pip3 install --user certbot
```

#### Configure dns challenge (cloudflare as example)

* Add `LOCAL_DOMAIN` to PATH variable with domain name

* Install letsencrypt

```bash
pip3 install certbot --user
```
* Install auth plugin for your provider (cloudflare as example)

List allowed providers was [here](https://letsencrypt.org/docs/client-options/) or you can search plugin for your provider on github.

```bash
pip3 install certbot-dns-cloudflare --user
```

* Add new dns record to your domain registrator (we need domain with local IP for letsencrypt certificate)

Format:

| Type | Name                                 | IpV4      | TTL |
|------|--------------------------------------|-----------|-----|
| A    | <your subdomain `local` for example> | 127.0.0.1 | 600 |

* Wait while record would be added
* Generate [new token](https://dash.cloudflare.com/?to=/:account/profile/api-tokens) for certbot auth
* Save your token in any ini file in format

```ini
# Cloudflare API token used by Certbot
dns_cloudflare_api_token = <token>
```

* Generate ssl certificate

```bash
# Create letencrypt dirs
mkdir -p ~/.letsencrypt/log ~/.letsencrypt/workingdir ~/.letsencrypt/config
# Generate wild card certificates
certbot certonly \
  --dns-cloudflare \
  --dns-cloudflare-credentials </path/to/credentials/ini> \
  --logs-dir ~/.letsencrypt/log \
  --work-dir ~/.letsencrypt/workingdir \
  --config-dir ~/.letsencrypt/config \
  -d "*.$LOCAL_DOMAIN"

# copy certificates
cp ~/.letsencrypt/config/live/$LOCAL_DOMAIN/privkey.pem ./certs/privkey.pem
cp ~/.letsencrypt/config/live/$LOCAL_DOMAIN/fullchain.pem ./certs/cert.pem
```

## Renew certificates when generated certificates was expired

```bash
certbot renew --dry-run \
  --dns-cloudflare \
  --dns-cloudflare-credentials </path/to/credentials/ini> \
  --logs-dir ~/.letsencrypt/log \
  --work-dir ~/.letsencrypt/workingdir \
  --config-dir ~/.letsencrypt/config 

docker restart traefik

```

## Setting up project:

* Create network for traefik

```bash
docker network create traefik
``` 

## Example nginx docker-compose with traefik proxy

```yaml 
version: '3.9'

networks:
  traefik:
    external: true

services:
  nginx:
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.some-service-nginx.rule=Host(`some-service.$LOCAL_DOMAIN`)" # replace with your domain
      - "traefik.http.routers.some-service-nginx.entrypoints=web-secure" # Allow only https
      - "traefik.http.routers.some-service-nginx.tls.certresolver=certificate" # Certificates resolver
      - "traefik.http.services.some-service-nginx.loadBalancer.server.port=8080" # Proxied port
      - "traefik.docker.network=traefik" # Required. We need say traefik network for scan
    networks:
      - resume
      - traefik
```

## Traefik hub

Generate token add add it to environment variable `HUB_TOKEN` or disable traefik hub agent if you don't need it.

You can find more usages description [traefik hub](https://doc.traefik.io/traefik-hub/)
