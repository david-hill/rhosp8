#!/bin/bash

set -eu

function check_resource {

  if [ "$#" -ne 3 ]; then
      echo_error "ERROR: check_resource function expects 3 parameters, $# given"
      exit 1
  fi

  service=$1
  state=$2
  timeout=$3

  if [ "$state" = "stopped" ]; then
      match_for_incomplete='Started'
  else # started
      match_for_incomplete='Stopped'
  fi

  if timeout -k 10 $timeout crm_resource --wait; then
      node_states=$(pcs status --full | grep "$service" | grep -v Clone)
      if echo "$node_states" | grep -q "$match_for_incomplete"; then
          echo_error "ERROR: cluster finished transition but $service was not in $state state, exiting."
          exit 1
      else
        echo "$service has $state"
      fi
  else
      echo_error "ERROR: cluster remained unstable for more than $timeout seconds, exiting."
      exit 1
  fi

}

function echo_error {
    echo "$@" | tee /dev/fd2
}

function systemctl_swift {
    services=( openstack-swift-account-auditor openstack-swift-account-reaper openstack-swift-account-replicator openstack-swift-account \
               openstack-swift-container-auditor openstack-swift-container-replicator openstack-swift-container-updater openstack-swift-container \
               openstack-swift-object-auditor openstack-swift-object-replicator openstack-swift-object-updater openstack-swift-object openstack-swift-proxy )
    action=$1
    case $action in
        stop)
            services=$(systemctl | grep swift | grep running | awk '{print $1}')
            ;;
        start)
            enable_swift_storage=$(hiera -c /etc/puppet/hiera.yaml 'enable_swift_storage')
            if [[ $enable_swift_storage != "true" ]]; then
                services=( openstack-swift-proxy )
            fi
            ;;
        *)  services=() ;;  # for safetly, should never happen
    esac
    for S in ${services[@]}; do
        systemctl $action $S
    done
}

# Special-case OVS for https://bugs.launchpad.net/tripleo/+bug/1635205
function special_case_ovs_upgrade_if_needed {
    if [[ -n $(rpm -q --scripts openvswitch | awk '/postuninstall/,/*/' | grep "systemctl.*try-restart") ]]; then
        echo "Manual upgrade of openvswitch - restart in postun detected"
        rm -rf OVS_UPGRADE
        mkdir OVS_UPGRADE && pushd OVS_UPGRADE
        echo "Attempting to downloading latest openvswitch with yumdownloader"
        yumdownloader --resolve openvswitch
        for pkg in $(ls -1 *.rpm);  do
            if rpm -U --test $pkg 2>&1 | grep "already installed" ; then
                echo "Looks like newer version of $pkg is already installed, skipping"
            else
                echo "Updating $pkg with nopostun option"
                rpm -U --replacepkgs --nopostun $pkg
            fi
        done
        popd
    else
        echo "Skipping manual upgrade of openvswitch - no restart in postun detected"
    fi

}

