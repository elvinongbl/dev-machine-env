#!/bin/bash
# Simple script to list version numbers of critical development tools
# https://lfs-hk.koddos.net/lfs/view/stable/chapter02/hostreqs.html

function print_topic() {
    echo -e "\n# $@"
}

function run_cmd() {
    # 30 - black    31 - red
    # 32 - green    33 - yellow
    # 34 - blue     35 - magenta
    # 36 - cyan     37 - white
    CYAN='\033[0;36m'
    YELLOW='\033[0;33m'

    echo -e "$CYAN\$ $@ $YELLOW"
    if [ x"$DRYRUN" != x"dryrun" ]; then
        eval $@
    fi
}

function print_cmd() {
    COLOR='\033[0;36m'
    NCOLOR='\033[0m'
    echo -e "$COLOR\$ $@ $NCOLOR"
}

function print_warn() {
    RED='\033[0;31m'
    WHITE='\033[0m'
    echo -e "$RED $@ $WHITE"
}

function print_info() {
    YELLOW='\033[0;33m'
    WHITE='\033[0m'
    echo -e "$YELLOW $@ $WHITE"
}

export LC_ALL=C
run_cmd ' bash --version | head -n1 | cut -d" " -f2-4 '

run_cmd ' MYSH=$(readlink -f /bin/sh) '
run_cmd ' echo "/bin/sh -> $MYSH" '
run_cmd ' echo $MYSH | grep -q bash || print_warn "ERROR: /bin/sh does not point to bash. $ ln -sf /bin/bash /bin/sh " '
unset MYSH

run_cmd ' echo -n "Binutils: "; ld --version | head -n1 | cut -d" " -f3- '
run_cmd ' bison --version | head -n1 '

if [ -h /usr/bin/yacc ]; then
  run_cmd ' echo "/usr/bin/yacc -> `readlink -f /usr/bin/yacc`"; '
elif [ -x /usr/bin/yacc ]; then
  run_cmd ' echo yacc is `/usr/bin/yacc --version | head -n1` '
else
  print_warn "yacc not found"
fi

run_cmd ' bzip2 --version 2>&1 < /dev/null | head -n1 | cut -d" " -f1,6- '
run_cmd ' echo -n "Coreutils: "; chown --version | head -n1 | cut -d")" -f2 '
run_cmd ' diff --version | head -n1 '
run_cmd ' find --version | head -n1 '
run_cmd ' gawk --version | head -n1 '

if [ -h /usr/bin/awk ]; then
  run_cmd ' echo "/usr/bin/awk -> `readlink -f /usr/bin/awk`"; '
elif [ -x /usr/bin/awk ]; then
  run_cmd ' echo awk is `/usr/bin/awk --version | head -n1` '
else
  print_warn "awk not found"
fi

run_cmd ' gcc --version | head -n1 '
run_cmd ' g++ --version | head -n1 '
run_cmd ' ldd --version | head -n1 | cut -d" " -f2- ' # glibc version
run_cmd ' grep --version | head -n1 '
run_cmd ' gzip --version | head -n1 '
run_cmd ' cat /proc/version '
run_cmd ' m4 --version | head -n1 '
run_cmd ' make --version | head -n1 '
run_cmd ' patch --version | head -n1 '
run_cmd ' echo Perl `perl -V:version` '
run_cmd ' python3 --version '
run_cmd ' sed --version | head -n1 '
run_cmd ' tar --version | head -n1 '
run_cmd ' makeinfo --version | head -n1 ' # texinfo version
run_cmd ' xz --version | head -n1 '

run_cmd ' echo "int main(){}" > dummy.c && g++ -o dummy dummy.c '
if [ -x dummy ]
  then print_info ' g++ compilation OK '
  else print_warn 'g++ compilation failed '
  fi
run_cmd ' rm -f dummy.c dummy '
