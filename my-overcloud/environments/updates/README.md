This directory contains Heat environment file snippets which can
be used to ensure smooth updates of the Overcloud.

Contents
--------

**update-from-keystone-admin-internal-api.yaml**
  To be used if the Keystone Admin API was originally deployed on the
  Internal API network.

**update-from-publicvip-on-ctlplane.yaml**
  To be used if the PublicVirtualIP resource was deployed as an additional VIP on the 'ctlplane'.
**update-from-vip.yaml**
  To be used if the VIP resources were mapped to VipPort (vip.yaml) during the initial Overcloud deployment.