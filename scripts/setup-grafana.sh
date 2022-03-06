#!/bin/bash

COMMAND=$1
GRAFANAVER=$2
GRAFANAREL=https://dl.grafana.com/oss/release

usage() {
cat << EOF
  $ ./setup-grafana.sh <COMMAND>
      COMMAND:
        debian <VERSION>    Install Grafana on Debian system
        help                Print the usage

    Note:
        * Get <VERSION> from https://grafana.com/grafana/download.
        * Choose OSS version, e.g. grafana_8.4.3_amd64.deb
        * However, Enterprise version, e.g. grafana-enterprise_8.4.3_amd64.deb,
          contains OSS edition, used for free and can be upgraded to Enterprise
          feature set.
EOF
}

if [ x"$COMMAND" == x"help" ] || [ x"$COMMAND" == x"" ]; then
  usage
  exit
fi

function run_cmd() {
    COLOR='\033[0;36m'
    NCOLOR='\033[0m'
    echo -e "$COLOR\$ $@ $NCOLOR"
    eval $@
}

function print_cmd() {
    COLOR='\033[0;36m'
    NCOLOR='\033[0m'
    echo -e "$COLOR\$ $@ $NCOLOR"
}

function print_topic() {
    echo -e "\n# $@"
}

function print_warn() {
    COLOR='\033[0;31m'
    NCOLOR='\033[0m'
    echo -e "$COLOR $@ $NCOLOR"
}

function install_debian() {
    if [ x"${GRAFANAVER}" != x"" ]; then
        run_cmd wget ${GRAFANAREL}/grafana_${GRAFANAVER}_amd64.deb
        if [ -f grafana_${GRAFANAVER}_amd64.deb ]; then
            # Reference: https://grafana.com/grafana/download
            run_cmd sudo apt-get install -y adduser libfontconfig1
            run_cmd sudo dpkg -i grafana_${GRAFANAVER}_amd64.deb
            print_topic "Grafana installed. Next use dgrafana helper script"
            run_cmd rm grafana_${GRAFANAVER}_amd64.deb
            exit
        else
            print_warn "Grafana deb pkg not downloaded from ${GRAFANAREL}"
            usage
            exit
        fi
    else
        print_warn "<VERSION> is not specified"
        usage
        exit
    fi
}

if [ x"$COMMAND" == x"debian" ]; then
    install_debian
    exit
fi

usage
