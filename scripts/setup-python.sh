#!/bin/bash
#
# Development using the system package installed Python is often
# not desirable due to it is fairly old. To install multiple
# Python version on the system, we can use pyenv.
#
# To enable pyenv, we need to pre-install all the dependency
# according to 'install dependencies' in [1]


PROGNAME=setup-python.sh
COMMAND=$1

usage() {
cat << EOF
  $ ./${PROGNAME} <COMMAND>
      COMMAND:
        show:                   Show current CPython installed by pyenv
        prepare:                Pre-install software dependency
        install <version>:      Build and install Python version using pyenv
        uninstall <version>:    Uninstall Python version using pyenv
        switch <version>:       Switch to a desired Python version
        test <version>:         Sanity test a particular Python version
        list <regex>:           List available Python version according to regex
        help:                   Print the usage
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
    eval $@
}

function print_cmd() {
    COLOR='\033[0;36m'
    NCOLOR='\033[0m'
    echo -e "$COLOR\$ $@ $NCOLOR"
}

function prepare_env() {
    print_topic "Install build software dependencies ..."
    run_cmd sudo apt-get update -y
    run_cmd sudo apt-get build-dep -y python3
    run_cmd sudo apt-get install -y build-essential gdb lcov pkg-config \
      libbz2-dev libffi-dev libgdbm-dev libgdbm-compat-dev liblzma-dev \
      libncurses5-dev libreadline6-dev libsqlite3-dev libssl-dev \
      lzma lzma-dev tk-dev uuid-dev zlib1g-dev
    print_topic "Get and execute pyenv installer ..."
    run_cmd 'curl https://pyenv.run | bash'
    print_topic "Note: steps to add pyenv to system has been added through ~/.bash_aliases"
}

function install_python() {
    local VERSION=$1

    run_cmd pyenv install -v $VERSION
}

function uninstall_python() {
    local VERSION=$1

    run_cmd pyenv uninstall $VERSION
}

function switch_python() {
    local VERSION=$1

    print_topic "Switch a specific Python version"
    run_cmd pyenv global $VERSION
}

function test_python() {
    print_topic "Sanity test current Python version"
    run_cmd python -m test
}

function list_python() {
    local REGEX=$1

    print_topic "Available CPython version from open-source Python Project"
    run_cmd pyenv install --list | grep $REGEX
}

function show_python() {
    print_topic "CPython version installed through pyenv locally:"
    run_cmd pyenv versions
}

if [ x"$COMMAND" == x"show" ]; then
    show_python
    exit
fi

if [ x"$COMMAND" == x"prepare" ]; then
    print_topic "Requirement /etc/apt/sources.list:- deb-src http://archive.ubuntu.com/ubuntu/ jammy main or equivalent"
    prepare_env
    exit
fi

if [ x"$COMMAND" == x"install" ]; then
    VERSION=$2
    install_python $VERSION
    exit
fi

if [ x"$COMMAND" == x"uninstall" ]; then
    VERSION=$2
    uninstall_python $VERSION
    exit
fi

if [ x"$COMMAND" == x"switch" ]; then
    VERSION=$2
    switch_python $VERSION
    exit
fi

if [ x"$COMMAND" == x"test" ]; then
    test_python
    exit
fi


if [ x"$COMMAND" == x"list" ]; then
    REGEX=$2

    [ -z $REGEX ] && print_topic "Note: REGEX not set. Default to 3.10" && REGEX="3\.10"

    list_python $REGEX
    exit
fi

usage

# Reference:
# [1] https://devguide.python.org/getting-started/setup-building/index.html#build-dependencies
# [2] https://realpython.com/intro-to-pyenv/