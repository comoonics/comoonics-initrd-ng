b#!/bin/bash

source $(dirname $0)/etc/boot-lib.sh

#debug="true"
stepmode="true"

echo_local "3.2 Importing unconfigured scsi-devices..."
devs=$(find /proc/scsi -name "[0-9]*" 2>/dev/null)
channels=0
for dev in $devs; do 
  for channel in $channels; do
    id=$(basename $dev)
    echo_local -n "3.2.$id On id $id and channel $channel"
    exec_local add_scsi_device $id $channel $dev
  done
done
echo_local_debug "3.3 Configured SCSI-Devices:"
exec_local_debug /bin/cat /proc/scsi/scsi
step
