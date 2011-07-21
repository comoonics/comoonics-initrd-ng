#!/bin/bash
MKCDSLINFRASTRUCTURE=${MKCDSLINFRASTRUCTURE:-"/usr/bin/com-mkcdslinfrastructure"}

# Check if the binary exists
if [ -e "$MKCDSLINFRASTRUCTURE" ]; then
  $MKCDSLINFRASTRUCTURE --list >/dev/null
fi