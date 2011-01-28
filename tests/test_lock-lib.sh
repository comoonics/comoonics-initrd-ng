if ! $(runonce); then
    lockfile=$(mktemp)
    rm -f $lockfile
	echo "Creating lockfile $lockfile"
	lock $lockfile
	echo "Checking for existance of $lockfile"
	lock -r2 $lockfile
	echo "Unlockfing lockfile $lockfile"
	unlock $lockfile
fi