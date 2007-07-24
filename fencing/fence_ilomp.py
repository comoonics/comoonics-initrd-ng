#!/usr/bin/python
"""
fence_ilomp - fencing agent for HP ILO2 MP for integrity


"""

# ------------------------------------------------------------------------------
# About                                                                      {{{
# Filename:      fence_ilomp.py
version = "0.0.1"
# $Id: fence_ilomp.py,v 1.1 2007-07-24 14:57:06 mark Exp $
# Created:       07 Jul 2007
# Last Modified: 07 Jan 2007 Mark Hlawatschek <hlawatschek@atix.de>
# Maintainer:    Mark Hlawatschek (grimme@atix.de)
# Copyright:    (C) 2007 Marc Gimme
#
#                This program is free software; you can redistribute it and/or
#                modify it under the terms of the GNU General Public License as
#                published by the Free Software Foundation; either version 2 of
#                the License, or (at your option) any later version.
#
#                This program is distributed in the hope that it will be useful,
#                but WITHOUT ANY WARRANTY; without even the implied warranty of
#                MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#                GNU General Public License for more details.
#
#                You should have received a copy of the GNU General Public
#                License along with this program; if not, write to the Free
#                Software Foundation, Inc., 59 Temple Place, Suite 330, Boston,
#                MA  02111-1307  USA
#
# Dependencies:  0.999 Pexpect (http://pexpect.sourceforge.net)
#                Local Applications:
#                SSH or Telnet 
#                                                                            }}}
# ------------------------------------------------------------------------------
# Import modules                                                             {{{


from comoonics import pexpect

import socket
from OpenSSL import SSL
import sys
import re
import exceptions

# PID_DIR="/var/run"
PID_DIR="/var/run"
PID_EXT="pid"

class Config:
    login=False
    passwd=False
    hostname=False
    action="reset"
    verbose=False
    mpcl=False
    timeout=10
    proto="ssh"

def debug(msg):
    if Config.verbose:
        print msg

class WrongOrNoMPVersion(Exception): pass
class MPOptionNotFound(Exception): pass
class NoPowerStateFound(Exception): pass
class CouldNotSetPowerState(Exception): pass

class FenceIlo:
    LOGINPROMPT="MP login:"
    PASSPROMPT="MP password:"
    CONSOLPROMPT="MP>"
    CMPROMPT="MP:CM>"
    
    CMD_CM="CM"
    CMD_MP="MA"
    CMD_EXIT="X"
    
    CMD_POWER_STATUS="ps -nc"
    CMD_POWER_ON="pc -on -nc"
    CMD_POWER_OFF="pc -off -nc"
    CMD_POWER_RESET="pc -reset -nc"
    CMD_FIRMWARE_REVS="SYSREV -nc"
    
    RES_POWER_STATUS="System Power state      : "
    RES_MP_FW=" MP FW     : "
    
    RES_SUCCESS="-> Command successful."
    RES_NOSUCCESS="-> Command failed."
     
    def __init__(self, Config):
        self.username=Config.login
        self.password=Config.passwd
        self.address=Config.hostname
        self.verbose=Config.verbose
        self.timeout=Config.timeout
        self.proto=Config.proto
        
        try:
            self.connect()
            # For now, we trust the ilo MP interface. Tested version: T.01.20
            self.mpversion=self.getMPVersion()
        except WrongOrNoMPVersion:
            print "Could not establish connection to ilo trying a second time"
            self.socket.close()
            self.connect()
            # Sometimes first try goes wrong try another
            self.ribversion=self.getMPVersion()
        if Config.mpcl:
            self.mpversion=Config.mpcl
        
    def connect(self):
        if self.proto == "ssh":
            from comoonics import pxssh
            s = pxssh.pxssh()
            if not s.login (self.address, self.username, self.password):
                debug("SSH session failed on login.")
                debug(str(s))
                raise WrongOrNoMPVersion("SSH session failed on login.")
            debug("SSH session login successful")
            self.session=s
        elif self.proto == "telnet":
            from comoonics import pexpect
            s = pexpect.spawn('telnet %s 23' %self.address)
            s.expect(self.LOGINPROMPT)
            s.sendline(self.username)
            debug("Telnet sending username %s" %self.username)
            s.expect(self.PASSPROMPT)
            s.sendline(self.password)
            debug("Telnet sending password")
            res=s.expect([self.CONSOLPROMPT, self.LOGINPROMPT, pexpect.TIMEOUT])
            if res != 0:
                debug("Telnet session failed to login")
                raise WrongOrNoMPVersion("Telnet session failed on login.")
            debug("Telnet connection success")
            self.session=s         
        else:
             debug("%s session is not supported" %self.proto)
             raise WrongOrNoMPVersion("%s session is not supported" %self.proto)             
        self.setCommandMode()
     
             
    def setCommandMode(self):
        debug("setCommandMode")
        self.session.sendline(self.CMD_CM)
        res = self.session.expect([self.CMPROMPT, pexpect.TIMEOUT, pexpect.EOF])
        if res != 0:
            raise MPOptionNotFound(self.CMD_CMD)      
                 
    def getMPVersion(self):
        debug("getMPVersion")
        return("NA")
    
    def getPowerStatus(self):
        debug("getPowerState")
        self.setCommandMode()
        self.session.sendline(self.CMD_POWER_STATUS)
        self.session.expect(self.RES_POWER_STATUS)
        res=self.session.readline()
        debug("Result: %s" %res)
        return self.getREResult("(On|Off)", res, NoPowerStateFound, "Power state not found")

    def setPowerState(self, state):
        self.setCommandMode()
        if self.getPowerStatus().lower() == state:
            debug("Power is already %s" %state)
        debug("Setting power to %s" %state)
        if state == "on":
            self.session.sendline(self.CMD_POWER_ON)
        elif state == "off":
            self.session.sendline(self.CMD_POWER_OFF)
        elif state == "reset":
            self.session.sendline(self.CMD_POWER_RESET)
        else:
            raise MPOptionNotFound("Power %s" %state)
        res = self.session.expect([self.RES_SUCCESS, self.RES_NOSUCCESS, pexpect.TIMEOUT])
        if res != 0:
            raise CouldNotSetPowerState("Could not set power to %s" %state)

    def getREResult(self, reg, buf, exc, errortext):
        result=re.search(reg, buf, re.MULTILINE)
        debug("getREResult: %s" % result)
        if not result:
            raise exc(errortext)
        else:
            debug("Result: %s" % result.group(1))
            return result.group(1)

    def getErrorREResult(self, reg, buf, exc, errortext):
        result=re.search(reg, buf, re.MULTILINE)
        debug("getErrorREResult: %s" % result)
        if result:
            debug("Result: %s" % result.group(1))
            raise exc(errortext % result.group(1))
        else:
            return ""

    def getWarningREResult(self, reg, buf, warningtext):
        result=re.search(reg, buf, re.MULTILINE)
        debug("getWarningREResult: %s" % result)
        if result:
            debug("Result: %s" % result.group(1))
            return warningtext % result.group(1)
        else:
            return ""


    def do(self, action):
        if action == "status":
            return self.getPowerState()
        elif action == "on":
            self.setPowerState(action)
            return "OK"
        elif action == "off":
            self.setPowerState(action)
            return "OK"
        elif action == "reset":
            self.setPowerState(action)
            return "OK"
        else: 
            raise CouldNotSetPowerState("action %s is not supported" %action)
    
    def close(self):
        self.session.sendline(self.CMD_MP)
        self.session.sendline(self.CMD_EXIT)
        self.session.terminate()

def usage():
    print """%s [-h|--help] [-V|--version] [-q|--quiet] [-l|--login login] [-p|--password password] [-a|--address ipaddress] [-o|--option status|on|off|reset]
       """ % sys.argv[0]

def version():
    print '$Revision'

def getOptions():
    import getopt
    try:
        (opts, args_proper)=getopt.getopt(sys.argv[1:], 'hvVqa:l:o:p:P:', [ 'help', 'verbose', 'proto=', 'login=', 'password=', 'option=', 'address=' ])
    except getopt.GetoptError, goe:
        print >>sys.stderr, "Error parsing params: %s" % goe
        usage(sys.argv)
        sys.exit(1)

    for (opt, value) in opts:
        #    print "Option %s" % opt
        if opt == "-v" or opt == "--verbose":
            Config.verbose=True
        elif opt == "-q" or opt == "--quiet":
            Config.verbose=False
        elif opt == "-a" or opt == "--address":
            Config.hostname=value
        elif opt == "-P" or opt == "--proto":
            Config.proto=value
        elif opt == "-l" or opt == "--login":
            Config.login=value
        elif opt == "-p" or opt == "--password":
            Config.passwd=value
        elif opt == "-o" or opt == "--option":
            Config.action=value
        elif opt == "-V|--version":
            version()
            sys.exit(0)
        elif opt == "-h" or opt == "--help":
            usage()
            sys.exit(0)
        else:
            usage()
            sys.exit(0)

def getOptionsFromStdin():
    #print "Reading from stdin"
    for line in sys.stdin:
        #print "Reading line %s" %line
        line.strip()
        line=line.splitlines()[0]
        if line!="":
            (opt, value)=line.split("=")
            if not value:
                value=True
            debug("read %s=%s" %(opt, value))
            setattr(Config, opt, value)

def get_pid_filename():
    import os.path
    return "%s/%s.%s" %(PID_DIR, os.path.basename(os.path.splitext(sys.argv[0])[0]), PID_EXT)


def create_pid_file():
    import os
    pidf=open(get_pid_filename(), "w")
    print >>pidf, os.getpid()
    pidf.close()

def remove_pid_file():
    import os
    os.remove(get_pid_filename())

def main():
    if len(sys.argv) > 1:
        getOptions()
    else:
        getOptionsFromStdin()

    exit_code=0
    try:
        try:
            create_pid_file()
        except:
            print "Could not create pidfile %s" % get_pid_filename()
        ilo=FenceIlo(Config)
        print ilo.do(Config.action.lower())
        ilo.close()
        import os.path
        if os.path.exists(get_pid_filename()):
            try:
                remove_pid_file()
            except:
                print "Could not remove pidfile %s" % get_pid_filename()
    except:
        if Config.verbose:
            import traceback
            traceback.print_exc()
        else:
            print >>sys.stderr, sys.exc_value
        import os.path
        if os.path.exists(get_pid_filename()):
            try:
                remove_pid_file()
            except:
                print "Could not remove pidfile %s" % get_pid_filename()
        exit_code=1

    sys.exit(exit_code)


if __name__ == '__main__':
    main()

#################
# $Log: fence_ilomp.py,v $
# Revision 1.1  2007-07-24 14:57:06  mark
# initial check in
#
