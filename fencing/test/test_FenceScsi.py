import unittest
# Implicitly try to import DBLogger and let it register
#try:
#    from comoonics.db.ComDBLogger import DBLogger
#except:
#    pass
class testFenceScsi(unittest.TestCase):
    def setUp(self):
        cmds=dict()
        cmds["cman_tool status"]=dict()
        cmds["cman_tool status"]["simoutput"]="""Version: 6.2.0
Config Version: 48
Cluster Name: testcluster
Cluster Id: 15354
Cluster Member: Yes
Cluster Generation: 36
Membership state: Cluster-Member
Nodes: 3
Expected votes: 3
Quorum device votes: 2
Total votes: 6
Quorum: 4  
Active subsystems: 10
Flags: Dirty 
Ports Bound: 0 11 177  
Node name: node2
Node ID: 2
Multicast addresses: 239.192.59.54 
Node addresses: 10.10.10.84""".split("\n")
        cmds["cman_tool status"]["simerror"]=""
        cmds["cman_tool status"]["rc"]=None
        cmds["cman_tool status"]["output"]=None
        cmds["cman_tool status"]["error"]=None
        cmds["cman_tool status"]["executed"]=False
        cmds["sg_persist -d /dev/sda -i -k"]=dict()
        cmds["sg_persist -d /dev/sda -i -k"]["simoutput"]=["blabla\n","0x7ef0005\n","0x7ef0006\n"]
        cmds["scsi_get_registration_keys"]=dict()
        cmds["scsi_get_registration_keys"]["simerror"]=""
        cmds["scsi_get_registration_keys"]["simoutput"]="""blabla
0x3bfa0001
0x3bfa0002
0x3bfa0003""".split("\n")
        cmds["scsi_get_registration_keys"]["rc"]=None
        cmds["scsi_get_registration_keys"]["output"]=None
        cmds["scsi_get_registration_keys"]["error"]=None
        cmds["scsi_get_registration_keys"]["executed"]=False
        cmds["sg_persist -V"]=dict()
        cmds["sg_persist -V"]["simoutput"]="""
1.0
"""
        cmds["sg_persist -V"]["simerror"]=""
        cmds["sg_persist -V"]["rc"]=None
        cmds["sg_persist -V"]["output"]=None
        cmds["sg_persist -V"]["error"]=None
        cmds["sg_persist -V"]["executed"]=False
        cmds["scsi_do_register /dev/sda"]=dict()
        cmds["scsi_do_register /dev/sda"]["simoutput"]="""
"""
        cmds["scsi_do_register /dev/sda"]["simerror"]=""
        cmds["scsi_do_register /dev/sda"]["rc"]=None
        cmds["scsi_do_register /dev/sda"]["output"]=None
        cmds["scsi_do_register /dev/sda"]["error"]=None
        cmds["scsi_do_register /dev/sda"]["executed"]=False
        cmds["scsi_remove_registration_key /dev/sda"]=dict()
        cmds["scsi_remove_registration_key /dev/sda"]["simoutput"]="""
"""
        cmds["scsi_remove_registration_key /dev/sda"]["simerror"]=""
        cmds["scsi_remove_registration_key /dev/sda"]["rc"]=None
        cmds["scsi_remove_registration_key /dev/sda"]["output"]=None
        cmds["scsi_remove_registration_key /dev/sda"]["error"]=None
        cmds["scsi_remove_registration_key /dev/sda"]["executed"]=False

        cmds["scsi_remove_registration_key /dev/sdb"]=dict()
        cmds["scsi_remove_registration_key /dev/sdb"]["simoutput"]="""
"""
        cmds["scsi_remove_registration_key /dev/sdb"]["simerror"]=""
        cmds["scsi_remove_registration_key /dev/sdb"]["rc"]=None
        cmds["scsi_remove_registration_key /dev/sdb"]["output"]=None
        cmds["scsi_remove_registration_key /dev/sdb"]["error"]=None
        cmds["scsi_remove_registration_key /dev/sdb"]["executed"]=False

        cmds["scsi_remove_registration_key /dev/sdc"]=dict()
        cmds["scsi_remove_registration_key /dev/sdc"]["simoutput"]="""
"""
        cmds["scsi_remove_registration_key /dev/sdc"]["simerror"]=""
        cmds["scsi_remove_registration_key /dev/sdc"]["rc"]=None
        cmds["scsi_remove_registration_key /dev/sdc"]["output"]=None
        cmds["scsi_remove_registration_key /dev/sdc"]["error"]=None
        cmds["scsi_remove_registration_key /dev/sdc"]["executed"]=False

        cmds["vgs"]=dict()
        cmds["vgs"]["simoutput"]="""blabla
wz--n-:/dev/sda
wz--nc:/dev/sdc
""".split("\n")
        cmds["vgs"]["simerror"]=""
        cmds["vgs"]["rc"]=None
        cmds["vgs"]["output"]=None
        cmds["vgs"]["error"]=None
        cmds["vgs"]["executed"]=False

        cmds["vgs2"]=dict()
        cmds["vgs2"]["simoutput"]="""wz--n-:/dev/sda
""".split("\n")
        cmds["vgs2"]["simerror"]=""
        cmds["vgs2"]["rc"]=None
        cmds["vgs2"]["output"]=None
        cmds["vgs2"]["error"]=None
        cmds["vgs2"]["executed"]=False
        self.cmds=cmds
    
    def test_fence_scsi(self):
        import fence_scsi
        fence_scsi.cmds=self.cmds
        fence_scsi.main(["fence_scsi", "-S", "-n node2", "-v", "-c ./cluster_fence_scsi.xml"])

    def test_fence_scsi_devices(self):
        import fence_scsi
        fence_scsi.cmds=self.cmds
        fence_scsi.main(["fence_scsi", "-S", "-n node2", "-v", "-c ./cluster_fence_scsi_devices.xml"])
        
    def test_fence_scsi_test(self):
        print "test_fence_scsi_test"
        import fence_scsi_test
        fence_scsi_test.cmds=self.cmds
        fence_scsi_test.main(["fence_scsi_test", "-s"])

def test_main():
    unittest.main()

if __name__ == '__main__':
    test_main()
