#!/bin/bash
#
# This delivers the swift-storage upgrade script to be invoked as part of the tripleo
# major upgrade workflow.
#
set -eu

UPGRADE_SCRIPT=/root/tripleo_upgrade_node.sh

cat > $UPGRADE_SCRIPT << ENDOFCAT
### DO NOT MODIFY THIS FILE
### This file is automatically delivered to the swift-storage nodes as part of the
### tripleo upgrades workflow


function systemctl_swift {
    action=\$1
    for S in openstack-swift-account-auditor openstack-swift-account-reaper openstack-swift-account-replicator openstack-swift-account \
             openstack-swift-container-auditor openstack-swift-container-replicator openstack-swift-container-updater openstack-swift-container \
             openstack-swift-object-auditor openstack-swift-object-replicator openstack-swift-object-updater openstack-swift-object; do
                systemctl \$action \$S
    done
}

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

systemctl_swift stop

yum -y install python-zaqarclient  # needed for os-collect-config
yum -y update

systemctl_swift start



ENDOFCAT

# ensure the permissions are OK
chmod 0755 $UPGRADE_SCRIPT

