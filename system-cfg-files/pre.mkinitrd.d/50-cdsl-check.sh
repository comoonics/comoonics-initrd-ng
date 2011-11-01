#!/bin/bash
MKCDSLINFRASTRUCTURE=${MKCDSLINFRASTRUCTURE:-"/usr/bin/com-cdslinvadm"}

# Check if the binary exists
if [ -e "$MKCDSLINFRASTRUCTURE" ]; then
  $MKCDSLINFRASTRUCTURE --list >/dev/null
fi