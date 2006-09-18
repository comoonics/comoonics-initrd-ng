#!/usr/bin/python
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
    port=443
    ribcl=False
    timeout=10

def debug(msg):
    if Config.verbose:
        print msg

class WrongOrNoRIBVersion(Exception): pass
class RIBOptionNotFound(Exception): pass
class NoPowerStateFound(Exception): pass
class CouldNotSetPowerState(Exception): pass

class FenceIlo:
    RIBVERSION_RE='<RIBCL VERSION="(.+)"/>'
    XMLS = {
    "header": '<?xml version="1.0"?>'+"\r\n",
    "frame": """<RIBCL VERSION="%s">
<LOGIN USER_LOGIN="%s" PASSWORD="%s">
%s
</LOGIN>
</RIBCL>
    """,
    "read": """
  <SERVER_INFO MODE="read">
  %s
  </SERVER_INFO>
""",
    "write": """
  <SERVER_INFO MODE="write">
  %s
  </SERVER_INFO>
"""
    }
    ACTIONS = {
        "status": {
            "xml": XMLS["read"] % "<GET_HOST_POWER_STATUS/>",
            "regexp": 'HOST_POWER="(\w+)"',
            "exception": NoPowerStateFound,
            "errortext": "Could not find power state"
        },
        "on": {
            "xml": XMLS["write"] % '<SET_HOST_POWER HOST_POWER="YES"/>',
            "eregexp": "MESSAGE=\'(((?!No error)(?!Host power is already ON)).[^\']*)\'",
            "exception": CouldNotSetPowerState,
            "errortext": "Could not set powerstate to on. Message: %s"
        },
        "off": {
            "xml": XMLS["write"] % '<SET_HOST_POWER HOST_POWER="No"/>',
            "eregexp": "MESSAGE=\'(((?!No error)(?!Host power is already OFF)).[^\']*)\'",
            "exception": CouldNotSetPowerState,
            "errortext": "Could not set powerstate to off. Message: %s"
        },
        "hardoff": {
            "xml": XMLS["write"] % '<HOLD_PWR_BTN/>',
            "eregexp": "MESSAGE=\'(((?!No error)(?!Host power is already OFF)).[^\']*)\'",
            "exception": CouldNotSetPowerState,
            "errortext": "Could not set powerstate to hardoff. Message: %s"
        },
        "coldboot": {
            "xml": XMLS["write"] % '<COLD_BOOT_SERVER/>',
            "eregexp": "MESSAGE=\'(((?!No error)(?!Server being reset)).[^\']*)\'",
            "exception": CouldNotSetPowerState,
            "errortext": "Could not set powerstate to coldboot. Message: %s"
        },
        "reset": {
            "xml": XMLS["write"] % '<RESET_SERVER/>',
            "eregexp": "MESSAGE=\'((?!No error).+)\'",
            "exception": CouldNotSetPowerState,
            "errortext": "Could not reset server. Message: %s"
        }
    }

    def __init__(self, Config):
        self.username=Config.login
        self.password=Config.passwd
        self.address=Config.hostname
        self.verbose=Config.verbose
        self.port=Config.port
        self.timeout=Config.timeout
        try:
            self.connect()
            self.ribversion=self.getRIBVersion()
        except WrongOrNoRIBVersion:
            print "Could not establish connection to ilo trying a second time"
            self.socket.close()
            self.connect()
            # Sometimes first try goes wrong try another
            self.ribversion=self.getRIBVersion()
        if Config.ribcl:
            self.ribversion=Config.ribcl

    def connect(self):
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
#        s.settimeout(self.timeout)
        ctx = SSL.Context(SSL.SSLv23_METHOD)
        ctx.set_timeout(self.timeout)
        self.socket = SSL.Connection(ctx,s)
        debug('Python socket client. Connecting to: %s:%s' %(self.address, self.port))
        self.socket.connect((self.address, self.port))

    def getRIBVersion(self):
        debug("getRIBVersion")
        self.sendXMLHeader()

        buf=self.getAnswer(1)
        debug("Got: %s" % buf)
        return self.getREResult(self.RIBVERSION_RE, buf, WrongOrNoRIBVersion, "Wrong or no RIB version found within initial response")

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
        debug("getREResult: %s" % result)
        if not result:
            return 0
        else:
            debug("Result: %s" % result.group(1))
            raise exc(errortext % result.group(1))

    def sendXMLHeader(self):
        debug("sending header")
#        try:
        self.socket.send(self.XMLS["header"])
#        except SSL.WantReadError:
#            import sys
#            debug("WantRead Error while writing and WantWrite %s" %sys.exc_info()[0])
#            try:
#                self.socket.recv(1024)
#            except SSL.WantWriteError:
#                import sys
#                debug("Caught want write let's go %s" %sys.exec_info()[0])
#                self.sendXMLHeader()

    def sendXML(self, xml):
        tosend=self.XMLS["frame"] %(self.ribversion, self.username, self.password, xml)
        debug("SEND: %s" %tosend)
        self.socket.send(tosend)

    def getAnswer(self, times=1000, message=4):
        debug("Waiting for answer")
        buf=""
        i=0
        try:
            tmessage=""
            while i<times:
                nbuf=self.socket.recv(1024)
                i=i+1
                if i == message:
                    tmessage=nbuf
                buf=buf+nbuf
        except SSL.ZeroReturnError:
            debug("nothing more to read")
        debug("READ(%u): %s" % (i,buf))
        debug("Message: %s" % tmessage)
        return buf

    def do(self, action):
        regexp=None
        eregexp=None
        xml=self.ACTIONS[action]["xml"]
        if self.ACTIONS[action].__contains__("regexp"):
            regexp=self.ACTIONS[action]["regexp"]
        if self.ACTIONS[action].__contains__("eregexp"):
            eregexp=self.ACTIONS[action]["eregexp"]
        exception=self.ACTIONS[action]["exception"]
        errortext=self.ACTIONS[action]["errortext"]
        if not xml:
            raise RIBOptionNotFound("Could not find option for command %s" % action)
        self.sendXML(xml)
        buf=self.getAnswer()
        if regexp:
            return self.getREResult(regexp, buf, exception, errortext)
        if eregexp:
            return self.getErrorREResult(eregexp, buf, exception, errortext)
        return buf

    def close(self):
        self.socket.close()

def usage():
    print """%s [-h|--help] [-V|--version] [-q|--quiet] [--port port] [-l|--login login] [-p|--password password] [-a|--address ipaddress] [-o|--option status|on|off|reset]
       """ % sys.argv[0]

def version():
    print '$Revision'

def getOptions():
    import getopt
    try:
        (opts, args_proper)=getopt.getopt(sys.argv[1:], 'hvVqa:l:p:o:', [ 'help', 'verbose', 'port=', 'login=', 'password=', 'option=', 'address=' ])
    except getopt.GetoptError, goe:
        print >>sys.stderr, "Error parsing params: %s" % goe
        usage(sys.argv)
        sys.exit(1)

    for (opt, value) in opts:
        #    print "Option %s" % opt
        if opt == "-v" or opt == "--verbose":
            Config.verbose=True
        elif opt == "-p'" or opt == "--port":
            Config.port=value
        elif opt == "-q" or opt == "--quiet":
            Config.verbose=False
        elif opt == "-a" or opt == "--address":
            Config.hostname=value
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
        print ilo.do(Config.action)
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
# $Log: fence_ilo.py,v $
# Revision 1.3  2006-09-18 10:01:48  marc
# - added hardoff and coldboot options.
# - bugfix with reconnect
#
# Revision 1.2  2006/09/07 16:43:50  marc
# creates pidfile and gives errorcode
#
# Revision 1.1  2006/08/28 16:04:46  marc
# initial revision
#