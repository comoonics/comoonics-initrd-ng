#!/bin/bash
JOBNAME=${1:-"nfsclusterconf1"}
source ${JOBNAME}/virt.sh
source ${JOBNAME}/vm1.sh
echo "First clean up old storage files.."
virsh vol-delete $VM_DISK1
echo "Ignore Error if disk does not exist."

echo "First the template machine for installation has to be cloned.."
virt-clone --connect=$LIBVIRT_URL --name="$VM_NAME" --original="$VM_SOURCE_NAME" --mac="$VM_NIC1_MAC" --replace --file=$VM_DISK1 --quiet --force && \
echo "Success" || { echo "Failed"; exit 1; }
