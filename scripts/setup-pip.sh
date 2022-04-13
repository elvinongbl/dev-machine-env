#!/bin/bash

PROGNAME=$0
COMMAND=$1

usage() {
cat << EOF
  $ ./${PROGNAME} <COMMAND>
      COMMAND:
        install:        Install pip (use get-pip.py)
        upgrade:        Upgrade pip
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

function install_pip() {
    # https://pip.pypa.io/en/stable/installation/
    run_cmd "curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py"
    run_cmd "python3 get-pip.py"
    run_cmd "rm get-pip.py"
    run_cmd "pip --version"
}

function upgrade_pip() {
    # https://pip.pypa.io/en/stable/installation/
    run_cmd "python3 -m pip install --upgrade pip"
    run_cmd "pip --version"
}

if [ x"$COMMAND" == x"install" ]; then
    install_pip
    exit
fi

if [ x"$COMMAND" == x"upgrade" ]; then
    upgrade_pip
    exit
fi

usage
