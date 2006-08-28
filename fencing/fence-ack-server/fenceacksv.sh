#!/bin/bash
#
# $Id: fenceacksv.sh,v 1.1 2006-08-28 16:04:46 marc Exp $
#
# chkconfig: 345 24 76
# description: Starts and stops fenceacksv
#
#
### BEGIN INIT INFO
# Provides:
### END INIT INFO

. /etc/init.d/functions

FENCEACKDIR="/opt/atix/comoonics-fenceacksv"
FENCEACKSV="fenceacksv"
FENCEACKSV_PARAMS="--xml --xml-clusterconf --xml-novalidate --debug"
FENCEACKSV_LOG="/var/log/fenceacksv.log"
LOCK_FILE="/var/lock/subsys/${FENCEACKSV}"

[ -f /etc/sysconfig/cluster ] && . /etc/sysconfig/cluster
[ -f /etc/sysconfig/fenceacksv ] && . /etc/sysconfig/fenceacksv

start()
{
  if ! pidof fenceacksv > /dev/null; then
  	nodename=$(cman_tool status | awk '/Node name: /{ print $3; exit 0;}')
    echo -n "Starting fenceacksv: "
    [ ! -d ${FENCE_CHROOT}/dev/pts ] && mkdir ${FENCE_CHROOT}/dev/pts
    mount -t devpts none ${FENCE_CHROOT}/dev/pts &&
    chroot ${FENCE_CHROOT} /bin/bash -c "${FENCEACKDIR}/${FENCEACKSV} ${FENCEACKSV_PARAMS} --nodename $nodename /etc/cluster/cluster.conf 2>&1 | /usr/bin/logger -t $FENCEACKSV &"
    rtrn=$?
    if [ $rtrn -eq 0 ]; then success; else failure; fi
    echo
    return $rtrn
  fi
}

stop()
{
  echo -n "Stopping fenceacksv:"
  killproc ${FENCEACKSV} -TERM
  rtrn=$?
  umount ${FENCE_CHROOT}/dev/pts &>/dev/null
  if [ $rtrn -eq 0 ]; then success; else failure; fi
  echo
  return $rtrn
}

rtrn=1

# See how we were called.
case "$1" in
  start)
    start
    rtrn=$?
    [ $rtrn = 0 ] && touch $LOCK_FILE
    ;;

  stop)
    stop
    rtrn=$?
    [ $rtrn = 0 ] && rm -f $LOCK_FILE
    ;;

  restart)
    if stop; then
       start
    fi
    rtrn=$?
    ;;

  status)
    status fenceacksv
    rtrn=0
    ;;

  *)
    echo $"Usage: $0 {start|stop|restart|status}"
    ;;
esac

exit $rtrn
######################
# $Log: fenceacksv.sh,v $
# Revision 1.1  2006-08-28 16:04:46  marc
# initial revision
#