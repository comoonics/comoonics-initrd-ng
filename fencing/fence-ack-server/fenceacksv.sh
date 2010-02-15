#!/bin/bash
#
# $Id: fenceacksv.sh,v 1.5 2010-02-15 14:07:07 marc Exp $
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
FENCEACKSV="fence_ack_server.py"
FENCEACKSV_PARAMS="--xml --xml-clusterconf --debug"
FENCEACKSV_LOG="/var/log/fenceacksv.log"
CHROOT_PATH=$(/opt/atix/comoonics-bootimage/manage_chroot.sh -p) 
CHROOT_START="/opt/atix/comoonics-bootimage/manage_chroot.sh -a start_service" 
CHROOT_STATUS_PID="/opt/atix/comoonics-bootimage/manage_chroot.sh -a status_service_pid" 
CHROOT_STOP_PID="/opt/atix/comoonics-bootimage/manage_chroot.sh -a stop_service_pid" 
LOCK_FILE="/var/lock/subsys/${FENCEACKSV}"

[ -f /etc/sysconfig/cluster ] && . /etc/sysconfig/cluster
[ -f /etc/sysconfig/fenceacksv ] && . /etc/sysconfig/fenceacksv

start()
{
  if ! pidof fenceacksv > /dev/null; then
  	nodename=$(cman_tool status | awk '/Node name: /{ print $3; exit 0;}')
    echo -n "Starting fenceacksv: "
    mkdir -p ${CHROOT_PATH}/var/spool 2>/dev/null
    chroot ${CHROOT_PATH} /bin/bash -c "${FENCEACKDIR}/${FENCEACKSV} ${FENCEACKSV_PARAMS} --nodename $nodename /etc/cluster/cluster.conf 2>&1 | logger -t $FENCEACKSV &"
    rtrn=$?
    if [ $rtrn -eq 0 ]; then success; else failure; fi
    echo
    return $rtrn
  fi
}

stop()
{
  echo -n "Stopping fenceacksv:"
  killall ${FENCEACKSV}
  rtrn=$?
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
# Revision 1.5  2010-02-15 14:07:07  marc
# - moved to latest version
# - fixed bug in initscript
#
# Revision 1.4  2009/07/01 09:33:39  marc
# fixed bug with logger.
#
# Revision 1.3  2008/09/10 12:49:14  marc
# fixed bug #264 where fenceacksv could not be stopped
#
# Revision 1.2  2007/08/06 15:57:05  mark
# support for bootimage 1.3
#
# Revision 1.1  2006/08/28 16:04:46  marc
# initial revision
#