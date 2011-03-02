#!/usr/bin/python

##
## Copyright (C) 2008 Red Hat, Inc. All Rights Reserved.
##
## The Following Agent Has Been Tested On:
##
##  Model       Firmware
## +---------------------------------------------+
##  AP7951	AOS v2.7.0, PDU APP v2.7.3
##  AP7941      AOS v3.5.7, PDU APP v3.5.6
##  AP9606	AOS v2.5.4, PDU APP v2.7.3
##
## @note: ssh is very slow on AP79XX devices protocol (1) and 
##        cipher (des/blowfish) have to be defined
#####

import sys, re, pexpect, exceptions
sys.path.append("/usr/lib/fence")
from fencing import *

#BEGIN_VERSION_GENERATION
FENCE_RELEASE_NAME=""
REDHAT_COPYRIGHT=""
BUILD_DATE=""
#END_VERSION_GENERATION

def get_power_status(conn, options, logout=True):
	status=""
	try:
		if (re.compile('.*enter\s+selection:.*', re.IGNORECASE | re.S).match(conn.before) != None):
			# Press "1" for Management Agent
			conn.send("1\r\n")
			conn.log_expect(options, options["-c"], SHELL_TIMEOUT)
			# Press "1" for Management Agent Information
			conn.send("1\r\n")
			conn.log_expect(options, options["-c"], SHELL_TIMEOUT)
			# Press n for the port number 
			conn.send(options["-n"]+"\r\n")
			conn.log_expect(options, options["-c"], SHELL_TIMEOUT)
			# Press "1" for Server Blade Control Information
			conn.send("1\r\n")
			conn.log_expect(options, options["-c"], SHELL_TIMEOUT)
			
			# Now parse the power status
			result=re.compile('.*server power\s+: power\s+(\S+).*', re.IGNORECASE | re.S).match(conn.before)
			if result:
				status=result.group(1)
			# 0 for Logout
			if logout:
				conn.send("0\r\n")
		else:
			raise IOError("Could not communicate with fscbladecenter module. Enable debugging and analyse the output.")
	except pexpect.EOF:
		fail(EC_CONNECTION_LOST)
	except pexpect.TIMEOUT:
		fail(EC_TIMED_OUT)
	except IOError:
		fail(EC_STATUS)

	return status.lower().strip()

def set_power_status(conn, options):
	try:
		# the get power status takes us to the right menu
		status=get_power_status(conn, options, False)
		# Let's change power status of this blade
		# (1) Serverr power
		conn.send("1\r\n")
			
	except pexpect.EOF:
		fail(EC_CONNECTION_LOST)
	except pexpect.TIMEOUT:
		fail(EC_TIMED_OUT)
	except IOError:
		fail(EC_STATUS)

def main():
	device_opt = [  "help", "agent", "quiet", "verbose", "debug",
			"action", "ipaddr", "login", "passwd", "passwd_script",
			"port", "test", "ipport" ]

	options = check_input(device_opt, process_input(device_opt))

	## 
	## Fence agent specific defaults
	#####
	options["ssh_options"] = "-1 -c blowfish"

	##
	## Operate the fencing device
	####
	conn = fence_login(options)
	fence_action(conn, options, set_power_status, get_power_status)

	##
	## Logout from system
	##
	## In some special unspecified cases it is possible that 
	## connection will be closed before we run close(). This is not 
	## a problem because everything is checked before.
	######
	try:
		conn.sendline("4")
		conn.close()
	except exceptions.OSError:
		pass
	except pexpect.ExceptionPexpect:
		pass

if __name__ == "__main__":
	main()
