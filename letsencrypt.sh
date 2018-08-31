#!/bin/bash
set -e

while getopts ":d:p:r" o; do
    case "${o}" in 
        d) DOMAIN="${OPTARG}";;
        p) INIFILE="${OPTARG}";;
        r) RENEW=true;;
    esac
done

if [ -z "${DOMAIN}" ] || [ -z "${INIFILE}" ]; then
    echo "Usage: ${0} -d domain.com -p cloudflare_keys.ini"
    exit 1
fi

if [ ! -z "${RENEW}" ]; then
    echo "Renewing certs for ${DOMAIN}."
    docker run -it --rm --name certbot \
        -v "$(pwd)/letsencrypt/etc/:/etc/letsencrypt/" \
        -v "$(pwd)/letsencrypt/lib/:/var/lib/letsencrypt/" \
        -v "$(pwd)/letsencrypt/log/:/var/log/letsencrypt/" \
        -v "$(pwd)/${INIFILE}:/cloudflare_api.ini" \
        certbot/dns-cloudflare certonly \
        --dns-cloudflare \
        --dns-cloudflare-credentials "/cloudflare_api.ini" \
        --dns-cloudflare-propagation-seconds 60 \
        -d "${DOMAIN}" \
        -d "*.${DOMAIN}"
    exit 0    
fi

echo "Assuming first time run."
echo "Creating certs for ${DOMAIN}."
docker run -it --rm --name certbot \
        -v "$(pwd)/letsencrypt/etc/:/etc/letsencrypt/" \
        -v "$(pwd)/letsencrypt/lib/:/var/lib/letsencrypt/" \
        -v "$(pwd)/letsencrypt/log/:/var/log/letsencrypt/" \
        -v "$(pwd)/${INIFILE}:/cloudflare_api.ini" \
        certbot/dns-cloudflare certonly \
        --dns-cloudflare \
        --dns-cloudflare-credentials "/cloudflare_api.ini" \
        --dns-cloudflare-propagation-seconds 60 \
        -d "${DOMAIN}" \
        -d "*.${DOMAIN}"