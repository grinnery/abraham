# nginx + certbot

to set a domain for certbot, use `domain` environment variable, e.g. from nte active docker machine:
```
@FOR /f "tokens=*" %i IN ('docker-machine active -t 1') DO set domain=%i
```

Templated [nginx](https://hub.docker.com/_/nginx/) setup with automatic SSL by [certbot](https://certbot.eff.org/#debianjessie-nginx)

Done: use gosu and exec as described here:

https://docs.docker.com/engine/reference/builder/#/exec-form-entrypoint-example
https://blog.phusion.nl/2015/01/20/docker-and-the-pid-1-zombie-reaping-problem/

Done: mount certs volume to preserve across rebuilds.

```
docker build -t abraham --build-arg domain=example.com .
docker volume create --name lecrypt
docker volume create --name lewww
docker run -v lecrypt:/etc/letsencrypt -p 80:80 -p 443:443 --name abraham abraham
```

- Check that FQDN is resolving to this host before attemptiong to certbot
- 
```
EXT_IP=`dig +short myip.opendns.com @resolver1.opendns.com`
FQDN_IP=`dig +short ${FQDN}`
```

- pluggable /locations for nginx
- switch to S6 for handling multiple processes

- MAYBE: planB when certbot failed?
    generate self-signed certificate like that
```
    RUN mkdir -p $CERTPATH && \
    openssl req -new -newkey rsa:2048 -days 3650 -nodes -x509 \
       -subj '/CN=sni-support-required-for-valid-ssl' \
       -keyout $CERTPATH/privkey.pem \
       -out $CERTPATH/fullchain.pem
```

- Read: https://hub.docker.com/r/ceroic/certbot-generator/
