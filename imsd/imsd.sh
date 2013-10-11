#!/bin/bash
#
# $Id: fenceacksv.sh,v 1.12 2011-01-31 17:55:59 marc Exp $
#
# chkconfig: 345 24 38
# description: Starts and stops imsd (integrated management server device
#
#
### BEGIN INIT INFO
# Provides:
### END INIT INFO

. /etc/init.d/functions


RETVAL=0
prog="sshd"

# Some functions to make the below more readable
IMSD="imsd"
IMSDDIR="/opt/atix/comoonics-imsd"
SSHDIR="/etc/ssh"
IMSD_LOG="/var/log/imsd.log"
IMSD_PORT=12242
IMSD_SHELL=${IMSDDIR}/shell.py
CHROOT_PATH=$(/opt/atix/comoonics-bootimage/manage_chroot.sh -p) 
LOCK_FILE="/var/lock/subsys/${IMSD}"
KEYGEN=/usr/bin/ssh-keygen
SSHD_BIN="/usr/sbin/sshd"
SSHD="chroot ${CHROOT_PATH} ${SSHD_BIN} -p $IMSD_PORT -e"
RSA1_KEY=${SSHDIR}/ssh_host_key
RSA_KEY=${SSHDIR}/ssh_host_rsa_key
DSA_KEY=${SSHDIR}/ssh_host_dsa_key
RSA1_KEY_CHROOT=${CHROOT_PATH}${SSHDIR}/ssh_host_key
RSA_KEY_CHROOT=${CHROOT_PATH}${SSHDIR}/ssh_host_rsa_key
DSA_KEY_CHROOT=${CHROOT_PATH}${SSHDIR}/ssh_host_dsa_key
PID_FILE=${CHROOT_PATH}/var/run/sshd.pid
USE_SSHD=1

[ -f /etc/sysconfig/cluster ] && . /etc/sysconfig/cluster
[ -f /etc/sysconfig/imsd ] && . /etc/sysconfig/imsd

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
      sed -e 's!\(^root:.*:\)[^:]*$!\1'${IMSD_SHELL}'!' ${CHROOT_PATH}/etc/passwd.old > ${CHROOT_PATH}/etc/passwd
      rm -f ${CHROOT_PATH}/etc/passwd.old
    fi
}

do_imsd_shell()
{
    if [ -d "${CHROOT_PATH}" ]; then
        chmod a+x ${CHROOT_PATH}/${IMSD_SHELL}
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
[ -d ${CHROOT_PATH}${SSHDIR} ] || mkdir -p ${CHROOT_PATH}${SSHDIR}
	do_rsa1_keygen
	do_rsa_keygen
	do_dsa_keygen
	do_passwd_file
    do_imsd_shell
    	
	mkdir -p ${CHROOT_PATH}/var/empty/sshd/etc
	cp -af ${CHROOT_PATH}/etc/localtime ${CHROOT_PATH}/var/empty/sshd/etc
	touch ${CHROOT_PATH}/var/log/lastlog

	echo -n $"Starting imsd via $prog: "
	$SSHD $OPTIONS && success || failure
	RETVAL=$?
	[ "$RETVAL" = 0 ] && touch /var/lock/subsys/imsd
	echo
}

stop_sshd()
{
	echo -n $"Stopping imsd via $prog: "
	if [ -e "$PID_FILE" ] ; then
	    pid=$(cat $PID_FILE)
	    kill $pid && success
	elif [ "x$runlevel" = x0 -o "x$runlevel" = x6 ] && ! killall -0 ${CHROOT_PATH}/$SSHD_BIN &>/dev/null; then
	    # no sshd running any more
        success
	else
	    failure $"Stopping $prog"
	fi
	RETVAL=$?
	# if we are in halt or reboot runlevel kill all running sessions
	# so the TCP connections are closed cleanly
	if [ "x$runlevel" = x0 -o "x$runlevel" = x6 ] ; then
	    killall $prog 2>/dev/null
	fi
	[ "$RETVAL" = 0 ] && [ -f /var/lock/subsys/imsd ] && rm -f /var/lock/subsys/imsd
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
  start_sshd
}

stop()
{
  stop_sshd
}

rtrn=1

if [ -z "$CHROOT_PATH" ] || [ "$CHROOT_PATH" = "/" ] || [ ! -d "$CHROOT_PATH" ]; then
	echo -en "No isolated path found to start imsd [$CHROOT_PATH]. \nService will not be affected."
	passed
	echo
	exit 1
fi

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
    status -p $PID_FILE imsd
    rtrn=$?
    ;;

  *)
    echo $"Usage: $0 {start|stop|restart|status}"
    ;;
esac

exit $rtrn
######################
# $Log: imsd.sh,v $
# Revision 1.12  2011-01-31 17:55:59  marc
# fixed a bug in the initscript the imsd will fail to stop during shutdown.
#
# Revision 1.11  2010/08/06 13:33:33  marc
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
# - imsd.sh: make the fenceackshell executable
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
# fixed bug #264 where imsd could not be stopped
#
# Revision 1.2  2007/08/06 15:57:05  mark
# support for bootimage 1.3
#
# Revision 1.1  2006/08/28 16:04:46  marc
# initial revision
#