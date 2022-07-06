#!/bin/bash

PROGNAME=$0
COMMAND=$1
USER=$2

usage() {
cat << EOF
  $ ./${PROGNAME} <COMMAND> <USER>
      COMMAND:
        add:        Add \$USER sudoers settings
        delete:     Remove \$USER sudoers settings
        help:       Print the usage
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

function add_sudoers() {
    run_cmd "su -"
    has_user=$(grep ^$USER /etc/sudoers -c)
    if [ $has_user -eq 0 ]; then
        # Allow $USER to sudo without pass but disallow "sudo su"
        run_cmd "echo \"$USER ALL=(ALL:ALL) NOPASSWD:ALL, !/bin/su\" >> /etc/sudoers"
    else
        print_topic "$USER is already in /etc/sudoers"
    fi
    run_cmd "cat /etc/sudoers"
    run_cmd "logout"
}

function delete_sudoers() {
    run_cmd "sudo cat /etc/sudoers"
    has_user=$(sudo grep ^$USER /etc/sudoers -c)
    if [ $has_user -gt 0 ]; then
        echo "$USER found in /etc/sudoers"
        run_cmd "su -"
        run_cmd "sed \"/$USER/d\" /etc/sudoers > ./sudoers.temp"
        run_cmd "cat ./sudoers.temp"
        run_cmd "mv /etc/sudoers /etc/sudoers.orig"
        run_cmd "mv ./sudoers.temp /etc/sudoers"
        run_cmd "rm ./sudoers.temp"
        run_cmd "logout"
    fi
}

if [ x"$COMMAND" == x"add" ]; then
    add_sudoers
    exit
fi

if [ x"$COMMAND" == x"delete" ]; then
    delete_sudoers
    exit
fi

usage
