#!/usr/bin/python
import sys
import logging

logging.basicConfig()
logger=logging.getLogger("fence_scsi_test")
cmds=dict()

## Fence Scsi Test Program.
class CouldNotDetectFenceName(Exception):
    def __str__(self):
        return "Could not detect the scsi fence device name for node %s with agent %s." %(self.args[0], self.args[1]) 

def log_debug(text):
    logger.debug(text)
    
def getXPathFromXMLFile(xpath, filename):
    try:
        from comoonics import XmlTools
        document=XmlTools.parseXMLFile(filename)
        return XmlTools.evaluateXPath(xpath, document.documentElement)
    except ImportError:
        import xml.dom.minidom
        from xml.xpath import Evaluate
        import os
        filep = os.fdopen(os.open(filename, os.O_RDONLY))
        doc=xml.dom.minidom.parse(filep)
        return Evaluate(xpath, doc.documentElement)
            
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

def scsi_get_block_devices(path="/sys/block", filter=None):
    import glob
    import os.path
    if not filter:
        filter="sd*"
    if not filter.startswith(os.sep):
        devicefilter=os.path.join(path, filter)
    else:
        devicefilter=filter
    devices=list()
    for device in glob.glob(devicefilter):
        device=os.path.basename(device.strip())
        if device.startswith("sd"):
            devices.append(os.path.join("/dev", device))
    return devices

def scsi_get_devices_default(findattr="c", cmd="vgs --config 'global { locking_type = 0 }' --noheadings --separator : -o vg_attr,pv_name 2> /dev/null", cmdkey="vgs"):
    output=exec_cmd(cmd, cmdkey)
    devices=list()
    for line in output:
        try:
            (attrs, device)=line.split(":")
            attrs=attrs.replace("-", "")
            if not findattr or attrs.find(findattr) >= 0:
                devices.append(device.strip())
        except ValueError:
            pass
    print("The following devices for reservation have been found: %s" %devices)
    return devices

def scsi_do_register(device, key, cmd="sg_persist -n -d %s -o -G -S %s"):
    exec_cmd(cmd %(device, key), "scsi_do_register %s" %device)
    
def scsi_remove_registration_key(device, key, mykey):
    if mykey == key:
        cmd = "sg_persist -n -d %s -o -G -K %s -S 0" %(device, mykey)
    else:
        cmd = "sg_persist -n -d %s -o -A -K %s -S %s -T 5" %(device, mykey, key)
        
    exec_cmd(cmd, "scsi_remove_registration_key %s" %device.strip())

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
    
def check_count_xpath(xpath, clusterconf):
    result=getXPathFromXMLFile(clusterconf, "count("+xpath+")")
    if len (result) >0:
        return int(result[0])
    else:
        return 0
    
def check_config_fence(xpath="/cluster/fencedevices/fencedevice[@agent='fence_scsi']", clusterconf="/etc/cluster/cluster.conf"):
    return check_count_xpath(xpath, clusterconf)

def check_config_nodes(xpath1="/cluster/clusternodes/clusternode/@name", xpath2="/cluster/clusternodes/clusternode/@nodeid", clusterconf="/etc/cluster/cluster.conf"):
    return check_count_xpath(xpath1, clusterconf) == check_count_xpath(xpath2, clusterconf)

def print_results(results):
    success_count=0
    
    print "\nAttempted to register with devices:"
    print "-------------------------------------"

    for device in results.keys():
        print "\t%s\t" %(device)
        if results[device]:
            print "Success"
            success_count+=1
        else:
            print "Failure"
    
    print "-------------------------------------"
    print "Number of devices tested: %u" %len(results.keys())
    print "Number of devices passed: %u" %success_count
    print "Number of devices failed: %u\n" %(len(results.keys()) - success_count)
    
    return success_count > 0
        
def test_device(device, key="0xDEADBEEF"):
    scsi_do_register(device, key)
    scsi_remove_registration_key(device, key, key)

def test_devices(devices, key="oxDEADBEEF"):
    results=dict()
    for device in devices:
        try:
            test_device(device, key)
            results[device]=True
        except IOError:
            results[device]=False
    return results

def test_tools(tools=[ "sg_persist" ]):
    import os
    notfoundtools=list()
    try:
        from comoonics import ComSystem
        if ComSystem.isSimulate():
            return notfoundtools
    except:
        pass
    for tool in tools:
        found=False
        for path in os.environ['PATH'].split(":"):
            cmd=os.path.join(path, tool)
            if os.path.exists(cmd) and os.access(cmd, os.X_OK):
                found=True
        if not found:
            notfoundtools.append(tool)
    return notfoundtools

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
    from optparse import OptionParser
    sys.argv=argv
    devices=None
    parser = OptionParser()
    parser.add_option("-c", "--clustermode", dest="clustermode", default=False, action="store_true", help="Cluster mode. This mode is intended to test SCSI persistent reservation capabilties for devices that are part of existing clustered volumes. Only devices in LVM cluster volumes will be tested.")
    parser.add_option("-s", "--scsimode", dest="scsimode", default=False, action="store_true", help="SCSI mode. This mode is intended to test SCSI persistent reservation capabilities for all SCSI devices visible on a node.")
    parser.add_option("-d", "--debug", dest="debug", default=False, action="store_true", help="Debug flag. This will print debugging information such as the actual commands being run to register and unregister a device.")
    parser.add_option("-t", "--test", dest="test", default=None, help="test either for fencing or nodes, being configured for fencing.")
    parser.add_option("-C", "--clusterconf", dest="clusterconf", default="/etc/cluster/cluster.conf", help="Specify the path to the clusterconfiguration.")
    parser.add_option("-k", "--key", dest="key", default="0xDEADBEEF", help="Specify the key to be used for the reservation. Default 0xDEADBEEF")
    parser.add_option("-S", "--sysblockpath", dest="sysblockpath", default="/sys/block", help="Specify the sys path where scsi disks can be found. Default: /sys/block")
    parser.add_option("-F", "--fenceagent", dest="fenceagent", default="/sbin/fence_scsi", help="Specify the path to the fenceagent")
    parser.add_option("-f", "--scsidevicefilter", dest="scsidevicefilter", default=None, help="Only use scsidevices to test found by that glob filter. Default: None")
    
    (options, args) = parser.parse_args()
    
    setVerbose(options.debug)
    
    notfound=test_tools()
    
    if notfound:
        parser.exit(-1, """Could not find the following tools that are required to work. 
Try to find their rpm counterpart and install by issueing:
    yum whatprovides */cmd 
and then 
    yum install rpm

For the commands: %s""" %(", ".join(notfound)))
    
    if options.clustermode:
        print "Testing devices in cluster volumes or specified in %s..." %options.clusterconf
        devices=scsi_get_devices("", options.fenceagent, options.clusterconf)
    elif options.scsimode:
        print "Testing all SCSI block devices..."
        devices=scsi_get_block_devices(options.sysblockpath, options.scsidevicefilter)
    elif options.test=="fence":
        check_config_fence()
    elif options.test=="nodes":
        check_config_nodes()
    else:
        parser.exit(-2, "Commandline parameters did not make any sense. Please check with -h or --help.\n")
    if devices:
        results=test_devices(devices, options.key)
        print_results(results)
    
if __name__ == "__main__":
    main(sys.argv)
                
            
        
    
