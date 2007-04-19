#!/bin/bash
#
# comhf_update_chroot
#
# chkconfig: 345 11 99
# description: hotfix for updating the fenced chroot environment 
#
#
### BEGIN INIT INFO
# Provides:
### END INIT INFO


. /etc/init.d/functions

CMD=/opt/atix/comoonics-hf-sysreport/comhf-update_fenced_chroot.sh

start()
{
        echo -n "Updating chroot ..."
		$CMD
		echo
		return $?
}

stop()
{
        return 0
}

rtrn=1

# See how we were called.
case "$1" in
  start)
        start
        rtrn=$?
        ;;

  stop)
        stop
        rtrn=$?
        ;;

  restart)
        $0 stop
        $0 start
        rtrn=$?
        ;;

  *)
        echo $"Usage: $0 {start|stop|restart}"
        ;;
esac

exit $rtrn
