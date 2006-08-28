#!/usr/bin/python
"""
Fence Acknowledge Server via normal an ssl
"""

# here is some internal information
# $Id: shell.py,v 1.1 2006-08-28 16:04:46 marc Exp $
#


__version__ = "$Revision: 1.1 $"
# $Source: /atix/ATIX/CVSROOT/nashead2004/bootimage/fencing/fence-ack-server/shell.py,v $
import cmd
import sys
import pexpect
import fence_ack_server
from comoonics import ComLog
from comoonics import ComExceptions

class AuthorizationError(ComExceptions.ComException): pass

class ExpectShell(pexpect.spawn):
    def __init__(self, command, stdin=sys.stdin, stdout=sys.stdout):
        pexpect.spawn.__init__(self, command)
        self.stdin=stdin
        self.stdout=stdout
        self.STDIN_FILENO=self.stdin.fileno()
        self.STDOUT_FILENO=self.stdout.fileno()
        self.STDERR_FILENO=self.stdout.fileno()

class Shell(cmd.Cmd):
    def __init__(self, stdin=sys.stdin, stdout=sys.stdout, user=None, passwd=None):
        cmd.Cmd.__init__(self, 'tab', stdin, stdout)
        self.shell="/bin/bash"
        self.fence_cmd="/sbin/fence_node"
        self.prompt_name="Fence Acknowledge Shell"
        self.use_rawinput=0
        self.oldprompt=""
        self.user=user
        self.passwd=passwd

    def check_for_fence_manual(self):
        import os.path
        return os.path.exists(fence_ack_server.FENCE_MANUAL_FIFO) and os.path.exists(fence_ack_server.FENCE_MANUAL_LOCKFILE)

    def preloop(self):
        ComLog.getLogger().debug("User: %s, Password: %s" %(self.user, "***"))

        if self.user and self.passwd:
            self.stdout.write("Username: ")
            self.stdout.flush()
            user=self.stdin.readline()
            user=user.splitlines()[0]
            self.stdout.write("Password: ")
            self.stdout.flush()
            passwd=self.stdin.readline()
            passwd=passwd.splitlines()[0]
            ComLog.getLogger().debug("User: %s, Password: %s" %(user, "***"))
            if self.user!=user or self.passwd!=passwd:
                print >>self.stdout, "Wrong username or password"
                raise AuthorizationError("Wrong username or password")
        self.precmd()

    def precmd(self, s=""):
        if self.check_for_fence_manual():
            if self.oldprompt == "":
                self.oldprompt=self.prompt
            self.prompt="""Fence manual is in progress. Please make sure the fenced node is powercylcled and
execute ackmanual here.
%s""" % self.oldprompt
        else:
            if self.oldprompt != "":
                self.prompt=self.oldprompt
        return s

    def do_shell(self, rest):
        ComLog.getLogger().debug("starting a shell..")
        child=ExpectShell(self.shell, self.stdin, self.stdout)
        child.setecho(False)
        COMMAND_PROMPT = "<%s> " % (self.prompt_name)
        child.sendline ("PS1='<"+self.prompt_name+"> [\u@\h \W]\$ '") # In case of sh-style
        i = child.expect ([pexpect.TIMEOUT, COMMAND_PROMPT], timeout=10)
        if i == 0:
            print >>self.stdout, "# Couldn't set sh-style prompt -- trying csh-style."
            child.sendline ("set prompt='[PEXPECT]\$ '")
            i = child.expect ([pexpect.TIMEOUT, COMMAND_PROMPT], timeout=10)
            if i == 0:
                print >>self.stdout, "Failed to set command prompt using sh or csh style."
                print >>self.stdout, "Response was:"
                print >>self.stdout, child.before
                exit=True
        try:
            child.interact()
        except:
            pass
        sys.stdin=sys.__stdin__
        sys.stderr=sys.__stderr__

    def help_shell(self):
        print >>self.stdout, "Starts a normal shell (%s)" %(self.shell)

    def help_version(self):
        print >>self.stdout, "Prints the version of this service" %(self.shell)

    def do_version(self, rest):
        print >>self.stdout, 'Version $Revision: 1.1 $'

    def help_fence_node(self):
        print >>self.stdout, "Fenced the given node"

    def do_fence_node(self, rest):
        from comoonics import ComSystem
        (rc, out) = ComSystem.execLocalStatusOutput("%s %s" %(self.fence_cmd, rest))
        print >>self.stdout, "Output: "+out

    def do_ackmanual(self, rest):
        print >>self.stdout, """Warning:  If the node has not been manually fenced
            (i.e. power cycled or disconnected from shared storage devices)
            the GFS file system may become corrupted and all its data
            unrecoverable!  Please verify that the node shown above has
            been reset or disconnected from storage."""
        import os
        if self.check_for_fence_manual():
            fifo=open(fence_ack_server.FENCE_MANUAL_FIFO, "w", 0)
            print >>fifo, fence_ack_server.FENCE_ACK_STRING
            fifo.close()
        else:
            print >>self.stdout, "Not fence_manual in progress that means that"
            print >>self.stdout, "Either %s not existing or %s not existing." %(fence_ack_server.FENCE_MANUAL_FIFO, fence_ack_server.FENCE_MANUAL_LOCKFILE)
        self.lastcmd=""

    def help_ackmanual(self):
        print >>self.stdout, "Acknowledges a previously manual fenced node"
        print >>self.stdout, """Warning:  If the node has not been manually fenced
            (i.e. power cycled or disconnected from shared storage devices)
            the GFS file system may become corrupted and all its data
            unrecoverable!  Please verify that the node shown above has
            been reset or disconnected from storage."""

    def do_print(self, rest):
        print >>self.stdout, rest
    def help_print(self):
        print >>self.stdout, "print (any string): outputs (any string)"
    def do_stop(self, rest):
        return 1
    def help_stop(self):
        print >>self.stdout, "stop: terminates the command loop"
    def do_exit(self, rest):
        return 1
    def help_exit(self):
        print >>self.stdout, "exit: terminates the command loop"

if __name__ == '__main__':
    Shell().cmdloop()

##############
# $Log: shell.py,v $
# Revision 1.1  2006-08-28 16:04:46  marc
# initial revision
#