#!/usr/bin/python
"""
Fence Acknowledge Server via normal an ssl
"""

# here is some internal information
# $Id: fence_ack_server.py,v 1.1 2006-08-28 16:04:46 marc Exp $
#


__version__ = "$Revision: 1.1 $"
# $Source: /atix/ATIX/CVSROOT/nashead2004/bootimage/fencing/fence-ack-server/fence_ack_server.py,v $

from OpenSSL import SSL
import sys, os, select, socket, asyncore, asynchat, SocketServer #, ZeroReturnError
sys.path.append("../../../management/comoonics-clustersuite/python/lib")
import getopt
import logging
import warnings

from comoonics import ComSystem, ComLog

ComSystem.__EXEC_REALLY_DO=""
FENCE_MANUAL_FIFO="/tmp/fence_manual.fifo"
FENCE_MANUAL_LOCKFILE="/var/lock/fence_manual.lock"
FENCE_ACK_STRING="meatware ok"

dir = os.path.dirname(sys.argv[0])
if dir == '':
    dir = os.curdir

class Defaults:
    ssl_keyfile=os.path.join(dir, "server.pkey")
    ssl_certfile=os.path.join(dir, "server.cert")
    ssl_verifyfile=os.path.join(dir, "CA.cert")
    ssl=False
    port=12242
    Debug=False
    xml=False
    xml_validate=True
    xml_nodepath=None
    xml_clusterconf=True
    user=False
    password=False
    nodename=False

def usage(argv):
    print """%s [-d|-debug] [-p port|--port port] [--ssl [--ssl-key=keyfile] [--ssl-cert=certfile] [--ssl-verifyfile]]
    [--xml [xmlfile] [--xml-validate|--xml-novalidate] [--xml-nodepath path] [--xml-clusterconf|--xml-noclusterconf]]""" % argv[0]
    print '''
    starts the fence_ack_manual server
    -h|--help         this helpscreen
    -d|--debug        be more helpfull
    -p|--port         to be started on (default: %s)
    --ssl             use ssl
    --ssl-key         the keyfile to ssl (default:%s)
    --ssl-cert        the ssl certfile (default:%s)
    --ssl-verify      the ssl verify cert file (default:%s)
    --xml [file]      We are using an xml configfile (default: %s). No file for reading from stdin.
    --xml-validate    Validate this xmlfile (default:%s)
    --xml-nodepath    Get the config from this path (default: %s)
    --xml-clusterconf This is an RHEL4-XML Cluster configuration (default: %s)
    --nodename nodename Set the nodename from outside
    ''' %(Defaults.port, Defaults.ssl_keyfile, Defaults.ssl_certfile, Defaults.ssl_verifyfile, Defaults.xml, Defaults.xml_validate, Defaults.xml_nodepath, Defaults.xml_clusterconf)

def getDefaultsFromXML(xmlfile, xmlvalidate, xmlnodepath, xmlclusterconf, nodename, defaults):
    import xml.dom
    # from xml.dom.ext import PrettyPrint
    from xml.dom.ext.reader import Sax2
    import os.path
    # create Reader object
    if xmlvalidate:
        reader = Sax2.Reader(validate=1)
    else:
        reader = Sax2.Reader(validate=0)

    if xmlfile==True:
        ComLog.getLogger().debug("Parsing document from stdin")
        doc = reader.fromStream(sys.stdin)
    elif os.path.isfile(xmlfile):
        file=open(xmlfile,"r")
        ComLog.getLogger().debug("Parsing document %s " % xmlfile)
        doc = reader.fromStream(file)

    if xmlnodepath and xmlnodepath != "":
        from xml import xpath
        ComLog.getLogger().debug("Path2Config: %s" %xmlnodepath)
        node=xpath.Evaluate(xmlnodepath, doc)[0]
    else:
        node=doc.documentElement

    if xmlclusterconf:
        from comoonics import ComSystem
        from xml import xpath
        if not nodename:
            (rc, nodename)=ComSystem.execLocalStatusOutput("cman_tool status | grep 'Node name:'")
            nodename=nodename.split(" ")[3]
        _xmlnodepath='/cluster/clusternodes/clusternode[@name="%s"]/com_info/fenceackserver' %(nodename)
        ComLog.getLogger().debug("Nodename: %s, path: %s" %(nodename, _xmlnodepath))
        node=xpath.Evaluate(_xmlnodepath, doc)[0]

    if node.hasAttribute("port"): defaults.port=node.getAttribute("port")
    if node.hasAttribute("user"): defaults.user=node.getAttribute("user")
    if node.hasAttribute("passwd"): defaults.password=node.getAttribute("passwd")
    sslnodes=node.getElementsByTagName("ssl")
    if sslnodes:
        defaults.ssl=True
        if node.hasAttribute("keyfile"): defaults.ssl_keyfile=node.getAttribute("keyfile")
        if node.hasAttribute("certfile"): defaults.ssl_certfile=node.getAttribute("certfile")
        if node.hasAttribute("verifyfile"): defaults.ssl_verifyfile=node.getAttribute("verifyfile")

    return (defaults.port, defaults.ssl, defaults.ssl_keyfile, defaults.ssl_certfile, defaults.ssl_verifyfile)

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
    try:
        (opts, args_proper)=getopt.getopt(sys.argv[1:], 'hdp:', [ 'help', 'port', 'debug', 'user=', 'passwd', 'ssl', 'ssl-key=', 'ssl-cert=', 'ssl-verify=', 'xml', 'xml-validate', 'xml-novalidate', 'xml-nodepath=', 'xml-clusterconf', 'xml-noclusterconf', 'nodename=' ])
    except getopt.GetoptError, goe:
        print >>sys.stderr, "Error parsing params: %s" % goe
        usage(sys.argv)
        sys.exit(1)

    index=0
    ComLog.setLevel(logging.INFO)
    for (opt, value) in opts:
        #    print "Option %s" % opt
        if opt == "-d" or opt == "--debug":
            Defaults.DEBUG=True
            ComLog.setLevel(logging.DEBUG)
        elif opt == "-p'" or opt == "--port":
            Defaults.port=value
            index=index+1
        elif opt == "--user":
            Defaults.user=value
            index=index+1
        elif opt == "--passwd":
            import getpass
            Defaults.password=getpass.getpass("Password for user %s: " % Defaults.user)
        elif opt == "--ssl":
            Defaults.ssl=True
        elif opt == "--ssl-key":
            Defaults.ssl_keyfile=value
            index=index+1
        elif opt == "--ssl-cert":
            Defaults.ssl_certfile=value
            index=index+1
        elif opt == "--ssl-verify":
            Defaults.ssl_verifyfile=value
            index=index+1
        elif opt == "--xml":
            Defaults.xml=True
        elif opt == "--xml-validate":
            Defaults.xml_validate=True
        elif opt == "--xml-novalidate":
            Defaults.xml_validate=False
        elif opt == "--xml-clusterconf":
            Defaults.xml_clusterconf=True
        elif opt == "--xml-noclusterconf":
            Defaults.xml_clusterconf=False
        elif opt == "--xml-nodepath":
#            print "xmlnodepath "+ value
            Defaults.xml_nodepath=value
            index=index+1
        elif opt == "--nodename":
            Defaults.nodename=value
            index=index+1
        elif opt == "-h" or opt == "--help":
            usage(sys.argv)
            sys.exit(0)
        else:
            usage(sys.argv)
            sys.exit(0)
        index=index+1

    import os.path
#    print "Rest[%u] %u: %s" %(len(sys.argv), index, sys.argv[index])
    if len(sys.argv) > index+1 and os.path.isfile(sys.argv[index+1]) and Defaults.xml:
        Defaults.xml=sys.argv[index+1]

    if Defaults.xml:
        (Defaults.port, Defaults.ssl, Defaults.ssl_keyfile, Defaults.ssl_certfile, Defaults.ssl_verifyfile) = getDefaultsFromXML(Defaults.xml, Defaults.xml_validate, Defaults.xml_nodepath, Defaults.xml_clusterconf, Defaults.nodename, Defaults)

    if Defaults.ssl:
        ComLog.getLogger().debug("Starting ssl server")
        srv=SecureTCPServer(('', int(Defaults.port)), FenceHandler, Defaults.ssl_keyfile, Defaults.ssl_certfile, Defaults.ssl_verifyfile, Defaults.user, Defaults.password)
        srv.allow_reuse_address=True
    else:
        ComLog.getLogger().debug("Starting nonssl server")
        srv=MyTCPServer(('', int(Defaults.port)), FenceHandler, Defaults.user, Defaults.password)
#        srv.allow_reuse_address=True
    try:
        srv.serve_forever()
    except:
        import traceback
        traceback.print_exc()

if __name__ == '__main__':
    main()

##################
# $Log: fence_ack_server.py,v $
# Revision 1.1  2006-08-28 16:04:46  marc
# initial revision
#