#!/usr/bin/env bash
#
# Arquivo: install.sh
#
# Mais um script feito com ❤️ por: 
# - "Lucas Saliés Brum" <lucas@archlinux.com.br>
# 
# Created on: 29/01/2022 10:12:26
# Updated on: 29/01/2022 10:12:29

[ -z "$USER" ] || [ -z "$REPO" ] || [ -z "$EMAIL" ] || [ -z "$TOKEN" ] && exit

git clone git@github.com:${USER}/${REPO}.git ${DIR}/${REPO}

curl -sL \
    'https://raw.githubusercontent.com/sistematico/scaffolding-scripts/main/html-plyr/stubs/nginx.conf' \
    | sed -e "s|SITE_NAME|$REPO|" > /etc/nginx/sites-available/${REPO}

ln -sf /etc/nginx/sites-available/${REPO} /etc/nginx/sites-enabled/${REPO}

if [ ! -f /etc/cloudflare.ini ]; then
cat >/etc/cloudflare.ini <<-EOL
dns_cloudflare_email = ${EMAIL}
dns_cloudflare_api_key = ${TOKEN}
EOL
fi

chmod 600 /etc/cloudflare.ini

if [ ! -f /etc/letsencrypt/live/${REPO}/fullchain.pem ] && [ ! -f /etc/letsencrypt/live/${REPO}/privkey.pem ]; then
    certbot certonly -n -m "${EMAIL}" --agree-tos --dns-cloudflare --dns-cloudflare-credentials /etc/cloudflare.ini -d "${REPO}"
fi

systemctl restart nginx