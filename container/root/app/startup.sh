#!/usr/bin/env bash
set -e

if [ -z ${FQDN} ]; then
	echo ERROR: Domain name not set
	exit 1
fi;
echo Domain: ${FQDN}

if [ -z ${EMAIL} ]; then
	echo ERROR: email address not set
	exit 1
fi;
echo Email: ${EMAIL}

export CERTPATH=/etc/letsencrypt/live/${FQDN}
export WEBROOT=/app/www

EXT_IP=`dig +short myip.opendns.com @resolver1.opendns.com`
FQDN_IP=`dig +short ${FQDN}`

echo Host ip ${EXT_IP}, ${FQDN} ip ${FQDN_IP}

if [[ ! ${FQDN_IP} =~ ${EXT_IP} ]]; then
	echo WARNING: Host ip ${EXT_IP} does not match ${FQDN} ip ${FQDN_IP}
	exit 1
fi;

# testd done, now roll

if [ -d "${CERTPATH}" ]; then
	# cetificate already available
	certbot renew --standalone -n
else
	# first run only
	certbot certonly --standalone -d ${FQDN} -n --agree-tos --email ${EMAIL}
fi;

# schedule cert renewal to run every day
./recert.sh &

# configure nginx from environment vars and test it - must be after certbot
set +C
envsubst '${WEBROOT},${FQDN},${CERTPATH},${EMAIL}' < /etc/nginx/nginx.conf.tpl > /etc/nginx/nginx.conf
nginx -t

exec nginx
#exec nginx-debug
