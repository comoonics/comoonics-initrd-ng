#
# This is a library providing functions that allow to run services exclusivly on the cluster without other nodes interferring
# and also it allows to be running on a cluster as a dependency of a running clusterservice
# For locking we use the lock/unlock functions which use the magma tools or any other function to be clusterdependent
# This requires root privileges for magmatool

# SHAREDLOCK DIRECTORY
SHAREDLOCKDIR=${SHAREDLOCKDIR:-"/var/sharelock"}
MAGMATOOL=${MAGMATOOL:-"/sbin/magma_tool"}
REMOVE=${REMOVE:-"rm -f"}

LOCKMETHOD=${LOCKMETHOD:-"lockfile"}
LOCKFILE=${LOCKFILE:-"lockfile"}

#
# will use the magma_tool binary and fifos to create a lock in the background. The given lockname should be unique
# Does not work so we use lockfile first
function lock {
   if [ -z "$1" ] || [ "$1" = "" ]; then
   	  error_local "lock: No lockname given"
   	  return 2
   fi
   lock_${LOCKMETHOD} $*
}

function lock_lockfile {
   exec_local $LOCKFILE $*
}

function lock_magma {
   local lockname=$1
   shift
   local lockdir=$1
   shift

   echo_local_debug "Creating magma lock $lockname"
   exec 8> >($MAGMATOOL lock $lockname)
}

#
# uses the magmatool binary and fifos to release a lock held in background. The given lockname should be unique
function unlock {
   if [ -z "$1" ] || [ "$1" = "" ]; then
      error_local "unlock: No lockname given"
 	  return 2
   fi
   unlock_${LOCKMETHOD} $*
}

function unlock_lockfile {
   if [ ! -e "$1" ]; then
      error_local "Lockfile \"$1\" does not exist"
      return 1
   fi

   exec_local $REMOVE $*
}

function unlock_magma {
   local lockname=$1
   shift
   local lockdir=$1
   shift

   echo_local_debug "Unlocking magma lock $lockname"
   echo >&8
}

######################
# $Log: lock-lib.sh,v $
# Revision 1.1  2011-01-28 12:58:50  marc
# initial revision
# #