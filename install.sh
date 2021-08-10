#!/bin/bash
#
# ./install.sh [dryrun]
#

DRYRUN=$1

######################################
# Convenient script
######################################
function print_topic() {
    echo -e "\n# $@"
}

function print_banner() {
    echo -e "\n"
    echo -e "###############################################################"
    echo -e "# $@ "
    echo -e "# Time = $(date)"
    echo -e "###############################################################"
}

function run_cmd() {
    COLOR='\033[0;36m'
    NCOLOR='\033[0m'
    echo -e "$COLOR\$ $@ $NCOLOR"
    if [ x"$DRYRUN" != x"dryrun" ]; then
        eval $@
    fi
}

######################################
# Install software packages
######################################

PKGLIST_EDIT="vim-nox nano tree"
COMMENT_EDIT="Editing: vim-nox|nano (text editing); tree (directory show)"

PKGLIST_COMMS=" \
 socat openssh-server tightvncserver \
 xfce4 xfce4-goodies \
 putty \
"
COMMENT_COMMS="Comms: vncserver & setup xfce (lightweight vnc session);"

PKGLIST_SYSTEM="i7z htop"
COMMENT_SYSTEM="System: i7z (system monitor);"

PKGLIST_DEVTOOL=" \
 bc bison build-essential cpio chrpath \
 dblatex debianutils diffstat docbook-utils \
 exuberant-ctags flex fop gawk git gcc-multilib iputils-ping \
 libegl1-mesa libsdl1.2-dev libncurses5-dev libssl-dev libelf-dev \
 python3 python3-pip python3-pexpect python3-git python3-jinja2 pylint3 \
 texinfo unzip \
 wget xterm xz-utils xsltproc xmlto \
"
COMMENT_DEVTOOL="Development tools:"

PKGLIST_DEBUG="kernelshark"
COMMENT_DEBUG="kernelshark (process monitoring)"

PKGLIST_NETWORKING="packeth wireshark ostinato tshark"
COMMENT_NETWORKING=" \
packeth (Eth packet generator); \
wireshark (packet capture and disesector)\
"

PKGLIST_OBSERVABILITY=" \
 procps util-linux sysstat iproute2 numactl \
 linux-tools-common linux-tools-$(uname -r) \
 bpfcc-tools bpftrace perf-tools-unstable \
 trace-cmd nicstat ethtool tiptop msr-tools \
"
COMMENT_OBSERVABILITY=" \
 Linux observability tool recommended in <System Performance - \
 Enterprise and the Cloud>, Brendan Gregg \
 "

function install_packages(){
    print_banner "Install software packages on dev machine"
    print_topic "Update and upgrade current software packages..."
    run_cmd sudo apt update
    run_cmd sudo apt upgrade

    print_topic $COMMENT_EDIT
    run_cmd sudo apt install -y $PKGLIST_EDIT

    print_topic $COMMENT_COMMS
    run_cmd sudo apt install -y $PKGLIST_COMMS

    print_topic $COMMENT_SYSTEM
    run_cmd sudo apt install -y $PKGLIST_SYSTEM

    print_topic $COMMENT_DEVTOOL
    run_cmd sudo apt install -y $PKGLIST_DEVTOOL

    print_topic $COMMENT_DEBUG
    run_cmd sudo apt install -y $PKGLIST_DEBUG

    print_topic $COMMENT_NETWORKING
    run_cmd sudo apt install -y $PKGLIST_NETWORKING

    print_topic $COMMENT_OBSERVABILITY
    run_cmd sudo apt install -y $PKGLIST_OBSERVABILITY
}

######################################
# Setup misc environment
######################################
function setup_misc(){
    print_banner "Setup misc configurations"
    print_topic "Install ~/.vimrc, ~/.dircolors, ~/.bash_aliases"
    run_cmd cp ./configs/vimrc         $HOME/.vimrc
    run_cmd cp ./configs/dircolors     $HOME/.dircolors
    run_cmd cp ./configs/bash_aliases  $HOME/.bash_aliases

    print_topic "Setup ~/.gitconfig & ~/own-github/.github"
    run_cmd cp ./configs/main_gitconfig     $HOME/.gitconfig
    run_cmd mkdir -p $HOME/own-repos/
    run_cmd cp ./configs/own_gitconfig $HOME/own-repos/.gitconfig

    print_topic "Setup ~/common/bin/socat"
    run_cmd mkdir -p $HOME/common/bin
    run_cmd cp ./bin/socatproxy    $HOME/common/bin/socatproxy
    run_cmd chmod +x $HOME/common/bin/socatproxy
}

######################################
# Setup vncserver environment
######################################
function setup_vncserver() {
    print_banner "Setup vncserver"
    run_cmd mv $HOME/.vnc/xstartup  $HOME/.vnc/xstartup.bak
    run_cmd cp ./configs/vncserver@.service  /etc/systemd/system/
    print_topic "Reload vncsever systemd unit"
    run_cmd systemctl daemon-reload
    run_cmd systemctl enable vncserver@1.service
    run_cmd systemctl start vncserver@1

    ## Start vncserver manually to enter password
    print_topic "Start vncserver to create password"
    run_cmd vncserver
    run_cmd vncserver -kill :1


   ## Finally, on the client machine create a ssh pipe to vncserver
   # ssh -L 5901:127.0.0.1:5901 -C -N -l bong5 elvinlatte.local
   # For MAC, open safari, use vnc://localhost:5901
}

######################################
# Setup vncserver environment
######################################
function install_helper_scripts() {
   print_banner "Install helper scripts"
   run_cmd cp ./bin/osystem    $HOME/common/bin/
   run_cmd cp ./bin/kgrub      $HOME/common/bin/
   run_cmd cp ./bin/oputty     $HOME/common/bin/
   run_cmd cp ./bin/mycmd      $HOME/common/bin/
}

######################################
# Main installation flow
######################################

install_packages
setup_misc
install_helper_scripts
setup_vncserver

print_banner "Machine environment setup: COMPLETE."
print_topic "Now, you may source ~/.bashrc to refresh"

