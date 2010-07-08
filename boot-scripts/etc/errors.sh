#
# $Id: errors.sh,v 1.3 2010-07-08 08:07:21 marc Exp $
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
	shift
	local __out=""
	if [ -z "$key" ]; then
		echo_local "Warning: Could not find errormessage for error \"$key\"!"
		return 0;
	fi
	repository_store_parameters ${key}"_" $@
	echo -e $(eval eval echo \$$key)
	repository_del_parameters $ {key}"_" $@
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
	repository_store_parameters ${key}"_" $@
	eval eval echo -e \$$key > $issuetmp
	repository_del_parameters $ {key}"_" $@
}

err_test='This is a testerror with variable USER=$USER param1=$(repository_get_value err_test_param1)\\n
Command: $(repository_get_value exec_local_lastcmd)\\n
Errors:  $(repository_get_value exec_local_lasterror)'
err_cc_validate='Could not validate cluster configuration $(repository_get_value err_cc_validate_param1).\\n 
Please check if file exists and read error:\\n
Command: $(repository_get_value exec_local_lastcmd)\\n
Errors:  $(repository_get_value exec_local_lasterror)\\n
'
err_cc_wrongbootparamter='The bootparameter "$(repository_get_value err_cc_wrongbootparamter_param1)" cannot be validated.\\n 
Read errormessage below.\\n
Command: $(repository_get_value exec_local_lastcmd)\\n
Errors:  $(repository_get_value exec_local_lasterror)\\n
'
err_clusterfs_fsck='Either could not find executable to auto fsck the filesystem ("$(repository_get_value err_clusterfs_fsck_param2)") on "$(repository_get_value err_clusterfs_fsck_param1)"\\n
or this filesystem does not support autofsck. This means you have to do it manually.\\n 
This should be done if you end up here.\\n
\\n
CAUTION: If you are using a clusterfilesystem never ever fsck with other cluster nodes being online!\\n
'
err_cc_nodeid='The nodeid for this node could not be detected. This usually means the\\n
MAC-Addresses specified in the cluster configuration could not be matched to any\\n
MAC-Adresses of this node.\\n
\\n
You can either fix this and build a new initrd or hardset the nodeid via\\n
"setparameter nodeid <number>"\\n
'
err_cc_nodename='The nodename for this node could not be detected. This usually means the MAC-Addresses\\n
specified in the cluster configuration could not be matched to any MAC-Adresses of this node.\\n
\\n
You can either fix this and build a new initrd or hardset the nodeid via "setparameter nodename <nodename>"\\n
'
err_hw_nicdriver='No network interfaces were found. Either you have not specified a nic in the driver db (modprobe.conf).\\n
Or there are no valid drivers available for your network interfaces (use "lspci") to validate.\\n
\\n
You can either fix this problem and build a new initrd or load the drivers by hand and then exit from here and\\n
continue booting.\\n
'
err_nic_ifup='Could not power up the network interface "$(repository_get_value err_nic_ifup_param1)".\\n 
You might want to fix the configuration and continue booting.\\n 
\\n
Or you can fix it in the cluster configuration build a new initrd and reboot.\\n
Command: $(repository_get_value exec_local_lastcmd)\\n
Output: $(repository_get_value exec_local_lastout)\\n
Errors: $(repository_get_value exec_local_lasterror)\\n
'
err_nic_load='Could not load the driver for the network interface "$(repository_get_value err_nic_load_param1)".\\n
Either manually load it.\\n
\\n
Or you can fix it in the cluster configuration build a new initrd and reboot.\\n
'
err_nic_config='Could not detect network configuration.\\n
If unsure you might think of fixing it and continue booting with exiting from shell.\\n
Command: $(repository_get_value exec_local_lastcmd)\\n
Output: $(repository_get_value exec_local_lastout)\\n
Errors: $(repository_get_value exec_local_lasterror)\\n
'

err_storage_config='Could not setup storage configuration.\\n
This usually means the some kind of SCSI setup or driver multipathing are not working.\\n
The best idea would be to validate this, fix it in this shell and continue booting.\\n
\\n
Or you can fix it in the cluster configuration build a new initrd and reboot.\\n
'

err_storage_lvm='Could not start lvm configuration. This can have multiple problems.\\n
Either the lvm configuration is invalid or lvm could not be setup.\\n
\\n
The best guess is to manually validate the error then fix it in the initrd base,\\n
build a new initrd and reboot this node.\\n
\\n
Command: $(repository_get_value exec_local_lastcmd)\\n
Output: $(repository_get_value exec_local_lastout)\\n
Errors: $(repository_get_value exec_local_lasterror)\\n
'
err_cc_setup='The cluster could not be startet. Please check for the errormessages.\n  
\\n
The best guess is to manually validate the error then fix it in the initrd base,\n\
build a new initrd and reboot this node.\\n
Command: $(repository_get_value exec_local_lastcmd)\\n
Output: $(repository_get_value exec_local_lastout)\\n
Errors: $(repository_get_value exec_local_lasterror)\\n
'
err_rootfs_device='Could not find the rootdevice "$(repository_get_value root)".\\n 
This usually means either the rootdevice is not mapped to this node and is therefore not seen or\\n
a higherlevel software (lvm or multipathing) cannot access the rootdevice because it is not setup as such.\\n
\\n
The best guess is to manually validate the error then fix it in the initrd base, build a new initrd\n
and reboot this node.\\n
Command: $(repository_get_value exec_local_lastcmd)\\n
Output: $(repository_get_value exec_local_lastout)\\n
Errors: $(repository_get_value exec_local_lasterror)\\n
'

err_rootfs_mount='The rootfilesystem on "$(repository_get_value root)" could not be mountet.\\n 
You should check the errormessage and fix the problem.\\n
\\n
Usually you do not need to rebuild a new initrd but just fix something in the filesystem.\\n
Command: $(repository_get_value exec_local_lastcmd)\\n
Output: $(repository_get_value exec_local_lastout)\\n
Errors: $(repository_get_value exec_local_lasterror)\\n
'

err_fs_mount_cdsl='Could not mount the cdsl filesystem structure for the filesystem on "$(repository_get_value err_fs_mount_cdsl_param1)".\\n
Usually this can only happen if you did not set it up (com-mkcdslinfrastructure).\\n
You should fix this and reboot this node.\\n
'

err_cc_restart_service='Could not restart the service "$(repository_get_value err_cc_restart_service_param1)".\\n 
\\n
Please carefully decide if you want to continue (type exit) booting or not.\\n
The best guess might be to check why fix the problem and restart the service manully.\\n
Then you can savely continue booting.\\n
Command: $(repository_get_value exec_local_lastcmd)\\n
Output: $(repository_get_value exec_local_lastout)\\n
Errors: $(repository_get_value exec_local_lasterror)\\n
'

err_fs_device='Could not find the device "$(repository_get_value err_fs_device_param1)".\\n 
This usually means either the rootdevice is not mapped to this node and is therefore not seen or\\n
a higherlevel software (lvm or multipathing) cannot access the rootdevice because it is not setup as such.\\n
\\n
The best guess is to manually validate the error then fix it in the initrd base, build a new initrd\\n
Command: $(repository_get_value exec_local_lastcmd)\\n
Output: $(repository_get_value exec_local_lastout)\\n
Errors: $(repository_get_value exec_local_lasterror)\\n
'

err_fs_mount='The filesystem on "$(repository_get_value err_fs_mount_param1)" could not be mountet.\\n 
You should check the errormessage and fix the problem.\\n
\\n
Usually you do not need to rebuild a new initrd but just fix something in the filesystem.\\n
Command: $(repository_get_value exec_local_lastcmd)\\n
Output: $(repository_get_value exec_local_lastout)\\n
Errors: $(repository_get_value exec_local_lasterror)\\n
'
##################
# $Log: errors.sh,v $
# Revision 1.3  2010-07-08 08:07:21  marc
# - reworked the errors to make use of errors, output and command being stored by exec_local
# - rewrote errors
#
# Revision 1.2  2010/02/05 12:34:59  marc
# typo
#
# Revision 1.1  2009/01/28 12:52:26  marc
# initial revision
#