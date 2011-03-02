#!/usr/bin/python

## The Following Agent Has Been Tested On:
##
## Storage capable scsi3 reserve commands
##   Tested storage:
##      * Infortrend EONStor 
##   Note: As this is a scsi standard it is expected to have this agent working on all types of storage
##     That support scsifencing
#####

import sys, re, pexpect, exceptions
sys.path.append("/usr/lib/fence")
from fencing import all_opt, check_input, process_input, LOG_MODE_VERBOSE, show_docs

#BEGIN_VERSION_GENERATION
RELEASE_VERSION="SCSI3 Groupreservation fence agent"
REDHAT_COPYRIGHT=""
BUILD_DATE=""
#END_VERSION_GENERATION

options=None
cmds=dict()

all_opt["nodename"]={ "getopt": "n:", 
                      "help" : "-n <nodename>      The nodename to be fenced.", 
                      "shortdesc": "The nodename to be fenced.", 
                      "order": 1 }
#all_opt["node"]={ "getopt": "n", 
#                  "help" : "-n <nodename>      The nodename to be fenced.",
#                  "shortdesc": "The nodename to be fenced.", 
#                  "order": 2 }
all_opt["clusterconf"]={ "getopt": "c:", 
                  "help" : "-c <clusterconfiguration>      The clusterconfiguration file to be used.",
                  "shortdesc": "The clusterconfiguration to be used.", 
                  "order": 1 }
all_opt["simulate"]={ "getopt": "S", 
                  "help" : "-s                  Switch on simulation mode. Only for internal use.",
                  "shortdesc": "Switch on simulation mode. Only for internal use.", 
                  "order": 1 }

options=None

class CouldNotGetNodeId(Exception):
    def __str__(self):
        return "Could not get Nodeid for node %s. "%self.args[0]
class CouldNotGetValueFromCluster(Exception):
    def __str__(self):
        return "Could not get value %s from running cluster (Cmd: %s). "%(self.args[0], self.args[1])
class CouldNotDetectFenceName(Exception):
    def __str__(self):
        return "Could not detect the scsi fence device name for node %s with agent %s." %(self.args[0], self.args[1]) 

def exec_cmd(cmd, key=None):
    import sys
    if not key:
        key=cmd
    try:
        from comoonics import ComSystem
        (rc, out, err)=ComSystem.execLocalGetResult(cmd, True, cmds.get("key", dict()).get("simoutput", None), cmds.get("key", dict()).get("simerror", None))
    except ImportError:
        if sys.version[:3] < "2.4":
            import popen2
            child=popen2.Popen3(cmd, err)
            rc=child.wait()
            out=child.fromchild.readlines()
            err=child.childerr.readlines()
        else:
            import subprocess
            p = subprocess.Popen([cmd], shell=True, 
                                 stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, 
                                 close_fds=True)
            p.wait()
            rc=p.returncode
            out=p.stdout.readlines()
            err=p.stderr.readlines()
    if cmds.has_key(key):
        cmds[key]["executed"]=True
        cmds[key]["rc"]=rc
        cmds[key]["output"]=out
        cmds[key]["error"]=err
    if rc==0:
        return out
    else:
        raise IOError("Could not execute cmd %s. Errorcode: %u, Output: %s, Error: %s" %(cmd, rc, out, err))

def log_debug(message):
    global options
    if options["log"] >= LOG_MODE_VERBOSE:
        options["debug_fh"].write(message+"\n")
    
def getFromCluster(starts_with, cmd="cman_tool status"):
    output=exec_cmd(cmd)
    clusterid=None
    value=None
    for line in output:
        if line.startswith(starts_with):
            line=line.replace(":", "")
            value=line[len(starts_with):].strip()
    log_debug("getFromCluster(%s): %s)" %(starts_with, value))
    if not value:
        raise CouldNotGetValueFromCluster(starts_with, cmd)
    return value

def getXPathFromXMLFile(xpath, filename):
    try:
        from comoonics import XmlTools
        document=XmlTools.parseXMLFile(filename)
        return XmlTools.evaluateXPath(xpath, document.documentElement)
    except ImportError:
        from comoonics import ComLog
        ComLog.debugTraceLog()
        import xml.dom.minidom
        from xml.xpath import Evaluate
        import os
        filep = os.fdopen(os.open(filename, os.O_RDONLY))
        doc=xml.dom.minidom.parse(filep)
        return Evaluate(xpath, doc.documentElement)
            
def getMyNodeId(cmd="cman_tool status"):
    return getFromCluster("Node Id")

def getClusterId(cmd="cman_tool status"):
    return getFromCluster("Cluster Id")

def getMyNodeName(cmd="cman_tool status"):
    return getFromCluster("Node name")

def getNodeId(nodename, clusterconf="/etc/cluster/cluster.conf"):
    xpath="/cluster/clusternodes/clusternode[@name='"+nodename.strip()+"']/@nodeid"
    result=getXPathFromXMLFile(xpath, clusterconf)
    if len(result)>0:
        return result[0]
    else:
        raise CouldNotGetNodeId(nodename)

def getNodeKey(nodename, clusterconf="/etc/cluster/cluster.conf"):
    clusterid=getClusterId()
    nodeid=getNodeId(nodename, clusterconf.strip())
    return "%x%.4x" %(int(clusterid), int(nodeid))

def scsi_get_devices(nodename, fencename=None, clusterconf="/etc/cluster/cluster.conf", vgscmd="vgs --config 'global { locking_type = 0 }' --noheadings --separator : -o vg_attr,pv_name %s 2> /dev/null"):
    devices=list()
    if not fencename:
        xpath="/cluster/fencedevices/fencedevice[@agent='"+sys.argv[0]+"']/@name"
        result=getXPathFromXMLFile(xpath, clusterconf)
        if len(result)>0:
            fencename=result[0]
    if not fencename:
        raise CouldNotDetectFenceName(nodename, sys.argv[0])
    
    # first check for the scsidevices
    # let's start with global devices then overwrite/extend with local definitions
    xpaths=[ "/cluster/fencedevices/fencedevice[@name='"+fencename+"']/scsi/@device",
             "/cluster/clusternodes/clusternode[@name='"+nodename.strip()+"']/fence/method/device[@name='"+fencename+"']/scsi/@device" ]
    for xpath in xpaths:
        result=getXPathFromXMLFile(xpath, clusterconf)
        if len(result)>0:
            for i in range(len(result)):
                device=result[i].strip()
                if not device in devices: 
                    devices.append(device)

    # then check for vgs being given
    # let's start with global devices then overwrite/extend with local definitions
    xpaths=[ "/cluster/fencedevices/fencedevice[@name='"+fencename+"']/vg/@name",
             "/cluster/clusternodes/clusternode[@name='"+nodename.strip()+"']/fence/method/device[@name='"+fencename+"']/vg/@name" ]
    for xpath in xpaths:
        result=getXPathFromXMLFile(xpath, clusterconf)
        if len(result)>0:
            for i in range(len(result)):
                devices.extend(scsi_get_devices_default("", vgscmd % result[i].strip(), "vgs2"))
    if not devices or len(devices) == 0:
        devices=scsi_get_devices_default()
    return devices
        
def scsi_get_devices_default(findattr="c", cmd="vgs --config 'global { locking_type = 0 }' --noheadings --separator : -o vg_attr,pv_name 2> /dev/null", cmdkey="vgs"):
    output=exec_cmd(cmd, cmdkey)
    devices=list()
    for line in output:
        try:
            (attrs, device)=line.split(":")
            attrs=attrs.replace("-", "")
            if not findattr or attrs.find(findattr) >= 0:
                devices.append(device)
        except ValueError:
            pass
    log_debug("The following devices for reservation have been found: %s" %devices)
    return devices

def scsi_get_registration_keys(device, cmd="sg_persist -d %s -i"):
    output=exec_cmd(cmd %device, "scsi_get_registration_keys")
    keys=list()
    for line in output:
        line=line.strip()
        if line.startswith("0x"):
            keys.append(line[2:])
    log_debug("The following keys are registered to the device %s: %s" %(device, keys))
    return keys

def scsi_check_persist(cmd="sg_persist -V"):
    exec_cmd(cmd)

def scsi_do_register(device, key, cmd="sg_persist -n -d %s -o -G -S %s"):
    exec_cmd(cmd %(device, key), "scsi_do_register %s" %device)
    
def scsi_remove_registration_key(device, key, mykey):
    if mykey == key:
        cmd = "sg_persist -n -d %s -o -G -K %s -S 0" %(device, mykey)
    else:
        cmd = "sg_persist -n -d %s -o -A -K %s -S %s -T 5" %(device, mykey, key)
        
    exec_cmd(cmd, "scsi_remove_registration_key %s" %device.strip())
    
def fence_node(nodename, devices, clusterconf="/etc/cluster/cluster.conf"):
    nodekey=getNodeKey(nodename, clusterconf)
    mykey=getNodeKey(getMyNodeName(), clusterconf)
    for device in devices:
        device=device.strip()
        log_debug("Unregistring node/key %s/%s from device %s" %(nodename, nodekey, device))
        keys=scsi_get_registration_keys(device)
        if not mykey in keys:
            log_debug("Seems that our key %s is not registered with device %s. So we'll register it." %(mykey, device))
            scsi_do_register(device, mykey)
        scsi_remove_registration_key(device, nodekey, mykey)
        log_debug("The key %s has been successfully removed from device %s" %(nodekey, device))

def setSimulation(flag):
    if flag:
        try:
            from comoonics import ComSystem
            ComSystem.setExecMode(ComSystem.SIMULATE)
        except ImportError:
            pass

def setVerbose(flag):
    if flag:
        try:
            import logging
            from comoonics import ComLog
            logging.basicConfig()
            ComLog.setLevel(logging.DEBUG)
        except ImportError:
            pass
                                  
def main(argv):
    global options
    device_opt = [ "help", "version", "agent", "quiet", "verbose", "debug", "clusterconf",
                   "test", "nodename", "simulate" ]

    sys.argv=argv
    opt=process_input(device_opt)
    # not to get errors that an ipadress is not set which we don't need
    opt["-a"]=""
    # switch on simulation (only if available
    setSimulation(opt.has_key("-S"))
    setVerbose(opt.has_key("-v"))
    
    options = check_input(device_opt, opt)
    if options.has_key("-h"):
        show_docs(options)
        sys.exit(0)
    scsi_check_persist()
    devices=scsi_get_devices(options["-n"].strip(), None, options["-c"].strip())
    if not options.has_key("-c"):
        options["-c"]="/etc/cluster/cluster.conf"
    fence_node(options["-n"].strip(), devices, options["-c"].strip())

if __name__ == "__main__":
    main(sys.argv)
    
###############
# $Log:$