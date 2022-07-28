#!/bin/bash

# For debian system:-
#
# Build Linux kernel with cgroup, namespace, KVM, VHOST and virtualization support
#
# CONFIG_HAVE_KVM=y
# CONFIG_HAVE_KVM_PFNCACHE=y
# CONFIG_HAVE_KVM_IRQCHIP=y
# CONFIG_HAVE_KVM_IRQFD=y
# CONFIG_HAVE_KVM_IRQ_ROUTING=y
# CONFIG_HAVE_KVM_DIRTY_RING=y
# CONFIG_HAVE_KVM_EVENTFD=y
# CONFIG_KVM_MMIO=y
# CONFIG_KVM_ASYNC_PF=y
# CONFIG_HAVE_KVM_MSI=y
# CONFIG_HAVE_KVM_CPU_RELAX_INTERCEPT=y
# CONFIG_KVM_VFIO=y
# CONFIG_KVM_GENERIC_DIRTYLOG_READ_PROTECT=y
# CONFIG_HAVE_KVM_IRQ_BYPASS=y
# CONFIG_HAVE_KVM_NO_POLL=y
# CONFIG_KVM_XFER_TO_GUEST_WORK=y
# CONFIG_HAVE_KVM_PM_NOTIFIER=y
# CONFIG_KVM=y
# CONFIG_KVM_WERROR=y
# CONFIG_KVM_INTEL=y
#
# CONFIG_VHOST_IOTLB=y
# CONFIG_VHOST=y
# CONFIG_VHOST_MENU=y
# CONFIG_VHOST_NET=y
# CONFIG_VHOST_CROSS_ENDIAN_LEGACY=y
#
# 1/ vi /etc/default/grub, add intel_iommu=on
# 2/ sudo update-grub2
# 3/ sudo reboot
#
# 1/ sudo apt install qemu-utils virt-manager cgroup-tools cgroupfs-mount
# 2/ sudo cgroupfs-mount
# 3/ sudo virt-host-validate

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

function show_iommu() {
    print_topic IOMMU warning detected, please enable it on GRUB as follow:
    print_topic Add 'intel_iommu=on' to GRUB_CMDLINE_LINUX
    print_cmd vi /etc/default/grub
    print_cmd update-grub2
    print_cmd systemctl reboot -i
}

function show_secureguest() {
    print_topic Secure guest support warning detected, for AMD SEV only
}

function check_virt_readiness() {
    sudo virt-host-validate
    iommu_warn=$(sudo virt-host-validate | grep WARN | grep -c IOMMU)
    if [ $iommu_warn -eq 1 ]; then
        show_iommu
    fi

    secureguest_warn=$(sudo virt-host-validate | grep WARN | grep -c "secure guest")
    if [ $secureguest_warn -eq 1 ]; then
        show_secureguest
    fi
}

check_virt_readiness
