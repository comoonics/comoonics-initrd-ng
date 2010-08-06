#!/bin/bash
#
# $Id: fenceacksv.sh,v 1.11 2010-08-06 13:33:33 marc Exp $
#
# chkconfig: 345 24 76
# description: Starts and stops fenceacksv
#
#
### BEGIN INIT INFO
# Provides:
### END INIT INFO

. /etc/init.d/functions


RETVAL=0
prog="sshd"

# Some functions to make the below more readable
FENCEACKDIR="/opt/atix/comoonics-fenceacksv"
SSHDIR="/etc/ssh"
FENCEACKSV="fence_ack_server.py"
FENCEACKSV_PARAMS="--xml --xml-clusterconf --debug"
FENCEACKSV_LOG="/var/log/fenceacksv.log"
FENCEACKSV_PORT=12242
FENCEACKSV_SHELL=${FENCEACKDIR}/shell.py
CHROOT_PATH=$(/opt/atix/comoonics-bootimage/manage_chroot.sh -p) 
CHROOT_START="/opt/atix/comoonics-bootimage/manage_chroot.sh -a start_service" 
CHROOT_STATUS_PID="/opt/atix/comoonics-bootimage/manage_chroot.sh -a status_service_pid" 
CHROOT_STOP_PID="/opt/atix/comoonics-bootimage/manage_chroot.sh -a stop_service_pid" 
LOCK_FILE="/var/lock/subsys/${FENCEACKSV}"
KEYGEN=/usr/bin/ssh-keygen
SSHD="chroot ${CHROOT_PATH} /usr/sbin/sshd -p $FENCEACKSV_PORT -e"
RSA1_KEY=${SSHDIR}/ssh_host_key
RSA_KEY=${SSHDIR}/ssh_host_rsa_key
DSA_KEY=${SSHDIR}/ssh_host_dsa_key
RSA1_KEY_CHROOT=${CHROOT_PATH}/etc/ssh/ssh_host_key
RSA_KEY_CHROOT=${CHROOT_PATH}/etc/ssh/ssh_host_rsa_key
DSA_KEY_CHROOT=${CHROOT_PATH}/etc/ssh/ssh_host_dsa_key
PID_FILE=${CHROOT_PATH}/var/run/sshd.pid

[ -f /etc/sysconfig/cluster ] && . /etc/sysconfig/cluster
[ -f /etc/sysconfig/fenceacksv ] && . /etc/sysconfig/fenceacksv

runlevel=$(set -- $(runlevel); eval "echo \$$#" )

do_rsa1_keygen() {
	if [ ! -s $RSA1_KEY ]; then
		echo -n $"Generating SSH1 RSA host key: "
		rm -f $RSA1_KEY
		if $KEYGEN -q -t rsa1 -f $RSA1_KEY -C '' -N '' >&/dev/null; then
			chmod 600 $RSA1_KEY
			chmod 644 $RSA1_KEY.pub
			if [ -x /sbin/restorecon ]; then
			    /sbin/restorecon $RSA1_KEY.pub
			fi
			success $"RSA1 key generation"
			echo
		else
			failure $"RSA1 key generation"
			echo
			exit 1
		fi
	fi
	if [ ! -s $RSA1_KEY_CHROOT ]; then
	   cp -a $RSA1_KEY $RSA1_KEY_CHROOT
	fi
}

do_rsa_keygen() {
	if [ ! -s $RSA_KEY ]; then
		echo -n $"Generating SSH2 RSA host key: "
		rm -f $RSA_KEY
		if $KEYGEN -q -t rsa -f $RSA_KEY -C '' -N '' >&/dev/null; then
			chmod 600 $RSA_KEY
			chmod 644 $RSA_KEY.pub
			if [ -x /sbin/restorecon ]; then
			    /sbin/restorecon $RSA_KEY.pub
			fi
			success $"RSA key generation"
			echo
		else
			failure $"RSA key generation"
			echo
			exit 1
		fi
	fi
	if [ ! -s $RSA_KEY_CHROOT ]; then
	   cp -a $RSA_KEY $RSA_KEY_CHROOT
	fi
}

do_dsa_keygen() {
	if [ ! -s $DSA_KEY ]; then
		echo -n $"Generating SSH2 DSA host key: "
		rm -f $DSA_KEY
		if $KEYGEN -q -t dsa -f $DSA_KEY -C '' -N '' >&/dev/null; then
			chmod 600 $DSA_KEY
			chmod 644 $DSA_KEY.pub
			if [ -x /sbin/restorecon ]; then
			    /sbin/restorecon $DSA_KEY.pub
			fi
			success $"DSA key generation"
			echo
		else
			failure $"DSA key generation"
			echo
			exit 1
		fi
	fi
	if [ ! -s $DSA_KEY_CHROOT ]; then
	   cp -a $DSA_KEY $DSA_KEY_CHROOT
	fi
}

do_passwd_file()
{
    if [ -d "${CHROOT_PATH}" ]; then
      cp ${CHROOT_PATH}/etc/passwd ${CHROOT_PATH}/etc/passwd.old
      sed -e 's!\(^root:.*:\)[^:]*$!\1'${FENCEACKSV_SHELL}'!' ${CHROOT_PATH}/etc/passwd.old > ${CHROOT_PATH}/etc/passwd
      rm -f ${CHROOT_PATH}/etc/passwd.old
    fi
}

do_fenceack_shell()
{
    if [ -d "${CHROOT_PATH}" ]; then
        chmod a+x ${CHROOT_PATH}/${FENCEACKSV_SHELL}
    fi
}

do_restart_sanity_check()
{
	$SSHD -t
	RETVAL=$?
	if [ ! "$RETVAL" = 0 ]; then
		failure $"Configuration file or keys are invalid"
		echo
	fi
}
start_sshd()
{
	# Create keys if necessary
	do_rsa1_keygen
	do_rsa_keygen
	do_dsa_keygen
	do_passwd_file
    do_fenceack_shell
    	
	mkdir -p ${CHROOT_PATH}/var/empty/sshd/etc
	cp -af ${CHROOT_PATH}/etc/localtime ${CHROOT_PATH}/var/empty/sshd/etc

	echo -n $"Starting fenceacksv via $prog: "
	$SSHD $OPTIONS && success || failure
	RETVAL=$?
	[ "$RETVAL" = 0 ] && touch /var/lock/subsys/fenceacksv
	echo
}

stop_sshd()
{
	echo -n $"Stopping fenceacksv via $prog: "
	if [ -e "$PID_FILE" ] ; then
	    pid=$(cat $PID_FILE)
	    kill $pid && success
	else
	    failure $"Stopping $prog"
	fi
	RETVAL=$?
	# if we are in halt or reboot runlevel kill all running sessions
	# so the TCP connections are closed cleanly
	if [ "x$runlevel" = x0 -o "x$runlevel" = x6 ] ; then
	    killall $prog 2>/dev/null
	fi
	[ "$RETVAL" = 0 ] && rm -f /var/lock/subsys/fenceacksv
	echo
}

reload_sshd()
{
	echo -n $"Reloading $prog: "
	if [ -n "`pidfileofproc $SSHD`" ] ; then
	    killproc $SSHD -HUP
	else
	    failure $"Reloading $prog"
	fi
	RETVAL=$?
	echo
}

start()
{
  if [ -n "$USE_SSHD" ]; then
    start_sshd
  elif ! pidof fenceacksv > /dev/null; then
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
  if [ -n "$USE_SSHD" ]; then
    stop_sshd
  else
    echo -n "Stopping fenceacksv:"
    killall ${FENCEACKSV}
    rtrn=$?
    if [ $rtrn -eq 0 ]; then success; else failure; fi
    echo
    return $rtrn
  fi
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
    if [ -n "$USE_SSHD" ]; then
      status -p $PID_FILE fenceacksv
    else
      status fenceacksv
    fi
    rtrn=$?
    ;;

  *)
    echo $"Usage: $0 {start|stop|restart|status}"
    ;;
esac

exit $rtrn
######################
# $Log: fenceacksv.sh,v $
# Revision 1.11  2010-08-06 13:33:33  marc
# - status works also with ssh
#
# Revision 1.10  2010/07/09 13:33:39  marc
# typo
#
# Revision 1.9  2010/07/08 13:17:10  marc
# typo
#
# Revision 1.8  2010/07/08 08:17:44  marc
# - don't create new sshd keys but use the already existant ones
#
# Revision 1.7  2010/06/25 12:39:32  marc
# - fenceacksv.sh: make the fenceackshell executable
#
# Revision 1.6  2010/06/17 08:19:22  marc
# - added ssh support
#
# Revision 1.5  2010/02/15 14:07:07  marc
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