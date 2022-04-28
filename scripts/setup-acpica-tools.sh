#!/bin/bash

PROGNAME=$0
COMMAND=$1

# ACPICA has download packaged published at https://acpica.org/downloads
ACPIPKGURL=https://acpica.org/sites/acpica/files/acpica-unix2-20220331.tar.gz
ACPIPKG=$(basename $ACPIPKGURL)
ACPIDIR=$(basename $ACPIPKG .tar.gz)

CWD=$(pwd)

usage() {
cat << EOF
  $ ./${PROGNAME} <COMMAND>
      COMMAND:
        install:        Install acpica tools
        remove:         Remove acpica source
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

function install_acpica_tools() {
    run_cmd "wget $ACPIPKGURL"
    run_cmd "tar -xvf $ACPIPKG"
    run_cmd "cd $ACPIDIR"
    run_cmd "make"
    run_cmd "sudo make install"
    run_cmd "cd $CWD"
}

function remove_acpica_tools() {
    if [ -d $ACPIDIR ]; then
        run_cmd "rm -rf $ACPIDIR"
    fi

    if [ -f $ACPIPKG ]; then
        run_cmd "rm $ACPIPKG"
    fi
}

if [ x"$COMMAND" == x"install" ]; then
    install_acpica_tools
    exit
fi

if [ x"$COMMAND" == x"remove" ]; then
    remove_acpica_tools
    exit
fi

usage
