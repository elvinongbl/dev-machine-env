#!/bin/bash

function print_topic() {
    echo -e "\n# $@"
}

function print_line() {
    echo -e "\n"
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

DISTRO=" \
    https://releases.ubuntu.com/20.04.2.0/ubuntu-20.04.2.0-desktop-amd64.iso
    https://fedora.ipserverone.com/fedora/linux/releases/32/Workstation/x86_64/iso/Fedora-Workstation-Live-x86_64-32-1.6.iso
"

function download_iso() {
    NCOLOR='\033[0m'
    DESTDIR=$1
    shift
    URLS=$@
    CWD=$(pwd)
    run_cmd mkdir -p $DESTDIR
    run_cmd cd $DESTDIR
    for url in $URLS; do
        TOPDIR=$(dirname $url)
        ISONAME=$(echo $url | grep -o -P "(?<=$TOPDIR/).*")
        if [ ! -f $ISONAME ]; then
            echo -e "${NCOLOR}Downloading ... $DESTDIR/$ISONAME"
            run_cmd wget $url -O $ISONAME
        else
            echo -e "${NCOLOR}Downloaded $DESTDIR/$ISONAME"
        fi
    done
    run_cmd cd $CWD
}

function extract_iso() {
    NCOLOR='\033[0m'
    DESTDIR=$1
    shift
    URLS=$@
    CWD=$(pwd)
    run_cmd mkdir -p $DESTDIR
    run_cmd cd $DESTDIR
    for url in $URLS; do
        TOPDIR=$(dirname $url)
        ISONAME=$(echo $url | grep -o -P "(?<=$TOPDIR/).*")
        EXTDIR=$(echo $url | grep -o -P "(?<=$TOPDIR/).*(?=.iso)")
        if [ ! -d $EXTDIR ]; then
            echo -e "${NCOLOR}Extracting ... $DESTDIR/$ISONAME"
            run_cmd mkdir -p $EXTDIR
            run_cmd cd $EXTDIR
            run_cmd 7z x ../$ISONAME
            run_cmd cd ..
        else
            echo -e "${NCOLOR}Extracted $DESTDIR/$EXTDIR"
            run_cmd ls -al $DESTDIR/$EXTDIR
        fi
    done
    run_cmd cd $CWD

}

download_iso ~/workspace/distros $DISTRO
extract_iso ~/workspace/distros $DISTRO
