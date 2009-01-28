#
# $Id: errors.sh,v 1.1 2009-01-28 12:52:26 marc Exp $
#
# @(#)$File$
#
# Copyright (c) 2001 ATIX GmbH, 2007 ATIX AG.
# Einsteinstrasse 10, 85716 Unterschleissheim, Germany
# All rights reserved.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

# This file lists all errors after the following format:
# errorname='errormsgwithshellvariables'
function errormsg {
	local key="$1"
	local __out=""
	if [ -z "$key" ]; then
		echo_local "Warning: Could not find errormessage for error \"$key\"!"
		return 0;
	fi
	eval __out=\$$key
	echo $__out
}
function errormsgissue {
	local key="$1"
	local issuetmp="$2"
	if [ -z "$issuetmp" ]; then
		issuetmp=$(repository_get_value shellissuetmp)
	fi
	local __out=""
	if [ -z "$key" ]; then
		echo "Warning: Could not find errormessage for error \"$key\"!" > $issuetmp
		return 0;
	fi
	eval __out=\$$key
	echo $__out > $issuetmp
}

err_test="This is a testerror with variable USER=$USER"
err_cc_validate="Could not validate cluster configuration ${cluster_conf}. 
Please check if file exists or read error:
$errors
"
err_cc_wrongbootparamter="The bootparameter \"$name\" cannot be validated. 
Read errormessage below.
$errors"
err_clusterfs_fsck="Either could not find executable to auto fsck the rootfilesystem or this
rootfilesystem does not support autofsck. This means you have to do it manually. 
This should be done if you end up here.

CAUTION: If you are using a clusterfilesystem never ever fsck with other cluster nodes being online!
"
err_cc_nodeid="The nodeid for this node could not be detected. This usually means the MAC-Addresses\n
specified in the cluster configuration could not be matched to any MAC-Adresses of this node.\n
\n
You can either fix this and build a new initrd or hardset the nodeid via \"setparameter nodeid <number>\"\n
"
err_cc_nodename="The nodename for this node could not be detected. This usually means the MAC-Addresses\n
specified in the cluster configuration could not be matched to any MAC-Adresses of this node.\n
\n
You can either fix this and build a new initrd or hardset the nodeid via \"setparameter nodename <nodename>\"\n
"
err_hw_nicdriver="No network interfaces were found. Either you have not specified a nic in the driver db (modprobe.conf).\n
Or there are no valid drivers available for your network interfaces (use \"lspci\") to validate.\n
\n
You can either fix this problem and build a new initrd or load the drivers by hand and then exit from here and\n
continue booting.\n"
err_nic_ifup="Could not power up the network interface \"$dev\".\n 
You might want to fix the configuration and continue booting.\n 
\n
Or you can fix it in the cluster configuration build a new initrd and reboot.\n
"
err_nic_load="Could not load the driver for the network interface \"dev\".\n
Either manually load it.\n
\n
Or you can fix it in the cluster configuration build a new initrd and reboot.\n
"
err_nic_config="Could not detect network configuration.\n
If unsure you might think of fixing it and continue booting with exiting from shell.\n
"

err_storage_config="Could not setup storage configuration.\n
This usually means the some kind of SCSI setup or driver multipathing are not working.\n
The best idea would be to validate this, fix it in this shell and continue booting.\n
\n
Or you can fix it in the cluster configuration build a new initrd and reboot.\n
"
err_storage_lvm="Could not start lvm configuration. This can have multiple problems.\n
Either the lvm configuration is invalid or lvm could not be setup.\n
\n
The best guess is to manually validate the error then fix it in the initrd base,\n
build a new initrd and reboot this node.\n
Error: $errors \n
"
err_cc_setup="The cluster could not be startet. Please check for the errormessages.\n  

The best guess is to manually validate the error then fix it in the initrd base,\n
build a new initrd and reboot this node.\n
Error: $errors\n
"
err_rootfs_device="Could not find the rootdevice \"$(repository_get_value root)\".\n 
This usually means either the rootdevice is not mapped to this node and is therefore not seen or\n
a higherlevel software (lvm or multipathing) cannot access the rootdevice because it is not setup as such.\n
\n
The best guess is to manually validate the error then fix it in the initrd base, build a new initrd\n
and reboot this node.\n
Error: $errors\n
"
err_rootfs_mount="The rootfilesystem on \"$(repository_get_value root)\" could not be mountet.\n 
You should check the errormessage and fix the problem.\n
\n
Usually you don't need to rebuild a new initrd but just fix something in the filesystem.\n
Error: $errors\n
"
err_rootfs_mount_cdsl="Could not mount the cdsl filesystem structure.\n
Usually this can only happen if you didn't set it up (com-mkcdslinfrastructure).\n
You should fix this and reboot this node.\n
"
err_cc_restart_service="Could not restart the service \"$service\".\n 
\n
Please carefully decide if you want to continue (type exit) booting or not.\n
The best guess might be to check why fix the problem and restart the service manully.\n
Then you can savely continue booting.\n
Error: $errors \n
"
##################
# $Log: errors.sh,v $
# Revision 1.1  2009-01-28 12:52:26  marc
# initial revision
#