#!/bin/bash

PROGNAME=$0
COMMAND=$1

usage() {
cat << EOF
  $ ./${PROGNAME} <COMMAND>
      COMMAND:
        install:        Install Glances
        upgrade:        Upgrade latest Glances
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

function install_glances() {
    # https://glances.readthedocs.io/en/latest/install.html
    run_cmd "pip3 install glances[all]"
}

function upgrade_glances() {
    # https://glances.readthedocs.io/en/latest/install.html
    run_cmd "pip3 install --upgrade glances"
    run_cmd "pip3 install --upgrade psutil"
    run_cmd "pip3 install --upgrade glances[all]"
}

if [ x"$COMMAND" == x"install" ]; then
    install_glances
    exit
fi

if [ x"$COMMAND" == x"upgrade" ]; then
    upgrade_glances
    exit
fi

usage

# Documentation:-
# https://glances.readthedocs.io/en/latest/index.html
