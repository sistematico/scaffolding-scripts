#!/usr/bin/env bash
#
# Arquivo: install.sh
#
# Mais um script feito com ❤️ por: 
# - "Lucas Saliés Brum" <lucas@archlinux.com.br>
# 
# Created on: 29/01/2022 10:56:30
# Updated on: 29/01/2022 10:56:33

if [ -f .env ]; then
    . .env 
else
    echo ".env file missing."
    exit 1
fi

[ -z "$USER" ] || [ -z "$REPO" ] || [ -z "$EMAIL" ] || [ -z "$TOKEN" ] && exit

[ -z "$DIR" ] && DIR="/var/www"

if [ ! -d ${DIR}/${REPO} ]; then
    git clone git@github.com:${USER}/${REPO}.git ${DIR}/${REPO}
else
    cd ${DIR}/${REPO}
    git pull
fi

curl -sL \
    'https://raw.githubusercontent.com/sistematico/scaffolding-scripts/main/html-plyr/html-plyr/stubs/etc/nginx/sites-available/nginx.conf' \
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

[ -z "$PW" ] && PW="toor"

pass=$(perl -e 'print crypt($ARGV[0], "password")' "$PW")
if ! id "nginx" &>/dev/null; then
    useradd -m -p "$pass" -d /home/nginx -s /bin/bash -c "Nginx System User" -U nginx
else
    usermod -m -p "$pass" -d /home/nginx -s /bin/bash -c "Nginx System User" nginx
fi

chown -R nginx:nginx /var/www
systemctl restart nginx