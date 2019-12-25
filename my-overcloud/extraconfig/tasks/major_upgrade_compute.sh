#!/bin/bash
#
# This delivers the compute upgrade script to be invoked as part of the tripleo
# major upgrade workflow.
#
set -eu

UPGRADE_SCRIPT=/root/tripleo_upgrade_node.sh

cat > $UPGRADE_SCRIPT << ENDOFCAT
### DO NOT MODIFY THIS FILE
### This file is automatically delivered to the compute nodes as part of the
### tripleo upgrades workflow

# pin nova to kilo (messaging +-1) for the nova-compute service

crudini  --set /etc/nova/nova.conf upgrade_levels compute $upgrade_level_nova_compute

<<<<<<< HEAD
# Special-case OVS for https://bugs.launchpad.net/tripleo/+bug/1635205
if [[ -n \$(rpm -q --scripts openvswitch | awk '/postuninstall/,/*/' | grep "systemctl.*try-restart") ]]; then
    echo "Manual upgrade of openvswitch - restart in postun detected"
    mkdir OVS_UPGRADE || true
    pushd OVS_UPGRADE
    echo "Attempting to downloading latest openvswitch with yumdownloader"
    yumdownloader --resolve openvswitch
    echo "Updating openvswitch with nopostun option"
    rpm -U --replacepkgs --nopostun ./*.rpm
    popd
else
    echo "Skipping manual upgrade of openvswitch - no restart in postun detected"
fi
=======
# Always ensure yum has full cache
yum makecache || echo "Yum makecache failed. This can cause failure later on."

$(declare -f special_case_ovs_upgrade_if_needed)
special_case_ovs_upgrade_if_needed
>>>>>>> 2c04151dedaa435a2a927377b4e5fa042b8fb6c0

yum -y install python-zaqarclient  # needed for os-collect-config
yum -y install openstack-nova-migration # needed for libvirt migration via ssh
yum -y update

ENDOFCAT

# ensure the permissions are OK
chmod 0755 $UPGRADE_SCRIPT

