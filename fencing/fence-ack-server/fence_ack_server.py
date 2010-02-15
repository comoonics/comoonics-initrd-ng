#!/usr/bin/python
"""
Fence Acknowledge Server via normal an ssl
"""

# here is some internal information
# $Id: fence_ack_server.py,v 1.8 2010-02-15 14:07:07 marc Exp $
#


__version__ = "$Revision: 1.8 $"
# $Source: /atix/ATIX/CVSROOT/nashead2004/bootimage/fencing/fence-ack-server/fence_ack_server.py,v $

try:
    from OpenSSL import SSL
except ImportError:
    pass
import sys, os, socket, SocketServer #, ZeroReturnError
import logging
from optparse import OptionParser

from comoonics import ComSystem, ComLog

logger=ComLog.getLogger("comoonics.bootimage.fenceacksv")
logging.basicConfig()

ComSystem.__EXEC_REALLY_DO=""
FENCE_MANUAL_FIFO="/tmp/fence_manual.fifo"
FENCE_MANUAL_LOCKFILE="/var/lock/fence_manual.lock"
FENCE_ACK_STRING="meatware ok"
PID_DIR="/var/run"
FENCE_CLIENT_RE="fence_.*\.pid"

dir = os.path.dirname(sys.argv[0])
if dir == '':
    dir = os.curdir

def setDebug(option, opt, value, parser):
    ComLog.setLevel(logging.DEBUG)
#    ComLog.getLogger().propagate=1

def fromXML(options, xmlfile):
    from comoonics import XmlTools
    import xml.dom
    if options.xml=="-":
        logger.debug("Parsing document from stdin")
        doc = XmlTools.parseXMLFP(sys.stdin, options.xmlvalidate)
    elif os.path.isfile(options.xml):
        logger.debug("Parsing document %s " % options.xml)
        doc = XmlTools.parseXMLFile(options.xml, options.xmlvalidate)

    if options.clusterconf:
        from xml import xpath
        if options.nodename != None or options.nodename != "":
            (rc, options.nodename)=ComSystem.execLocalStatusOutput("cman_tool status | grep 'Node name:'")
            logger.debug("options.nodename: %s" %options.nodename)
            options.nodename=options.nodename.split(" ")[2]
            _xmlnodepath='/cluster/clusternodes/clusternode[@name="%s"]/com_info/fenceackserver' %(options.nodename)
            logger.debug("Nodename: %s, path: %s" %(options.nodename, _xmlnodepath))
            node=xpath.Evaluate(_xmlnodepath, doc)[0]
    elif options.xmlnodepath and options.xmlnodepath != "":
        from xml import xpath
        logger.debug("Path2Config: %s" %options.xmlnodepath)
        node=xpath.Evaluate(options.xmlnodepath, doc)[0]
    else:
        node=doc.documentElement

    if node.hasAttribute("port"): options.port=node.getAttribute("port")
    if node.hasAttribute("user"): options.user=node.getAttribute("user")
    if node.hasAttribute("passwd"): options.password=node.getAttribute("passwd")
    if node.hasAttribute("bind"): options.bind=node.getAttribute("bind")
    sslnodes=node.getElementsByTagName("ssl")
    if sslnodes:
        options.ssl=True
        if node.hasAttribute("keyfile"): options.ssl_keyfile=node.getAttribute("keyfile")
        if node.hasAttribute("certfile"): options.ssl_certfile=node.getAttribute("certfile")
        if node.hasAttribute("verifyfile"): options.ssl_verifyfile=node.getAttribute("verifyfile")

    return
    
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
    #def setup(self):
    #    """
    #    We need to use socket._fileobject Because SSL.Connection
    #    doesn't have a 'dup'. Not exactly sure WHY this is, but
    #    this is backed up by comments in socket.py and SSL/connection.c
    #    """
    #    self.connection = self.request # for doPOST
    #    self.rfile = socket._fileobject(self.request, "rb", self.rbufsize)
    #    self.wfile = socket._fileobject(self.request, "wb", self.wbufsize)

    def handle(self):
        logger.debug("Connected from %s %u" %(self.client_address))
#        try:
        exit=False
        shellmode=False
        logger.debug("Starting a shell")
        from shell import Shell
        myshell=Shell(self.rfile, self.wfile, self.server.user, self.server.passwd)
        try:
            myshell.cmdloop()
        except:
            ComLog.errorTraceLog(logger)
#        except SSL.ZeroReturnError:
#            pass
        self.request.close()
        logger.debug("Disconnected from %s %u" %(self.client_address))

def main():

    usage = "usage: %prog [options]"
    parser = OptionParser(usage=usage, description=__doc__)

    parser.add_option("-d", "--debug", action="callback", callback=setDebug, help="Toggle debug mode")
    parser.add_option("-P", "--port", dest="port", type="int", default=12242, help="tcpport to be started on")
    parser.add_option("-K", "--ssl-keyfile", dest="sslkeyfile", default=os.path.join(dir, "server.pkey"), help="the keyfile for ssl")
    parser.add_option("-C", "--ssl-certfile", dest="sslcertfile", default=os.path.join(dir, "server.pkey"), help="the certificate file for ssl")
    parser.add_option("-V", "--ssl-verifyfile", dest="sslverifyfile", default=os.path.join(dir, "CA.cert"), help="the verifyfile for ssl")
    parser.add_option("-s", "--ssl", dest="ssl", default=False, action="store_true", help="enable ssl")
    parser.add_option("-b", "--bind", dest="bind", default="", help="bind to the given ip")
    parser.add_option("-x", "--xml", dest="xml", default=None, help="We are using an xml configfile. - for stdin")
    parser.add_option("-X", "--xml-validate", dest="xmlvalidate", default=False, action="store_true", help="Toggle validation for xml. Default: False")
    parser.add_option("-N", "--xml-nodepath", dest="xmlnodepath", default="", help="Where to find the configuration xml as xpath.")
    parser.add_option("-u", "--user", dest="user", default="", help="User to be used for fenceacksv to allow login")
    parser.add_option("-p", "--password", dest="password", default="", help="Password to be used for fenceacksv to allow login")
    parser.add_option("-n", "--nodename", dest="nodename", default=None, help="Set the nodename from outside")
    parser.add_option("-c", "--clusterconf", dest="clusterconf", default=True, action="store_true", help="Use predefined settings for RHEL cluster.conf")

    (options, args) = parser.parse_args()

    if len(args) > 0 and os.path.isfile(args[0]) and options.xml:
        options.xml=args[0]
    elif len(args) > 0:
        parser.error("Please call fenceacksv as required. If unsure use -h or --help for more information.")
        sys.exit(1)
    if options.xml:
        fromXML(options, options.xml)

    if options.ssl:
        logger.debug("Starting ssl server")
        srv=SecureTCPServer((options.bind, int(options.port)), FenceHandler, options.ssl_keyfile, options.ssl_certfile, options.ssl_verifyfile, options.user, options.password)
        srv.allow_reuse_address=True
    else:
        logger.debug("Starting nonssl server")
        srv=MyTCPServer((options.bind, int(options.port)), FenceHandler, options.user, options.password)
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
# Revision 1.8  2010-02-15 14:07:07  marc
# - moved to latest version
# - fixed bug in initscript
#
# Revision 1.7  2007/09/10 15:01:00  marc
# - BZ #108, fixed problems with not installed plugins
#
# Revision 1.6  2007/09/07 14:21:40  marc
# - independent from ssl being installed or not
# - support for binding on ips
#
# Revision 1.5  2007/03/01 10:49:29  marc
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