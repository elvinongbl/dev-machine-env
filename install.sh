#!/bin/bash
#
# ./install.sh all work|home
# ./install.sh myenv work|home
# ./install.sh mycmd
# ./install.sh package

CHOICE=$1
MODE=$2

function usage() {
    echo -e "./install.sh all work|home"
    echo -e "./install.sh myenv work|home"
    echo -e "./install.sh mycmd"
    echo -e "./install.sh python"
    echo -e "./install.sh package"
}

######################################
# Convenient script
######################################
function print_topic() {
    echo -e "\n# $@"
}

function print_warn() {
    COLOR='\033[0;31m'
    NCOLOR='\033[0m'
    echo -e "$COLOR $@ $NCOLOR"
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
    eval $@
}

######################################
# Install software packages
######################################

PKGLIST_EDIT="vim-nox nano tree"
COMMENT_EDIT="Editing: vim-nox|nano (text editing); tree (directory show)"

PKGLIST_COMMS=" \
 socat openssh-server tightvncserver \
 xfce4 xfce4-goodies \
 connect-proxy \
 putty \
"
COMMENT_COMMS="Comms: vncserver & setup xfce (lightweight vnc session);"

PKGLIST_SYSTEM="i7z htop"
COMMENT_SYSTEM="System: i7z (system monitor);"

PKGLIST_DEVTOOL=" \
 bc bison build-essential cpio chrpath \
 dblatex debianutils diffstat docbook-utils \
 exuberant-ctags flex fop gawk git git-email tig \
 gcc-multilib iputils-ping \
 libegl1-mesa libsdl1.2-dev libncurses5-dev libssl-dev libelf-dev \
 python3 python3-pip python3-pexpect python3-git python3-jinja2 pylint3 \
 texinfo unzip \
 wget xterm xz-utils xsltproc xmlto \
 cmake p7zip-full p7zip-rar \
 squashfs-tools rpm \
 codespell \
 figlet graphviz \
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

PKGLIST_VIRTUALMACHINE=" \
 vagrant virtualbox \
"
COMMENT_VIRTUALMACHINE=" \
 Software package for virtual machine setup on host machine \
"

# qemu is the package that contains the application.
# qemu-kvm is a package we need for QEMU to be able to virtualize processes using KVM.
# Since QEMU is a tool that provides us with a GUI, we installed virt-manager and virt-viewer.
# The packages libvirt are the binaries used by both QEMU and KVM to perform virtualizations
# and service monitoring.
#
# https://earlruby.org/2018/12/use-iso-and-kickstart-files-to-automatically-create-vms/
PKGLIST_QEMU=" \
 qemu-kvm qemu virt-manager virt-viewer virtinst virt-top \
 libvirt-clients libvirt-daemon libvirt-daemon-system \
 libvirt-daemon-driver-storage-zfs \
 libosinfo-bin libguestfs-tools cpu-checker ssh-askpass-gnome \
 python3-libvirt \
 vagrant-libvirt vagrant-sshfs \
 bridge-utils \
 openvswitch-switch \
"
COMMENT_QEMU=" \
 Qemu/KVM tool \
"

PKGLIST_PM=" \
 powertop s-tui stress \
"
COMMENT_PM=" \
 Power Management tool. \
 s-tui & stree for stress terminal GUI \
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

    # This installation will cause system reboot
    # uncommon it if you are beside your machine
    #print_topic $COMMENT_VIRTUALMACHINE
    #run_cmd sudo apt install -y $PKGLIST_VIRTUALMACHINE

    print_topic $COMMENT_QEMU
    run_cmd sudo apt install -y $PKGLIST_QEMU

    print_topic $COMMENT_PM
    run_cmd sudo apt install -y $PKGLIST_PM
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
    if [ x"$MODE" == x"work" ]; then
        run_cmd cp ./configs/main_gitconfig     $HOME/.gitconfig
        run_cmd mkdir -p $HOME/own-repos/
        run_cmd cp ./configs/own_gitconfig $HOME/own-repos/.gitconfig
    else
        run_cmd cp ./configs/home_main_gitconfig     $HOME/.gitconfig
        run_cmd mkdir -p $HOME/own-repos/
        run_cmd cp ./configs/home_own_gitconfig $HOME/own-repos/.gitconfig
    fi

    if [ x"$MODE" == x"work" ]; then
        print_topic "Setup ~/common/bin/socat"
        run_cmd mkdir -p $HOME/common/bin
        run_cmd cp ./configs/socatproxy    $HOME/common/bin/socatproxy
        run_cmd chmod +x $HOME/common/bin/socatproxy
    fi

    print_topic "Create workspace"
    run_cmd mkdir -p $HOME/workspace
    print_topic "Create mender-cpio folder to Yocto Project initramfs"
    run_cmd mkdir -p $HOME/workspace/mender-cpio
}

######################################
# Setup vncserver environment
######################################
function setup_vncserver() {
    print_banner "Setup vncserver"
    run_cmd mv $HOME/.vnc/xstartup  $HOME/.vnc/xstartup.bak
    run_cmd sudo cp ./configs/vncserver@.service  /etc/systemd/system/
    print_topic "Reload vncsever systemd unit"
    run_cmd sudo systemctl daemon-reload
    run_cmd sudo systemctl enable vncserver@1.service
    run_cmd sudo systemctl start vncserver@1

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
    run_cmd mkdir -p $HOME/common/bin/include
    run_cmd cp -r ./bin    $HOME/common/
}

######################################
# GitHub uses personal token now since 13th Aug, so we need to move
# https://github.blog/2020-12-15-token-authentication-requirements-for-git-operations/
# https://github.com/microsoft/Git-Credential-Manager-Core#linux-install-instructions
######################################

# For pulling latest gcm from
# https://github.com/microsoft/Git-Credential-Manager-Core/blob/main/docs/linuxcredstores.md
# https://github.com/microsoft/Git-Credential-Manager-Core/releases
function install_git_credential_manager_latest() {
    print_topic "Install git credential manager (gcm) for all future github access"
    latest="https://github.com/microsoft/Git-Credential-Manager-Core/releases/download/v2.0.498/gcmcore-linux_amd64.2.0.498.54650.deb"
    latest_dpkg="gcmcore-linux_amd64.2.0.498.54650.deb"
    run_cmd wget $latest
    run_cmd sudo dpkg -i $latest_dpkg
    run_cmd git config --global credential.credentialStore plaintext
    run_cmd git-credential-manager-core configure
    run_cmd rm $latest_dpkg
    print_topic "Generate your github personal token and when you push commit, gcm will ask for token and store it"
}

function setup_fuse_conf() {
    # To enable guestmount to mount virtual disk as root and access by
    # other user.
    print_topic "Make /etc/fuse.conf to allow other user"
    run_cmd sudo sed -i "s|#user_allow_other|user_allow_other|g" /etc/fuse.conf
}

function setup_python_virtualenv() {
    # Python virtual env works since Python 3.6 provides a python
    # sandbox with its own set of Python packages from your
    # underlying system-wide site-packages. This allows clear Python
    # dependencies and avoid cluttered environment.
    if [ x"$(which pip)" == x"" ]; then
        print_warn "pip not found !!!"
        print_topic "Automatically run \"$ scripts/setup-pip.sh install\" ..."
        run_cmd "./scripts/setup-pip.sh install"
    fi

    if [ x"$(which virtualenv)" == x"" ]; then
        print_warn "virtualenv not found !!!"
        print_topic "Automatically install virtualenv"
        run_cmd "pip install -U virtualenv"
    fi
}

######################################
# Main installation flow
######################################

if [ x"$CHOICE" == x"all" ]; then
    print_banner "Install: all (a new system)"
    install_packages
    setup_misc
    install_helper_scripts
    setup_vncserver
    install_git_credential_manager_latest
    setup_fuse_conf
    setup_python_virtualenv

    print_banner "Machine environment setup: COMPLETE."
    print_topic "Now, you may source ~/.bashrc to refresh"
    print_topic "Next, you may generate ssh key-pair: ssh-keygen -t ed25519 -C \"someone@gmail.com\" "
fi

if [ x"$CHOICE" == x"mycmd" ]; then
    print_banner "Install: mycmd (own convenient scripts)"
    install_helper_scripts
    print_topic "Install: mycmd : Completed"
    run_cmd mycmd
fi

if [ x"$CHOICE" == x"package" ]; then
    print_banner "Install: package (Software Package)"
    install_packages
    print_topic "Install: package : Completed"
fi

if [ x"$CHOICE" == x"python" ]; then
    print_banner "Install: Python environment"
    setup_python_virtualenv
    print_topic "Install: Python environment : Completed"
fi

if [ x"$CHOICE" == x"myenv" ]; then
    print_banner "Install: myenv (Development environment)"
    setup_misc
    setup_vncserver
    install_git_credential_manager_latest
    setup_fuse_conf

    print_banner "Machine environment setup: COMPLETE."
    print_topic "Now, you may source ~/.bashrc to refresh"
    print_topic "Next, you may generate ssh key-pair: ssh-keygen -t ed25519 -C \"someone@gmail.com\" "
fi
