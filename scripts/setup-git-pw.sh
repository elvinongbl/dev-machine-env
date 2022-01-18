#!/bin/bash

COMMAND=$1

usage() {
cat << EOF
  $ ./setup-git-pw.sh <COMMAND>
      COMMAND:
        install:        Install git-pw
        uninstall:      Uninstall git-pw
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

function install_git_pw() {
    if [ -d $HOME/public-repos/git-pw ]; then
        run_cmd sudo apt-get install -y python3-requests python3-click python3-pbr python3-arrow python3-tabulate python3-yaml
        run_cmd CWD=$(pwd)
        run_cmd cd $HOME/public-repos/git-pw
        run_cmd sudo pip install .
        run_cmd cd $CWD
    else
        echo -e "public-repos/git-pw is not found. Please run init-repos.sh first"
        exit
    fi
}

function uninstall_git_pw() {
    if [ -d $HOME/public-repos/git-pw ]; then
        run_cmd CWD=$(pwd)
        run_cmd cd $HOME/public-repos/git-pw
        run_cmd sudo pip uninstall git-pw
        run_cmd sudo apt-get remove -y python3-requests python3-click python3-pbr python3-arrow python3-tabulate python3-yaml
        run_cmd cd $CWD
    else
        echo -e "public-repos/git-pw is not found. Please run init-repos.sh first"
        exit
    fi
}

if [ x"$COMMAND" == x"install" ]; then
    install_git_pw
    exit
fi

if [ x"$COMMAND" == x"uninstall" ]; then
    uninstall_git_pw
    exit
fi
