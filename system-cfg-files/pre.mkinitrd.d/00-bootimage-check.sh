#!/bin/bash

VALIDFS="ext3 ext4 nfs gfs ocfs2 gfs2 glusterfs"

if ! rpm -qa 'comoonics-bootimage-listfiles*' | grep "\("$(echo "$VALIDFS" | sed -e 's/[[:space:]][[:space:]]*/\\|/g')"\)" >/dev/null 2>&1; then
  error_local "Could not find any software package of the following types. 
Please choose from one of the listed packages and install:."
  return 1
fi