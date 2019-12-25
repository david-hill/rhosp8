#!/bin/bash
#
# This runs an upgrade of Cinder Block Storage nodes.
#
set -eu

<<<<<<< HEAD
# Special-case OVS for https://bugs.launchpad.net/tripleo/+bug/1635205
if [[ -n $(rpm -q --scripts openvswitch | awk '/postuninstall/,/*/' | grep "systemctl.*try-restart") ]]; then
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

# Special-case OVS for https://bugs.launchpad.net/tripleo/+bug/1635205
special_case_ovs_upgrade_if_needed
>>>>>>> 2c04151dedaa435a2a927377b4e5fa042b8fb6c0

yum -y install python-zaqarclient  # needed for os-collect-config
yum -y -q update
