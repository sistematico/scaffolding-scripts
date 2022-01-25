#!/usr/bin/env bash
#
# Arquivo: inertia.sh
#
# Mais um script feito com ❤️ por: 
# - "Lucas Saliés Brum" <lucas@archlinux.com.br>
# 
# Criado em: 23/09/2021 01:33:12
# Atualizado: 25/01/2022 10:04:47

TMUX_SESSION="Inertia"
REGEX="[^a-zA-Z0-9_\-]"

read -p "O nome do diretório do projeto: " PROJECT

if [ -z "$PROJECT" ] || [[ "$PROJECT" =~ $REGEX ]]; then
    echo "Diretório inválido."
    exit 1
fi

sudo -H composer self-update &>/dev/null
composer create-project laravel/laravel $PROJECT
cd $PROJECT

test ! -d database && mkdir database
test -f database/database.sqlite || touch database/database.sqlite

curl -s -L https://raw.githubusercontent.com/sistematico/scaffolding-scripts/main/laravel-inertia-vue/stubs/.env -o .env
curl -s -L https://raw.githubusercontent.com/sistematico/scaffolding-scripts/main/laravel-inertia-vue/stubs/.env.example -o .env.example

composer require laravel/jetstream
php artisan jetstream:install inertia 
        
composer require nascent-africa/jetstrap --dev
php artisan jetstrap:swap inertia

curl -s -L https://raw.githubusercontent.com/sistematico/scaffolding-scripts/main/laravel-inertia-vue/stubs/webpack.mix.js -o webpack.mix.js
curl -s -L https://raw.githubusercontent.com/sistematico/scaffolding-scripts/main/laravel-inertia-vue/stubs/resources/js/app.js -o resources/js/app.js
curl -s -L https://raw.githubusercontent.com/sistematico/scaffolding-scripts/main/laravel-inertia-vue/stubs/resources/js/Layouts/BaseLayout.vue -o resources/js/Layouts/BaseLayout.vue
curl -s -L https://raw.githubusercontent.com/sistematico/scaffolding-scripts/main/laravel-inertia-vue/stubs/public/css/base.css -o public/css/base.css

npm install
npm run dev
npm run dev
php artisan migrate
php artisan key:generate

mkdir -p .vscode .github/workflows
curl -s -L https://raw.githubusercontent.com/sistematico/scaffolding-scripts/main/laravel-inertia-vue/stubs/.vscode/tasks.json -o .vscode/tasks.json
curl -s -L https://raw.githubusercontent.com/sistematico/scaffolding-scripts/main/laravel-inertia-vue/stubs/.github/workflows/laravel.yml -o .github/workflows/laravel.yml

if command -v tmux &> /dev/null; then
    if [ $? = 0 ]; then
        \tmux has-session -t $TMUX_SESSION 2>/dev/null

        if [ $? != 0 ]; then
            \tmux new-session -d -s $TMUX_SESSION
        else
            \tmux kill-session -t $TMUX_SESSION
        fi
        
        \tmux new-window -t $TMUX_SESSION -n artisan -d
        \tmux new-window -t $TMUX_SESSION -n npm -d

        \tmux send-keys -t $TMUX_SESSION:artisan "php artisan serve" ENTER
        \tmux send-keys -t $TMUX_SESSION:npm "npm run watch" ENTER

        \tmux detach -s $TMUX_SESSION
    else
        \tmux has-session -t $TMUX_SESSION 2>/dev/null

        if [ $? == 0 ]; then
            \tmux kill-session -t $TMUX_SESSION
        fi
    fi
fi


if [ -d .git ]; then
    curl -s -L https://git.io/JzKB2 -o .git/hooks/post-commit
    chmod +x .git/hooks/post-commit
    git config --local commit.template .commit

    if [ ! -f .commit ] || [ ! -s .commit ]; then
        echo "Update automático" > .commit
    fi

    if [ ! -f .gitignore ] || [ ! -s .gitignore ]; then
        echo ".commit" > .gitignore
    else
        if ! grep -Fxq ".commit" .gitignore 2> /dev/null; then
            echo ".commit" >> .gitignore        
        fi
    fi
fi