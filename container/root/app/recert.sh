#!/usr/bin/env bash
while true
do
	sleep 12h
	certbot renew --webroot -w ${WEBROOT} -n --post-hook "nginx -s reload" || true
done
