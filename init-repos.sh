#!/bin/bash
#
# ./init-repos.sh
# ./init-repos.sh dryrun
#

DRYRUN=$1

GITHUB_REPOS=" \
    https://github.com/elvinongbl/dev-machine-env.git \
    https://github.com/elvinongbl/self-learning-materials.git \
    https://github.com/elvinongbl/devnotes.git \
    https://github.com/elvinongbl/dev-machine-setup.git \
    https://github.com/elvinongbl/sys-tools.git \
"

PUBLIC_REPOS=" \
    https://github.com/chipsec/chipsec.git \
    https://git.kernel.org/pub/scm/devel/pahole/pahole.git \
    git://sourceware.org/git/elfutils.git \
    https://github.com/tianocore/edk2-staging.git \
    https://github.com/intel/iotg_tsn_ref_sw.git \
    https://github.com/richardcochran/linuxptp.git \
    https://git.kernel.org/pub/scm/network/iproute2/iproute2.git \
    https://git.kernel.org/pub/scm/network/iproute2/iproute2-next.git \
    https://git.kernel.org/pub/scm/network/ethtool/ethtool.git \
    https://github.com/llvm/llvm-project.git \
    https://github.com/open62541/open62541.git \
    https://github.com/mirror/busybox.git \
    https://github.com/nmap/nmap.git \
    https://github.com/a-j-wood/pv.git \
    https://github.com/lldpd/lldpd.git \
    https://github.com/DPDK/dpdk.git \
    https://github.com/wireshark/wireshark.git \
    https://github.com/the-tcpdump-group/tcpdump \
    https://github.com/the-tcpdump-group/libpcap \
    https://github.com/getpatchwork/git-pw \
    git://git.kernel.org/pub/scm/utils/rt-tests/rt-tests.git \
    git://github.com/acpica/acpica.git \
"

NETWORKING_REPOS=" \
   https://gitlab.com/etherlab.org/ethercat.git \
   https://github.com/Mellanox/sockperf.git \
"

BPFXDP_REPOS=" \
    https://github.com/xdp-project/xdp-project.git \
    https://github.com/xdp-project/xdp-tutorial.git \
    https://github.com/xdp-project/bpf-examples.git \
    https://github.com/xdp-project/xdp-tools.git \
    https://github.com/xdp-project/xdp-cpumap-tc.git \
    https://github.com/libbpf/libbpf.git \
    https://git.kernel.org/pub/scm/linux/kernel/git/bpf/bpf-next.git \
    https://git.kernel.org/pub/scm/linux/kernel/git/bpf/bpf.git \
    https://github.com/polycube-network/polycube.git \
    https://github.com/iovisor/bcc.git \
    https://github.com/iovisor/bpftrace.git \
"

NETCONF_REPOS=" \
    http://git.libssh.org/projects/libssh.git \
    https://github.com/CESNET/libnetconf2.git \
    https://github.com/CESNET/libyang.git \
    https://github.com/CESNET/netopeer2.git \
    https://github.com/sysrepo/sysrepo.git \
    https://github.com/YangModels/yang.git \
"

LINUX_REPOS=" \
    https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git \
    https://git.kernel.org/pub/scm/linux/kernel/git/rt/linux-rt-devel.git \
    https://git.kernel.org/pub/scm/linux/kernel/git/netdev/net-next.git \
    https://git.kernel.org/pub/scm/linux/kernel/git/netdev/net.git \
    https://github.com/intel/linux-intel-lts.git \
    git://git.kernel.org/pub/scm/devel/sparse/sparse.git \
    https://github.com/kuba-moo/nipa.git \
"

YOCTO_REPOS=" \
    https://github.com/intel/iotg-yocto-bsp-public.git \
    https://git.yoctoproject.org/git/poky \
"

LEARNING_REPOS=" \
    https://github.com/bpftools/linux-observability-with-bpf.git \
"

VT_REPOS=" \
    https://github.com/libvirt/libvirt.git \
    https://github.com/qemu/qemu.git \
"

TRACING_REPOS=" \
    git://git.kernel.org/pub/scm/libs/libtrace/libtraceevent.git \
    git://git.kernel.org/pub/scm/libs/libtrace/libtracefs.git \
    https://github.com/bristot/rtsl.git \
    https://git.kernel.org/pub/scm/utils/trace-cmd/trace-cmd.git \
    https://github.com/nicolargo/glances.git \
    https://github.com/phoronix-test-suite/phoronix-test-suite.git \
"

CLOUDNATIVE_REPOS=" \
    https://github.com/CloudNativeDataPlane/cndp.git \
    https://github.com/ipdk-io/ipdk.git \
"

SANDBOX_REPOS=" \
    https://github.com/intel-sandbox/personal.bong5.kensho-kit.git \
"

function run_cmd() {
    COLOR='\033[0;36m'
    NCOLOR='\033[0m'
    echo -e "$COLOR\$ $@ $NCOLOR"
    if [ x"$DRYRUN" != x"dryrun" ]; then
        eval $@
    fi
}

function git_clone_repos() {
    NCOLOR='\033[0m'
    DESTDIR=$1
    shift
    REPOS=$@
    CWD=$(pwd)
    run_cmd mkdir -p $DESTDIR
    run_cmd cd $DESTDIR
    for url in $REPOS; do
        topdir=$(dirname $url)
        reponame=$(echo $url | grep -o -P "(?<=$topdir/).*(?=.git)|(?<=$topdir/).*")
        if [ ! -d $reponame ]; then
            echo -e "${NCOLOR}Cloning ... $DESTDIR/$reponame"
            run_cmd git clone $url $reponame
        else
            echo -e "${NCOLOR}Detected ... $DESTDIR/$reponame"
            run_cmd cd $DESTDIR/$reponame
            run_cmd git pull --rebase
            run_cmd cd ..
        fi
    done
    run_cmd cd $CWD
}

git_clone_repos ~/own-repos $GITHUB_REPOS
git_clone_repos ~/public-repos $PUBLIC_REPOS
git_clone_repos ~/public-repos/oss-linux $LINUX_REPOS
git_clone_repos ~/public-repos/oss-yocto $YOCTO_REPOS
git_clone_repos ~/public-repos/oss-bpf $BPFXDP_REPOS
git_clone_repos ~/public-repos/oss-netconf $NETCONF_REPOS
git_clone_repos ~/public-repos/oss-learning $LEARNING_REPOS
git_clone_repos ~/public-repos/oss-virtualization $VT_REPOS
git_clone_repos ~/public-repos/oss-tracing $TRACING_REPOS
git_clone_repos ~/public-repos/oss-networking $NETWORKING_REPOS
git_clone_repos ~/public-repos/oss-cloudnative $CLOUDNATIVE_REPOS
git_clone_repos ~/sandbox-repos $SANDBOX_REPOS

