#!/usr/bin/python
"""
Fence Acknowledge Server via normal an ssl
"""

# here is some internal information
# $Id: fence_ack_server.py,v 1.5 2007-03-01 10:49:29 marc Exp $
#


__version__ = "$Revision: 1.5 $"
# $Source: /atix/ATIX/CVSROOT/nashead2004/bootimage/fencing/fence-ack-server/fence_ack_server.py,v $

from OpenSSL import SSL
import sys, os, select, socket, asyncore, asynchat, SocketServer #, ZeroReturnError
sys.path.append("../../../management/comoonics-clustersuite/python/lib")
import getopt
import logging
import warnings

from comoonics import ComSystem, ComLog, GetOpts

ComSystem.__EXEC_REALLY_DO=""
FENCE_MANUAL_FIFO="/tmp/fence_manual.fifo"
FENCE_MANUAL_LOCKFILE="/var/lock/fence_manual.lock"
FENCE_ACK_STRING="meatware ok"
PID_DIR="/var/run"
FENCE_CLIENT_RE="fence_.*\.pid"

dir = os.path.dirname(sys.argv[0])
if dir == '':
    dir = os.curdir

class Config(GetOpts.BaseConfig):
    def __init__(self):
        GetOpts.BaseConfig.__init__(self, sys.argv[0], "starts the fence_ack_manual server", __version__)
        self.debug=GetOpts.Option("debug", "toggle debugmode", False, False, "d", self.setDebug)
        self.port=GetOpts.Option("port", "tcpport to be started on", 12242, False, "p")
        self.ssl_keyfile=GetOpts.Option("ssl-keyfile", "the keyfile for ssl", os.path.join(dir, "server.pkey"))
        self.ssl_certfile=GetOpts.Option("ssl-certfile", "the certificate file for ssl", os.path.join(dir, "server.cert"))
        self.ssl_verifyfile=GetOpts.Option("ssl-verifyfile", "the verifyfile for ssl", os.path.join(dir, "CA.cert"))
        self.ssl=GetOpts.Option("ssl", "enable ssl", False)
        self.xml=GetOpts.Option("xml", "We are using an xml configfile. No file for stdin", "")
        self.xml_validate=GetOpts.Option("xml-validate", "Validate this xmlfile", True)
        self.xml_novalidate=GetOpts.Option("xml-novalidate", "Validate this xmlfile", False, False, None, self.setNoValidate)
        self.xml_nodepath=GetOpts.Option("xml-nodepath", "Get the config from this path", "")
        self.xml_clusterconf=GetOpts.Option("xml-clusterconf", "This is an RHEL4-XML Cluster configuration", True)
        self.user=GetOpts.Option("user", "The username of the user allowed to login", "")
        self.password=GetOpts.Option("password", "The password for the user", "")
        self.nodename=GetOpts.Option("nodename", "Set the nodename from outside", "")

    def do(self, args_proper):
        import os.path
        if len(args_proper) > 0 and os.path.isfile(args_proper[0]) and self.xml:
            self.xml=args_proper[0]
        elif len(args_proper) > 0:
            print >>self.__stderr__, "Wrong syntax."
            self.usage()
            return 1
        return 0

    def setNoValidate(self, value):
        self.xml_validate=not value

    def setDebug(self, value):
        ComLog.setLevel(logging.DEBUG)

    def fromXML(self, xmlfile):
        import xml.dom
        # from xml.dom.ext import PrettyPrint
        from xml.dom.ext.reader import Sax2
        import os.path
        # create Reader object
        if self.xml_validate:
            reader = Sax2.Reader(validate=1)
        else:
            reader = Sax2.Reader(validate=0)

        if self.xml==True:
            ComLog.getLogger().debug("Parsing document from stdin")
            doc = reader.fromStream(sys.stdin)
        elif os.path.isfile(self.xml):
            file=open(self.xml,"r")
            ComLog.getLogger().debug("Parsing document %s " % self.xml)
            doc = reader.fromStream(file)

        if self.xml_nodepath and self.xml_nodepath != "":
            from xml import xpath
            ComLog.getLogger().debug("Path2Config: %s" %self.xml_nodepath)
            node=xpath.Evaluate(self.xml_nodepath, doc)[0]
        else:
            node=doc.documentElement

        if self.xml_clusterconf:
            from comoonics import ComSystem
            from xml import xpath
            if not self.nodename:
                (rc, self.nodename)=ComSystem.execLocalStatusOutput("cman_tool status | grep 'Node name:'")
                self.nodename=self.nodename.split(" ")[3]
            _xmlnodepath='/cluster/clusternodes/clusternode[@name="%s"]/com_info/fenceackserver' %(self.nodename)
            ComLog.getLogger().debug("Nodename: %s, path: %s" %(self.nodename, _xmlnodepath))
            node=xpath.Evaluate(_xmlnodepath, doc)[0]

        if node.hasAttribute("port"): self.port=node.getAttribute("port")
        if node.hasAttribute("user"): self.user=node.getAttribute("user")
        if node.hasAttribute("passwd"): self.password=node.getAttribute("passwd")
        sslnodes=node.getElementsByTagName("ssl")
        if sslnodes:
            self.ssl=True
            if node.hasAttribute("keyfile"): self.ssl_keyfile=node.getAttribute("keyfile")
            if node.hasAttribute("certfile"): self.ssl_certfile=node.getAttribute("certfile")
            if node.hasAttribute("verifyfile"): self.ssl_verifyfile=node.getAttribute("verifyfile")

        return

#class Defaults:
#    ssl_keyfile=os.path.join(dir, "server.pkey")
#    ssl_certfile=os.path.join(dir, "server.cert")
#    ssl_verifyfile=os.path.join(dir, "CA.cert")
#    ssl=False
#    port=12242
#    Debug=False
#    xml=False
#    xml_validate=True
#    xml_nodepath=None
#    xml_clusterconf=True
#    user=False
#    password=False
#    nodename=False
#
#def usage(argv):
#    print """%s [-d|-debug] [-p port|--port port] [--ssl [--ssl-key=keyfile] [--ssl-cert=certfile] [--ssl-verifyfile]]
#    [--xml [xmlfile] [--xml-validate|--xml-novalidate] [--xml-nodepath path] [--xml-clusterconf|--xml-noclusterconf]]""" % argv[0]
#    print '''
#    starts the fence_ack_manual server
#    -h|--help         this helpscreen
#    -d|--debug        be more helpfull
#    -p|--port         to be started on (default: %s)
#    --ssl             use ssl
#    --ssl-key         the keyfile to ssl (default:%s)
#    --ssl-cert        the ssl certfile (default:%s)
#    --ssl-verify      the ssl verify cert file (default:%s)
#    --xml [file]      We are using an xml configfile (default: %s). No file for reading from stdin.
#    --xml-validate    Validate this xmlfile (default:%s)
#    --xml-nodepath    Get the config from this path (default: %s)
#    --xml-clusterconf This is an RHEL4-XML Cluster configuration (default: %s)
#    --nodename nodename Set the nodename from outside
#    ''' %(Defaults.port, Defaults.ssl_keyfile, Defaults.ssl_certfile, Defaults.ssl_verifyfile, Defaults.xml, Defaults.xml_validate, Defaults.xml_nodepath, Defaults.xml_clusterconf)

class SSLWrapper:
    """
    This whole class exists just to filter out a parameter
    passed in to the shutdown() method in SimpleXMLRPC.doPOST()
    """
    def __init__(self, conn):
        """
        Connection is not yet a new-style class,
        so I'm making a proxy instead of subclassing.
        """
        self.__dict__["conn"] = conn
    def __getattr__(self,name):
        return getattr(self.__dict__["conn"], name)
    def __setattr__(self,name, value):
        setattr(self.__dict__["conn"], name, value)
    def shutdown(self, how=1):
        """
        SimpleXMLRpcServer.doPOST calls shutdown(1),
        and Connection.shutdown() doesn't take
        an argument. So we just discard the argument.
        """
        self.__dict__["conn"].shutdown()
    def accept(self):
        """
        This is the other part of the shutdown() workaround.
        Since servers create new sockets, we have to infect
        them with our magic. :)
        """
        c, a = self.__dict__["conn"].accept()
        return (SSLWrapper(c), a)

class MyTCPServer(SocketServer.TCPServer):
    def __init__(self, server_address, RequestHandlerClass, user=False, passwd=False):
        self.allow_reuse_address=True
        SocketServer.TCPServer.__init__(self, server_address, RequestHandlerClass)
        self.user=user
        self.passwd=passwd


class SecureTCPServer(SocketServer.TCPServer):
    """
    Just like TCPServer, but use a socket.
    This really ought to let you specify the key and certificate files.
    """
    def __init__(self, server_address, RequestHandlerClass, keyfile, certfile, verifyfile, user=False, passwd=False):
        self.allow_reuse_address=True
        SocketServer.TCPServer.__init__(self, server_address, RequestHandlerClass)

        ## Same as normal, but make it secure:
        ctx = SSL.Context(SSL.SSLv23_METHOD)
        ctx.set_options(SSL.OP_NO_SSLv2)

        ctx.use_privatekey_file (keyfile)
        ctx.use_certificate_file(certfile)

        self.user=user
        self.passwd=passwd

        self.socket = SSLWrapper(SSL.Connection(ctx, socket.socket(self.address_family,
                                                                   self.socket_type)))
        self.server_bind()
        self.server_activate()

class FenceHandler(SocketServer.StreamRequestHandler):
    def setup(self):
        """
        We need to use socket._fileobject Because SSL.Connection
        doesn't have a 'dup'. Not exactly sure WHY this is, but
        this is backed up by comments in socket.py and SSL/connection.c
        """
        self.connection = self.request # for doPOST
        self.rfile = socket._fileobject(self.request, "rb", self.rbufsize)
        self.wfile = socket._fileobject(self.request, "wb", self.wbufsize)

    def handle(self):
        ComLog.getLogger().debug("Connected from %s %u" %(self.client_address))
        try:
            exit=False
            shellmode=False
            ComLog.getLogger().debug("Starting a shell")
            from shell import Shell
            myshell=Shell(self.rfile, self.wfile, self.server.user, self.server.passwd)
            myshell.cmdloop()
        except SSL.ZeroReturnError:
            pass
        self.request.close()
        ComLog.getLogger().debug("Disconnected from %s %u" %(self.client_address))

def main():
    config=Config()
#    print "Long options: %s" %(config.getoptLong())
#    print "Short options: %s" %(config.getoptShort())
    ret=config.getopt(sys.argv[1:])
    if ret < 0:
        sys.exit(0)
    elif ret > 0:
        sys.exit(ret)
#    try:
#        (opts, args_proper)=getopt.getopt(sys.argv[1:], 'hdp:', [ 'help', 'port', 'debug', 'user=', 'passwd', 'ssl', 'ssl-key=', 'ssl-cert=', 'ssl-verify=', 'xml', 'xml-validate', 'xml-novalidate', 'xml-nodepath=', 'xml-clusterconf', 'xml-noclusterconf', 'nodename=' ])
#    except getopt.GetoptError, goe:
#        print >>sys.stderr, "Error parsing params: %s" % goe
#        usage(sys.argv)
#        sys.exit(1)

#    index=0
#    ComLog.setLevel(logging.INFO)
#    for (opt, value) in opts:
#        #    print "Option %s" % opt
#        if opt == "-d" or opt == "--debug":
#            Defaults.DEBUG=True
#            ComLog.setLevel(logging.DEBUG)
#        elif opt == "-p'" or opt == "--port":
#            Defaults.port=value
#            index=index+1
#        elif opt == "--user":
#            Defaults.user=value
#            index=index+1
#        elif opt == "--passwd":
#            import getpass
#            Defaults.password=getpass.getpass("Password for user %s: " % Defaults.user)
#        elif opt == "--ssl":
#            Defaults.ssl=True
#        elif opt == "--ssl-key":
#            Defaults.ssl_keyfile=value
#            index=index+1
#        elif opt == "--ssl-cert":
#            Defaults.ssl_certfile=value
#            index=index+1
#        elif opt == "--ssl-verify":
#            Defaults.ssl_verifyfile=value
#            index=index+1
#        elif opt == "--xml":
#            Defaults.xml=True
#        elif opt == "--xml-validate":
#            Defaults.xml_validate=True
#        elif opt == "--xml-novalidate":
#            Defaults.xml_validate=False
#        elif opt == "--xml-clusterconf":
#            Defaults.xml_clusterconf=True
#        elif opt == "--xml-noclusterconf":
#            Defaults.xml_clusterconf=False
#        elif opt == "--xml-nodepath":
##            print "xmlnodepath "+ value
#            Defaults.xml_nodepath=value
#            index=index+1
#        elif opt == "--nodename":
#            Defaults.nodename=value
#            index=index+1
#        elif opt == "-h" or opt == "--help":
#            usage(sys.argv)
#            sys.exit(0)
#        else:
#            usage(sys.argv)
#            sys.exit(0)
#        index=index+1

#    print "Rest[%u] %u: %s" %(len(sys.argv), index, sys.argv[index])
    if config.xml:
        config.fromXML(config.xml)

    if config.ssl:
        ComLog.getLogger().debug("Starting ssl server")
        srv=SecureTCPServer(('', int(config.port)), FenceHandler, config.ssl_keyfile, config.ssl_certfile, config.ssl_verifyfile, config.user, config.password)
        srv.allow_reuse_address=True
    else:
        ComLog.getLogger().debug("Starting nonssl server")
        srv=MyTCPServer(('', int(config.port)), FenceHandler, config.user, config.password)
#        srv.allow_reuse_address=True
    try:
        srv.serve_forever()
    except:
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == '__main__':
    main()

##################
# $Log: fence_ack_server.py,v $
# Revision 1.5  2007-03-01 10:49:29  marc
# changed getopts
#
# Revision 1.4  2007/01/04 09:58:05  marc
# used right args
#
# Revision 1.3  2006/12/04 17:38:53  marc
# added GetOpts
#
# Revision 1.2  2006/09/07 16:43:06  marc
# support for killing pidfiles
# support for restarting processes
#
# Revision 1.1  2006/08/28 16:04:46  marc
# initial revision
#