#!/usr/bin/python
#
# client.py
"""
Simple Telnet client also using ssl
"""

from OpenSSL import SSL
import sys, os, select, socket
import getopt
from telnetlib import Telnet
import logging
import warnings

sys.path.append("../../../management/comoonics-clustersuite/python/lib")
from comoonics import ComSystem, ComLog

# Initialize context
#ctx = SSL.Context(SSL.SSLv2_METHOD)
#ctx.set_verify(SSL.VERIFY_NONE, verify_cb) # Demand a certificate
#ctx.use_privatekey_file (os.path.join(dir, 'client.pkey'))
#ctx.use_certificate_file(os.path.join(dir, 'client.cert'))
#ctx.load_verify_locations(os.path.join(dir, 'CA.cert'))
#
## Set up client
#sock = SSL.Connection(ctx, socket.socket(socket.AF_INET, socket.SOCK_STREAM))
#sock.connect((sys.argv[1], int(sys.argv[2])))
# Go to client mode
#sock.set_connect_state()

if len(sys.argv) < 2:
    print 'Usage: python[2] client.py HOST PORT'
    sys.exit(1)

dir = os.path.dirname(sys.argv[0])
if dir == '':
    dir = os.curdir

class Defaults:
    keyfile=os.path.join(dir, "client.pkey")
    certfile=os.path.join(dir, "client.cert")
    verifyfile=False
    ssl=False
    port=12242
    Debug=False

def usage(argv):
    print "%s [-d|-debug] [-p port|--port port] [--ssl [--ssl-key=keyfile] [--ssl-cert=certfile] hostname" % argv[0]
    print '''
    starts the fence_ack_manual client

    -d|--debug be more helpfull
    -p|--port  to be started on (default: %s)
    --ssl      use ssl
    --ssl-key  the keyfile to ssl (default:%s)
    --ssl-cert the ssl certfile (default:%s)
    --ssl-verify the ssl verify cert file (default:%s)
    ''' %(Defaults.port, Defaults.keyfile, Defaults.certfile, Defaults.verifyfile)

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

class MyTelnet(Telnet):
    logintimeout=5
    def checkuser(self):
        searchstring=list()
        searchstring.append("Username: ")
        (index, match, text)=self.expect(searchstring, self.logintimeout)
        if index >= 0:
            sys.stdout.write("Username: ")
            sys.stdout.flush()
            line=sys.stdin.readline()
            self.write(line)
        else:
            sys.stdout.write(text)
            sys.stdout.flush()
        return index

    def checkpassword(self):
        import getpass
        searchstring=list()
        searchstring.append("Password: ")
        (index, match, text) = self.expect(searchstring, self.logintimeout)
        if index >= 0:
            passwd=getpass.getpass('Remote password: ')
            self.write(passwd+"\n")
        else:
            sys.stdout.write(text)
            sys.stdout.flush()
        return index

class SSLTelnet(MyTelnet):
    def __init__(self, host=None, port=Defaults.port, keyfile=Defaults.keyfile, certfile=Defaults.certfile, verifyfile=Defaults.verifyfile):
        ## Same as normal, but make it secure:
        self.ctx = SSL.Context(SSL.SSLv23_METHOD)
        self.ctx.set_options(SSL.OP_NO_SSLv2)

        if verifyfile:
            self.ctx.set_verify(SSL.VERIFY_PEER, self.verify_cb) # Demand a certificate
            self.ctx.load_verify_locations(os.path.join(dir, verifyfile))
        self.ctx.use_privatekey_file (keyfile)
        self.ctx.use_certificate_file(certfile)
        Telnet.__init__(self, host, port)

    def verify_cb(self, conn, cert, errnum, depth, ok):
        # This obviously has to be updated
        print 'Got certificate: %s' % cert.get_subject()
        return ok

    def open(self, host, port=0):
        """Connect to a host.

        The optional second argument is the port number, which
        defaults to the standard telnet port (23).

        Don't try to reopen an already connected instance.

        """
        self.eof = 0
        if not port:
            port = TELNET_PORT
        self.host = host
        self.port = port
        msg = "getaddrinfo returns an empty list"
        for res in socket.getaddrinfo(host, port, 0, socket.SOCK_STREAM):
            af, socktype, proto, canonname, sa = res
            try:
                self.sock = SSLWrapper(SSL.Connection(self.ctx, socket.socket(af,socktype, proto)))
                #self.sock = socket.socket(af, socktype, proto)
                self.sock.connect(sa)
            except socket.error, msg:
                if self.sock:
                    self.sock.close()
                self.sock = None
                continue
            break
        if not self.sock:
            raise socket.error, msg

def main():
    try:
        (opts, args_proper)=getopt.getopt(sys.argv[1:], 'hdp:', [ 'help', 'debug', 'ssl', 'ssl-key=', 'ssl-cert=', 'ssl-verify=', 'port=' ])
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
            print "Port: ", Defaults.port
        elif opt == "--ssl":
            Defaults.ssl=True
        elif opt == "--ssl-key":
            Defaults.keyfile=value
        elif opt == "--ssl-cert":
            Defaults.certfile=value
        elif opt == "--ssl-verify":
            Defaults.verifyfile=value
        elif opt == "-h" or opt == "--help":
            usage(sys.argv)
            sys.exit(0)
        else:
            usage(sys.argv)
            sys.exit(0)
        index=index+1

    if Defaults.ssl:
        client=SSLTelnet(sys.argv[index+1], int(Defaults.port))
    else:
        ComLog.getLogger().debug("Connection to %s %u" %(sys.argv[index+1], int(Defaults.port)))
        client=MyTelnet(sys.argv[index+1], int(Defaults.port))
    try:
        if client.checkuser() >= 0:
            if client.checkpassword() < 0:
                client.close()
                print >>sys.stderr, "Wrong Username or password"

        client.interact()
    except:
        import traceback
        traceback.print_exc()

if __name__ == '__main__':
    main()

###################
# $Log: client.py,v $
# Revision 1.1  2006-08-28 16:04:46  marc
# initial revision
#