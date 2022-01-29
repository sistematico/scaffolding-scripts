#!/usr/bin/env bash
#
# Arquivo: install.sh
#
# Mais um script feito com ❤️ por: 
# - "Lucas Saliés Brum" <lucas@archlinux.com.br>
# 
# Created on: 29/01/2022 10:12:26
# Updated on: 29/01/2022 10:12:29

[ -z "$USER" ] && exit
[ -z "$REPO" ] && exit

git clone git@github.com:${USER}/${REPO}.git ${DIR}/${REPO}

curl -sL \
    'https://raw.githubusercontent.com/sistematico/server-scripts/main/icecastkh-liquidsoap/common/stubs/etc/nginx/sites-available/nginx.conf' \
    | sed -e "s|SITE_NAME|$REPO|" > /etc/nginx/sites-available/${REPO}