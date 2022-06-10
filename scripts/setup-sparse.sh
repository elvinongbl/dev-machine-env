#!/bin/bash

PROGNAME=$0
COMMAND=$1

usage() {
cat << EOF
  $ ./${PROGNAME} <COMMAND>
      COMMAND:
        install:        Install sparse
        clean:          Clean sparse
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

function install_sparse() {
    # https://sparse.docs.kernel.org/en/latest/
    if [ -d $HOME/public-repos/oss-linux/sparse ]; then
        run_cmd "cd $HOME/public-repos/oss-linux/sparse"
        run_cmd "make"
        run_cmd "sudo make PREFIX=/usr install"
    else
        echo -e "$HOME/public-repos/oss-linux/sparse is not found. Please run init-repos.sh first"
    fi
}

function clean_sparse() {
    # https://sparse.docs.kernel.org/en/latest/
    if [ -d $HOME/public-repos/oss-linux/sparse ]; then
        run_cmd "cd $HOME/public-repos/oss-linux/sparse"
        run_cmd "make clean"
    else
        echo -e "$HOME/public-repos/oss-linux/sparse is not found. Please run init-repos.sh first"
    fi
}

if [ x"$COMMAND" == x"install" ]; then
    install_sparse
    exit
fi

if [ x"$COMMAND" == x"clean" ]; then
    clean_sparse
    exit
fi

usage
