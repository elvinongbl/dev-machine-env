#!/bin/bash

PROGNAME=$0
COMMAND=$1

usage() {
cat << EOF
  $ ./${PROGNAME} <COMMAND>
      COMMAND:
        install:        Install ccache
        help:           print the usage
EOF
}

if [ x"$COMMAND" == x"help" ] || [ x"$COMMAND" == x"" ]; then
  usage
  exit
fi

function print_topic() {
    echo -e "\n# $@"
}

function run_cmd() {
    COLOR='\033[0;36m'
    NCOLOR='\033[0m'
    echo -e "$COLOR\$ $@ $NCOLOR"
    if [ x"$DRYRUN" != x"dryrun" ]; then
        eval $@
    fi
}

function print_cmd() {
    COLOR='\033[0;36m'
    NCOLOR='\033[0m'
    echo -e "$COLOR\$ $@ $NCOLOR"
}

function install_ccache() {
    # https://askubuntu.com/questions/470545/how-do-i-set-up-ccache
    sudo apt install -y ccache
    sudo /usr/sbin/update-ccache-symlinks
    path_has_ccache=$(echo $PATH | grep -c /usr/lib/ccache)
    if [ ${path_has_ccache} -eq 0 ]; then
        echo -e "# Add ccache PATH" | tee -a ~/.bash_aliases
        echo 'export PATH="/usr/lib/ccache:$PATH"' | tee -a ~/.bash_aliases
        source ~/.bashrc && echo $PATH
    fi
}

if [ x"$COMMAND" == x"install" ]; then
    install_ccache
    exit
fi

usage
