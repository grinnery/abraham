# nginx + certbot

Templated [nginx](https://hub.docker.com/_/nginx/) setup with automatic SSL by [certbot](https://certbot.eff.org/#debianjessie-nginx)

## Usage

Required: Define environment variables `FQDN` and `EMAIL` for certbot.
Recommended: Mount certs volume to preserve across rebuilds.

```
docker volume create --name lecrypt
docker run \
    -v lecrypt:/etc/letsencrypt \
    -e "FQDN=example.com" \
    -e "EMAIL=sam@example.com" \
    -p 80:80 -p 443:443 \
    --name abraham \
    grin/abraham
```

or use the provided [docker-compose.yml](docker-compose.yml) as an example.

Nginx is configured to load pluggable locations from  [`/etc/nginx/locations-enabled`](container/root/etc/nginx/locations-enabled)


## TODO:

- switch to S6 for handling background certbot script

- MAYBE: planB when certbot failed?
    generate self-signed certificate like that:
```
    RUN mkdir -p $CERTPATH && \
    openssl req -new -newkey rsa:2048 -days 3650 -nodes -x509 \
       -subj '/CN=sni-support-required-for-valid-ssl' \
       -keyout $CERTPATH/privkey.pem \
       -out $CERTPATH/fullchain.pem
```

- Read: https://hub.docker.com/r/ceroic/certbot-generator/

## Work notes

Done: use gosu and exec as described here:

https://docs.docker.com/engine/reference/builder/#/exec-form-entrypoint-example
https://blog.phusion.nl/2015/01/20/docker-and-the-pid-1-zombie-reaping-problem/

Done: On startup, check is performed that FQDN is resolving to this host external IP before attemptiong to run certbot:
```
EXT_IP=`dig +short myip.opendns.com @resolver1.opendns.com`
FQDN_IP=`dig +short ${FQDN}`
```


Done: Set a domain for certbot from the active docker machine on Win:
```
@FOR /f "tokens=*" %i IN ('docker-machine active -t 1') DO set FQDN=%i
```

