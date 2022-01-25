#!/usr/bin/env bash
#
# Arquivo: inertia.sh
#
# Mais um script feito com ❤️ por: 
# - "Lucas Saliés Brum" <lucas@archlinux.com.br>
# 
# Criado em: 23/09/2021 01:33:12
# Atualizado: 25/01/2022 10:04:47
#
# Referência:
# FG: reset = 0, black = 30, red = 31, green = 32, yellow = 33, blue = 34, magenta = 35, cyan = 36, white = 37
# BG: reset = 0, black = 40, red = 41, green = 42, yellow = 43, blue = 44, magenta = 45, cyan = 46, white=47

TEMA="red" # default, red, green, yellow, magenta
DIALOG="dialog" # whiptail, dialog
TITLE="Inertia.js Bootstrap Installer"
BACKTITLE="Laravel 8, Inertia.js, Vue.js 3 & Twitter Bootstrap 5 Scaffolding"
TMUX_SESSION="Inertia"
SECS="3s"
UPDATE=0
OPTS="--keep-tite --stdout --colors" 
INFOOPTS="--keep-tite"
REGEX="^[a-zA-Z0-9.-]+$"
APPS="curl composer tmux npm"
TIPO="JetStream"

running() { ps $1 | grep $1 >/dev/null; }

if ! command -v dialog &> /dev/null; then
    echo -e "O programa \e[1;31mdialog\e[0m não está instalado, instale-o primeiro."
    exit
fi

[ ! -d $HOME/.config/dialog/ ] && mkdir -p $HOME/.config/dialog/
case $TEMA in
    amarelo|yellow)
        TEMA="yellow"
        [ ! -f $HOME/.config/dialog/$TEMA.cfg ] && curl -s -L http://ix.io/3EtV -o $HOME/.config/dialog/$TEMA.cfg
    ;;
    vermelho|red)
        TEMA="red"
        [ ! -f $HOME/.config/dialog/$TEMA.cfg ] && curl -s -L https://git.io/JzK4p -o $HOME/.config/dialog/$TEMA.cfg
    ;;
    verde|green)
        TEMA="green"
        [ ! -f $HOME/.config/dialog/$TEMA.cfg ] && curl -s -L https://git.io/JzK4b -o $HOME/.config/dialog/$TEMA.cfg
    ;;
    rosa|magenta)
        TEMA="magenta"
        [ ! -f $HOME/.config/dialog/$TEMA.cfg ] && curl -s -L https://git.io/JzKRZ -o $HOME/.config/dialog/$TEMA.cfg
    ;;
    *)
        TEMA="default"
        [ ! -f $HOME/.config/dialog/$TEMA.cfg ] && curl -s -L https://git.io/JzK42 -o $HOME/.config/dialog/$TEMA.cfg
    ;;
esac
export DIALOGRC=$HOME/.config/dialog/$TEMA.cfg

for app in $APPS
do
    if ! command -v $app &> /dev/null
    then
        timeout --foreground $SECS $DIALOG $OPTS --backtitle "$BACKTITLE" --title "$TITLE" --msgbox "O programa ${app} não está instalado, instale-o primeiro." 10 30
        exit
    fi
done

timeout --foreground $SECS $DIALOG $OPTS --msgbox "Bem-vindo ao instalador gráfico do Laravel JetStream/Breeze!" 10 40

$DIALOG $OPTS --backtitle "$BACKTITLE" --title "$TITLE" --yesno "Deseja continuar a instalação?" 0 0 2>&1
[ $? = 1 ] && exit 1

if [ $UPDATE = 1 ]; then
    sudo -H composer self-update &>/dev/null
    COMPOSER_PID=$!
    (
        echo 10
        while running $COMPOSER_PID; do
            echo 50
        done    
        echo 100
    ) | $DIALOG $OPTS --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Atualizando o composer" 8 40 0 2>&1
fi

case "$2" in
    "-b"|"--breeze")
        TIPO="Breeze"
    ;;
    "-j"|"--jet"|"--jetstream")
        TIPO="JetStream"
    ;;
    *)
        TIPO="$($DIALOG $OPTS --backtitle "$BACKTITLE" --title "$TITLE" --menu 'Escolha o perfil da instalação:' 0 0 0 JetStream 'Laravel JetStream' Breeze 'Laravel Breeze' Nenhum 'Nenhum' 2>&1)"
        [ $? = 1 ] && exit 1
        if [ -z "$TIPO" ]; then
            TIPO="JetStream"
        fi
    ;;
esac

DIR="$(pwd)"

if [ ! -d app ]; then
    if [ ! $2 ]; then
        DIR=$($DIALOG $OPTS --backtitle "$BACKTITLE" --title "$TITLE" --inputbox "Digite o nome do projeto:" 0 0 "${TIPO,,}-bootstrap" 2>&1)
        [ $? = 1 ] && exit 1
    else 
        DIR="$2"
    fi

    [ -z "$DIR" ] && exit

    if [ -d "$DIR" ]; then
        $DIALOG $OPTS --backtitle "$BACKTITLE" --title "$TITLE" --yesno "O diretório $DIR jś existe, deseja sobre-escrever?" 0 0 2>&1
        [ $? = 1 ] && exit 1
        
        $DIALOG $OPTS --backtitle "$BACKTITLE" --title "$TITLE" --yesno "Tem certeza?" 0 0 2>&1
        [ $? = 0 ] && mv $DIR /tmp/$DIR-$(date +%s) || timeout --foreground $SECS $DIALOG $OPTS --backtitle "$BACKTITLE" --title "$TITLE" --msgbox "Abortando a instalação" 10 40
    fi

    if [[ ! "$DIR" =~ $REGEX ]]; then
      timeout --foreground $SECS $DIALOG $OPTS --backtitle "$BACKTITLE" --title "$TITLE" --msgbox "O caminho \e[1;31m${DIR}\e[0m é inválido." 10 30
      exit 1
    fi

    INSTALLER=$($DIALOG $OPTS --backtitle "$BACKTITLE" --title "$TITLE" --radiolist "O tipo de instalador" 10 45 5 \
        "1" "cURL" ON \
        "2" "Composer" OFF \
        "3" "Laravel Installer" OFF 2>&1)

    timeout --foreground $SECS $DIALOG $OPTS --backtitle "$BACKTITLE" --title "$TITLE" --msgbox "Instalando o pacote laravel/laravel em ${DIR}..." 10 40

    case "$INSTALLER" in
        "2")
            composer create-project laravel/laravel $DIR
        ;;
        "3")
            laravel new $DIR
        ;;
        *)
            if ! command -v curl &> /dev/null; then
                echo -e "O programa \e[1;31mcurl\e[0m não está instalado, instale-o primeiro."
                exit
            fi

            if ! systemctl list-unit-files | grep docker > /dev/null; then
                echo -e "Instale o docker primeiro."
                exit
            fi

            if ! systemctl is-active --quiet service; then
                echo -e "Inicie o daemon do Docker primeiro."
                exit
            fi

            curl -s https://laravel.build/$DIR | bash
        ;;
    esac
fi

if [ ! -d $DIR ]; then
    echo -e "O diretório \e[1;31m${DIR}\e[0m não existe, instalação abortada."
    exit
fi

cd $DIR

test ! -d database && mkdir database
test -f database/database.sqlite || touch database/database.sqlite

curl -s -L https://git.io/Jilxo -o .env
curl -s -L https://git.io/Jilxi -o .env.example

case "$TIPO" in
    "Breeze")
        timeout --foreground $SECS $DIALOG $OPTS --backtitle "$BACKTITLE" --title "$TITLE" --msgbox "O instalador prosseguirá para a instalação da stack:\n\n- Laravel Breeze" 10 45
        composer require mralston/bootstrap-breeze --dev
        php artisan breeze:install vue-bootstrap 
    ;;
    *)
        timeout --foreground $SECS $DIALOG $OPTS --backtitle "$BACKTITLE" --title "$TITLE" --msgbox "O instalador prosseguirá para a instalação da stack:\n\n- Laravel JetStream" 10 45
        composer require laravel/jetstream
        php artisan jetstream:install inertia --teams
        
        FRONTEND=$($DIALOG $OPTS --backtitle "$BACKTITLE" --title "$TITLE" --radiolist "Escolha o Framework do Front-End" 10 45 5 \
                "1" "TailwindCSS (Padrão do Laravel)" ON \
                "2" "Twitter Bootstrap 5" OFF 2>&1)

        [ -z "$FRONTEND" ] && exit 1

        if [ "$FRONTEND" == "2" ] && [ "$TIPO" != "Breeze" ]; then
            composer require nascent-africa/jetstrap --dev
            php artisan jetstrap:swap inertia
        fi
    ;;
esac

npm install
npm run dev
npm run dev
php artisan migrate
php artisan key:generate

mkdir -p .vscode .github/workflows
curl -s -L https://git.io/JzKBl -o .vscode/tasks.json
curl -s -L https://git.io/Ji8nf -o .github/workflows/laravel.yml

$DIALOG $OPTS --backtitle "$BACKTITLE" --title "$TITLE" --yesno "Deseja executar os comandos: \nphp artisan serve\nnpm run watch" 0 0 2>&1

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

GITOPTS=$($DIALOG $OPTS --backtitle "$BACKTITLE" --title "$TITLE" --radiolist "Opções de versionamento" 10 65 5 \
        "1" "Inicializar um projeto existente no Github" ON \
        "2" "Inicializar um projeto existente e habilitar mensagens de commit & push automáticos" OFF \
        "3" "Não inicializar o GIT" ON 2>&1)

if [ $? = 0 ] && [ -z "$GITOPTS" ] && ([ "$GITOPTS" == "1" ] || [ "$GITOPTS" == "2" ]); then
    echo "# $(basename $(pwd))" >> README.md
    curl -s -L https://unlicense.org/UNLICENSE -o LICENSE
    git init
    git add .
    git commit -m "Commit inicial, Inertia.sh Scaffolding"
    git branch -M main
    REPO=$($DIALOG $OPTS --backtitle "$BACKTITLE" --title "$TITLE" --inputbox "Digite o nome do repositorio no formato usuario/repositorio(Sem o .git):" 0 0 "$(whoami)/$(basename $(pwd))" 2>&1)
    if [ ! -z "$REPO" ]; then
        git remote add origin git@github.com:${REPO}.git
        git push -u origin main
    fi
fi

if [ -d .git ]; then
    if [ "$GITOPTS" == "2" ]; then
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
fi

timeout --foreground $SECS $DIALOG $OPTS --backtitle "$BACKTITLE" --title "$TITLE" --msgbox "Instalação finalizada com sucesso." 10 30

exit