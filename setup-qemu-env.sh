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

