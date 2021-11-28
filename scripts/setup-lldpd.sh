#!/bin/bash

COMMAND=$1

usage() {
cat << EOF
  $ ./setup-lldpd.sh <COMMAND>
      COMMAND:
        all:            Prepare, build and install lldpd
        prepare:        Prepare environment for lldpd
        build:          Build lldpd
        clean:          Clean lldpd
        install:        Install lldpd artifacts
        uninstall:      Uninstall lldpd artifacts
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

function prepare_lldpd() {
    if [ -d $HOME/public-repos/lldpd ]; then
        # libtool provides libtoolize is required for ./autogen.sh
        run_cmd sudo apt -y install libtool
        run_cmd CWD=$(pwd)
        run_cmd cd $HOME/public-repos/lldpd
        run_cmd ./autogen.sh
        run_cmd ./configure
        run_cmd cd $CWD
    else
        echo -e "lldpd is not found. Please run init-repos.sh first"
        exit
    fi
}

function build_lldpd() {
    if [ -d $HOME/public-repos/lldpd ]; then
        run_cmd CWD=$(pwd)
        run_cmd cd $HOME/public-repos/lldpd
        run_cmd make
        run_cmd cd $CWD
    else
        echo -e "lldpd is not found. Please run init-repos.sh first"
        exit
    fi
}

function clean_lldpd() {
    if [ -d $HOME/public-repos/lldpd ]; then
        run_cmd CWD=$(pwd)
        run_cmd cd $HOME/public-repos/lldpd
        run_cmd make clean
        run_cmd cd $CWD
    else
        echo -e "lldpd is not found. Please run init-repos.sh first"
        exit
    fi
}

function install_lldpd() {
    if [ -d $HOME/public-repos/lldpd ]; then
        run_cmd CWD=$(pwd)
        run_cmd cd $HOME/public-repos/lldpd
        run_cmd sudo make install
        run_cmd sudo ldconfig
        run_cmd cd $CWD
    else
        echo -e "lldpd is not found. Please run init-repos.sh first"
        exit
    fi
}

function uninstall_lldpd() {
    if [ -d $HOME/public-repos/lldpd ]; then
        run_cmd CWD=$(pwd)
        run_cmd cd $HOME/public-repos/lldpd
        run_cmd sudo make uninstall
        run_cmd sudo ldconfig
        run_cmd cd $CWD
    else
        echo -e "lldpd is not found. Please run init-repos.sh first"
        exit
    fi
}

if [ x"$COMMAND" == x"prepare" ]; then
    prepare_lldpd
    exit
fi

if [ x"$COMMAND" == x"build" ]; then
    build_lldpd
    exit
fi

if [ x"$COMMAND" == x"clean" ]; then
    clean_lldpd
    exit
fi

if [ x"$COMMAND" == x"install" ]; then
    install_lldpd
    exit
fi

if [ x"$COMMAND" == x"uninstall" ]; then
    uninstall_lldpd
    exit
fi

if [ x"$COMMAND" == x"all" ]; then
    prepare_lldpd
    build_lldpd
    install_lldpd
    exit
fi
