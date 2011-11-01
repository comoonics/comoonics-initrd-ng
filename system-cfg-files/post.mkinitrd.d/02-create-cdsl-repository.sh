#!/bin/sh
MKCDSLINFRASTRUCTURE=${MKCDSLINFRASTRUCTURE:-"/usr/bin/com-cdslinvadm"}

NOCDSL="nocdsl"

tree="$NOCDSL"
link="$NOCDSL"

if ! [ -d ${DESTDIR} ]; then
  mkdir -p ${DESTDIR}
fi

if [ -e "$MKCDSLINFRASTRUCTURE" ]; then
  echo_local -n -N " cdsl env "
  tree=$($MKCDSLINFRASTRUCTURE --get tree || echo "$NOCDSL")
  link=$($MKCDSLINFRASTRUCTURE --get link || echo "$NOCDSL")
fi
repository_store_value cdsl_prefix "$tree"  &&
repository_store_value cdsl_local_dir "$link" &&
unset tree
unset link

##############
# $Log: 02-create-cdsl-repository.sh,v $
# Revision 1.3  2011-02-16 14:32:40  marc
# - implemented that it might also work without existant cdsl environment.
#
