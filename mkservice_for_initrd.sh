#!/bin/bash
# $Id: mkservice_for_initrd.sh,v 1.1 2006-08-28 16:02:44 marc Exp $
# Creates a chroot for the given service and starts the service

exec 3>/dev/null

function _usage {
  echo "$0 chroot [service] nostart|[params]"
  echo "Starts the given service in chroot. With given params and follows the process defined by the initrd."
  echo "If nostart service will not be started"
}

dir=$(dirname $0)
source ${dir}/boot-scripts/etc/boot-lib.sh

chroot=$1
if [ ! -d "$chroot" ]; then
	_usage
	exit 1
fi
shift
service=$1
if [ ! -e "$service" ]; then
	_usage
	exit 1
fi
shift

[ -d ${chroot}.bak ] && rm -rf ${chroot}.bak
[ -d ${chroot} ] && mv -f ${chroot} ${chroot}.bak && mkdir $chroot
start_service ${chroot} ${service} ${dir}/boot-scripts/etc/ onlycopy nofailback $*

#######################
# $Log: mkservice_for_initrd.sh,v $
# Revision 1.1  2006-08-28 16:02:44  marc
# initial revision
#