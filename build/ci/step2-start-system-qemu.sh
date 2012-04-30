#!/bin/bash
JOBNAME=${1:-"nfsclusterconf1"}
source ${JOBNAME}/virt.sh
source ${JOBNAME}/vm1.sh

echo "Now starting the cloned machine and waiting for it to be up and running"
virsh -c $LIBVIRT_URL start $VM_NAME && echo "SUCCESS" || { echo "FAILED"; exit 2; }

echo "Waiting for machine to be up and running.."
