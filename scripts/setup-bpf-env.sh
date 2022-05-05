#!/bin/bash

PAHOLE_VERSION=v1.23
LLVM_VERSION=llvmorg-14.0.0
ELFUTILS_VERSION=elfutils-0.186

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

# https://sourceware.org/elfutils/
# http://cgit.openembedded.org/openembedded-core/tree/meta/recipes-devtools/elfutils/elfutils_0.186.bb?h=master
function install_elfutils() {
    if [ -d $HOME/public-repos/elfutils ]; then
        run_cmd sudo apt install autopoint libzip-dev
        run_cmd CWD=$(pwd)
        run_cmd cd $HOME/public-repos/elfutils
        run_cmd git checkout ${ELFUTILS_VERSION}

        # autoreconf requires autopoint
        run_cmd autoreconf -i -f
        run_cmd ./configure --prefix=/usr --disable-debuginfod --enable-libdebuginfod=dummy
        run_cmd make
        run_cmd make check
        run_cmd sudo make -C libelf install
        run_cmd sudo install -vm644 config/libelf.pc /usr/lib/pkgconfig

        run_cmd git checkout master
        run_cmd sudo ldconfig
        run_cmd cd $CWD
    else
        echo -e "elfutils is not found. Please run init-repos.sh first"
        exit
    fi
}

# pahole (Poke-a-hole) is used to find "hole" in data-structure to make binary is optimized.
# To analyze the object files, the source must be compiled with the debugging flag "-g". In the kernel,
# this is activated by CONFIG_DEBUG_INFO, or "Kernel Hacking > Compile the kernel with debug info".
#
# pahole shows data structure layouts encoded in debugging information formats, DWARF, CTF and BTF being supported.
# This is useful for, among other things: optimizing important data structures by reducing its size,
# figuring out what is the field sitting at an offset from the start of a data structure, investigating ABI
# changes and more generally understanding a new codebase you have to work with.
#
# Reference:
# * https://lwn.net/Articles/335942/
# * https://landley.net/kdocs/ols/2007/ols2007v2-pages-35-44.pdf
function install_pahole() {
    if [ -d $HOME/public-repos/pahole ]; then
        # dwarves depends on DWARF
        run_cmd sudo apt install libdw-dev
        run_cmd CWD=$(pwd)
        run_cmd cd $HOME/public-repos/pahole
        run_cmd git checkout ${PAHOLE_VERSION}
        run_cmd rm -rf build
        run_cmd mkdir -p build
        run_cmd cd build
        run_cmd cmake -D__LIB=lib ..
        run_cmd sudo make install
        run_cmd cd $HOME/public-repos/pahole
        run_cmd git checkout master
        run_cmd sudo ldconfig
        run_cmd cd $CWD
        run_cmd pahole --version
    else
        echo -e "pahole is not found. Please run init-repos.sh first"
        exit
    fi
}

# https://git.kernel.org/pub/scm/linux/kernel/git/netdev/net-next.git/tree/Documentation/bpf/bpf_devel_QA.rst
# https://llvm.org/docs/GettingStarted.html#getting-the-source-code-and-building-llvm
function install_llvm() {
    if [ -d $HOME/public-repos/llvm-project ]; then
       run_cmd sudo apt install ninja-build
       run_cmd CWD=$(pwd)
       run_cmd cd $HOME/public-repos/llvm-project/
       run_cmd git checkout ${LLVM_VERSION}
       run_cmd rm -rf llvm/build
       run_cmd mkdir -p llvm/build
       run_cmd cd llvm/build
       print_cmd 'cmake .. -G "Ninja" -DLLVM_TARGETS_TO_BUILD="BPF;X86" -DLLVM_ENABLE_PROJECTS="clang" -DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi" -DCMAKE_INSTALL_PREFIX="/usr/local" -DCMAKE_BUILD_TYPE=Release -DLLVM_BUILD_RUNTIME=OFF'
       cmake .. -G "Ninja" -DLLVM_TARGETS_TO_BUILD="BPF;X86" -DLLVM_ENABLE_PROJECTS="clang" -DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi" -DCMAKE_INSTALL_PREFIX="/usr/local" -DCMAKE_BUILD_TYPE=Release -DLLVM_BUILD_RUNTIME=OFF
       run_cmd ninja
       run_cmd sudo ninja install
       run_cmd cd $HOME/public-repos/llvm-project/
       run_cmd git checkout master
       run_cmd which llc
       run_cmd llc --version
       run_cmd cd $CWD
    else
       echo -e "llwm-project is not found. Please run init-repos.sh first"
       exit
    fi
}

function setup_linux_bpf_env() {
       # To build linux/samples/bpf, we need below software package
       run_cmd sudo apt install -y libcap-dev
}

install_elfutils
install_llvm
install_pahole
setup_linux_bpf_env
