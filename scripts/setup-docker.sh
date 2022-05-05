#!/bin/bash

PROGNAME=$0
COMMAND=$1

CWD=$(pwd)

usage() {
cat << EOF
  $ ./${PROGNAME} <COMMAND>
      COMMAND:
        install:        Install Docker engine
        uninstall:      Uninstall Docker engine
        set-proxy:      Set-up Docker proxy
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

function install_docker() {
    # Install using the repository [1]
    run_cmd "sudo apt-get update"
    run_cmd "sudo apt-get install ca-certificates curl gnupg lsb-release"
    print_cmd "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg"
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    print_cmd "echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null"
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    run_cmd "sudo apt-get update"
    # Always install the highest version
    run_cmd "sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-compose"
    run_cmd "sudo systemctl start docker"
    run_cmd "sudo systemctl status docker"
    run_cmd "sudo docker run hello-world"
    # Notes:
    # List the versions available in your repo
    # $ apt-cache madison docker-ce
    # $ apt-cache madison docker-compose
    # $ sudo apt-get install docker-ce=<VERSION_STRING> docker-ce-cli=<VERSION_STRING> containerd.io docker-compose-plugin docker-compose=<VERSION_STRING>
}

function uninstall_old_docker() {
    run_cmd "sudo apt-get remove docker docker-engine docker.io containerd runc"
    print_topic "To delete images, containers, volumes or customized configuration:"
    print_cmd "sudo rm -rf /var/lib/docker"
}

function uninstall_docker() {
    run_cmd "sudo apt-get purge docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-compose"
    print_topic "To delete images, containers, volumes or customized configuration:"
    print_cmd "sudo rm -rf /var/lib/docker"
    print_cmd "sudo rm -rf /var/lib/containerd"
}

function set_docker_proxy() {
    # Docker uses Systemd service configuration to specify proxy
    # instead of using environment variable
    run_cmd "sudo mkdir -p /etc/systemd/system/docker.service.d"
cat << EOF > proxy.conf
[Service]
Environment="HTTP_PROXY=http://proxy.png.intel.com:911"
Environment="HTTPS_PROXY=http://proxy.png.intel.com:911"
Environment="NO_PROXY="localhost,127.0.0.0/8,::1"
EOF
    run_cmd "sudo mv proxy.conf /etc/systemd/system/docker.service.d/"
    run_cmd "sudo systemctl daemon-reload"
    run_cmd "sudo systemctl restart docker.service"
}

if [ x"$COMMAND" == x"install" ]; then
    uninstall_old_docker
    install_docker
    exit
fi

if [ x"$COMMAND" == x"uninstall" ]; then
    uninstall_docker
    exit
fi

if [ x"$COMMAND" == x"set-proxy" ]; then
    set_docker_proxy
    exit
fi

usage

# Reference
# [1] https://docs.docker.com/engine/install/ubuntu/#installation-methods
# [2] https://www.serverlab.ca/tutorials/containers/docker/how-to-set-the-proxy-for-docker-on-ubuntu/