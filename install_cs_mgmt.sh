#!/bin/bash
set -x

VM_NAME="centostest3"
export XE_EXTRA_ARGS="server=$1,username=root,password=$2"
TEMPLATE="CentOS 6 (64-bit)"

VM=`xe vm-install template="$TEMPLATE" new-name-label=$VM_NAME`
xe vm-param-set uuid=$VM other-config:install-repository=http://www.mirrorservice.org/sites/mirror.centos.org/6.5/os/x86_64/
NETWORK=`xe network-list bridge=xenbr0 --minimal`
VIF=`xe vif-create vm-uuid=$VM network-uuid=$NETWORK device=0`

NETWORK2=`xe network-list bridge=xapi1 --minimal`
VIF2=`xe vif-create vm-uuid=$VM network-uuid=$NETWORK2 device=1`

xe vm-disk-remove vm="$VM" device=0
xe vm-disk-add vm="$VM" device=0 disk-size=32GiB

xe vm-param-set uuid=$VM PV-args="ks=http://www.uk.xensource.com/~jludlam/centos-6.5-x86_64.ks ksdevice=eth0"
VBD=`xe vbd-list vm-uuid=$VM --minimal`
xe vbd-param-set uuid=$VBD bootable=true
xe vm-cd-add vm="$VM" cd-name=xs-tools.iso device=3
xe vm-start vm="$VM"

echo $VM

