#!/bin/bash

CHOICE=$1

function usage() {
    echo -e "./download-distro.sh all"
    echo -e "./download-distro.sh download"
}

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
    https://releases.ubuntu.com/20.04.3/ubuntu-20.04.3-desktop-amd64.iso \
    https://releases.ubuntu.com/20.04.3/ubuntu-20.04.3-live-server-amd64.iso \
    https://fedora.ipserverone.com/fedora/linux/releases/32/Workstation/x86_64/iso/Fedora-Workstation-Live-x86_64-32-1.6.iso \
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

function extract_ubuntu() {
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
        ISUBUNTU=$(echo $ISONAME | grep -c ubuntu)
        EXTDIR=$(echo $url | grep -o -P "(?<=$TOPDIR/).*(?=.iso)")

        if [ ! -d $EXTDIR.rootfs ] && [ -d $EXTDIR ] && [ $ISUBUNTU -eq 1 ]; then
            echo -e "${NCOLOR}Extracting rootfs from $DESTDIR/$EXTDIR"
            FSYS=$(find $EXTDIR -name filesystem.squashfs)
            KERN=$(find $EXTDIR -name vmlinuz)
            run_cmd mkdir -p $EXTDIR.rootfs
            run_cmd sudo unsquashfs -f -d $EXTDIR.rootfs $FSYS
            run_cmd cp $KERN $EXTDIR.vmlinuz
        fi

        if [ -d $EXTDIR.rootfs ] && [ $ISUBUNTU -eq 1 ]; then
            echo -e "${NCOLOR}Extracted rootfs from $DESTDIR/$EXTDIR"
            run_cmd ls -al $DESTDIR/$EXTDIR.rootfs
        fi
    done
    run_cmd cd $CWD
}

if [ x"$CHOICE" == x"" ]; then
    usage
fi

if [ x"$CHOICE" == x"download" ]; then
    download_iso ~/workspace/distros $DISTRO
fi

if [ x"$CHOICE" == x"all" ]; then
    download_iso ~/workspace/distros $DISTRO
    extract_iso ~/workspace/distros $DISTRO
    extract_ubuntu ~/workspace/distros $DISTRO
fi
