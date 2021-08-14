#!/bin/bash

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

# pahole shows data structure layouts encoded in debugging information formats, DWARF, CTF and BTF being supported.
# This is useful for, among other things: optimizing important data structures by reducing its size,
# figuring out what is the field sitting at an offset from the start of a data structure, investigating ABI
# changes and more generally understanding a new codebase you have to work with.
function install_dwarves() {
    if [ -d $HOME/public-repos/dwarves ]; then
        # dwarves depends on DWARF
        run_cmd sudo apt install libdw-dev
        run_cmd CWD=$(pwd)
        run_cmd cd $HOME/public-repos/dwarves
        run_cmd mkdir -p build
        run_cmd cd build
        run_cmd cmake -D__LIB=lib ..
        run_cmd sudo make install
        run_cmd sudo ldconfig
        run_cmd cd $CWD
        run_cmd pahole --version
    else
        echo -e "dwarves is not found. Please run init-repos.sh first"
        exit
    fi
}

# https://git.kernel.org/pub/scm/linux/kernel/git/netdev/net-next.git/tree/Documentation/bpf/bpf_devel_QA.rst
function install_llvm() {
    if [ -d $HOME/public-repos/llvm-project ]; then
       run_cmd sudo apt install ninja-build
       run_cmd CWD=$(pwd)
       run_cmd cd $HOME/public-repos/llvm-project/llvm/
       run_cmd mkdir -p build
       run_cmd cd build
       print_cmd 'cmake .. -G "Ninja" -DLLVM_TARGETS_TO_BUILD="BPF;X86" -DLLVM_ENABLE_PROJECTS="clang" -DCMAKE_BUILD_TYPE=Release -DLLVM_BUILD_RUNTIME=OFF'
       cmake .. -G "Ninja" -DLLVM_TARGETS_TO_BUILD="BPF;X86" -DLLVM_ENABLE_PROJECTS="clang" -DCMAKE_BUILD_TYPE=Release -DLLVM_BUILD_RUNTIME=OFF
       run_cmd ninja

       llvm_in_path=$(echo $PATH | grep -c llvm)
       if [ x"$llvm_in_path" == x"0" ]; then
            print_cmd "echo -e 'export PATH=$HOME/public-repos/llvm-project/llvm/build/bin:$PATH' >> $HOME/.bash_aliases"
            echo -e 'export PATH=$HOME/public-repos/llvm-project/llvm/build/bin:$PATH' >> $HOME/.bash_aliases
            run_cmd source $HOME/.bashrc
       fi
       run_cmd which llc
       run_cmd llc --version
       run_cmd cd $CWD
    else
       echo -e "llwm-project is not found. Please run init-repos.sh first"
       exit
    fi
}

install_dwarves
install_llvm
