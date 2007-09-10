#!/usr/bin/python
"""
Fence Acknowledge Server via normal an ssl
"""

# here is some internal information
# $Id: shell.py,v 1.7 2007-09-10 15:01:00 marc Exp $
#


__version__ = "$Revision: 1.7 $"
# $Source: /atix/ATIX/CVSROOT/nashead2004/bootimage/fencing/fence-ack-server/shell.py,v $
import cmd
import os
import sys
import re
import inspect
import fence_ack_server
import logging
from comoonics import ComLog, ComSystem
from comoonics import ComExceptions
from comoonics import pexpect
from comoonics.ComSystemInformation import SystemInformation
logger=ComLog.getLogger("comoonics.bootimage.fenceacksv.shell")

try:
    from comoonics.fenceacksv import plugins
except ImportError:
    logger.warn("Could not import fenceacksv plugins. Limited functionality available.")

class AuthorizationError(ComExceptions.ComException): pass
class CouldNotFindFile(ComExceptions.ComException): pass
class CouldNotSendSignal(ComExceptions.ComException): pass
class CouldNotStartService(ComExceptions.ComException): pass

class ExpectShell(pexpect.spawn):
    def __init__(self, command, stdin=sys.stdin, stdout=sys.stdout):
        pexpect.spawn.__init__(self, command)
        #self.stdin=stdin
        #self.stdout=stdout
        #self.stderr=stdout
        #sys.stdin=self.stdin
        #sys.stdout=self.stdout
        self.STDIN_FILENO=stdin.fileno()
        self.STDOUT_FILENO=stdout.fileno()
        self.STDERR_FILENO=stdout.fileno()

class Shell(cmd.Cmd):
    """
    FENCEACKSV-Shell:
    *****************
    This shell is a rescue shell to manage a clusternode. Below you'll see all commands and plugins available.
    """
    def __init__(self, stdin=sys.stdin, stdout=sys.stdout, user=None, passwd=None):
        cmd.Cmd.__init__(self, 'tab', stdin, stdout)
        self.shell="/bin/bash"
        self.fence_cmd="/sbin/fence_node"
        self.prompt_name="Fence Acknowledge Shell"
        self.use_rawinput=1
        self.oldprompt=""
        self.user=user
        self.passwd=passwd
        self.sysinfo=SystemInformation()
        self.prompt="FENCEACKSV %s<%s>$ " %(self.sysinfo.getName(), self.sysinfo.getType())
        try:
            self.plugins=plugins.getRegistry()
            logger.debug("Plugins: %s" %self.plugins)
        except:
            self.plugins=None
        self.doc_header=inspect.getdoc(self)
        sys.stdin=self.stdin
        sys.stdout=self.stdout

    def do_help(self, arg):
        if arg:
            _cmd, _arg, _line = self.parseline(arg)
            # XXX check arg syntax
            try:
                func = getattr(self, 'help_' + _cmd)
            except AttributeError:
                try:
                    doc=getattr(self, 'do_' + _cmd).__doc__
                    if doc:
                        self.stdout.write("%s\n"%str(doc))
                        return
                except AttributeError:
                    if self.plugins:
                        for _plugin in self.plugins:
                            if plugins.getPlugin(_plugin).hasCommand(_cmd):
                                print plugins.getPlugin(_plugin).help(_line)
                                return
                self.stdout.write("%s\n"%str(self.nohelp % (_line,)))
                return
            func(_arg)
        else:
            names = self.get_names()
            cmds_doc = []
            cmds_undoc = []
            help = {}
            for name in names:
                if name[:5] == 'help_':
                    help[name[5:]]=1
            names.sort()
            # There can be duplicates if routines overridden
            prevname = ''
            for name in names:
                if name[:3] == 'do_':
                    if name == prevname:
                        continue
                    prevname = name
                    cmd=name[3:]
                    if cmd in help:
                        cmds_doc.append(cmd)
                        del help[cmd]
                    elif getattr(self, name).__doc__:
                        cmds_doc.append(cmd)
                    else:
                        cmds_undoc.append(cmd)
            self.stdout.write("%s\n"%str(self.doc_leader))
            doc_header=self.doc_header
            if self.plugins:
                for _pluginname in self.plugins:
                    _plugin=plugins.getPlugin(_pluginname)
                    _plugins_header="%s type \"help plugin %s\" to get more information" %(_plugin.getName(), _plugin.getName())
                    # _plugins_header+=_plugin.help_short()
                    _cmds=_plugin.getCommands()
                    doc_header+="\nPlugin %s:\n %s"%(_plugin.getName(), _plugins_header)
                    cmds_doc+=_cmds
            self.print_topics(doc_header,   cmds_doc,   15,80)
            self.print_topics(self.misc_header,  help.keys(),15,80)
            self.print_topics(self.undoc_header, cmds_undoc, 15,80)

    def help_plugin(self, arg):
        logger.debug("help_plugin(%s)" %arg)
        try:
            if arg and arg!="":
                _pluginname=re.split("\s+", arg)[0]
                _plugin=plugins.getPlugin(_pluginname)
                print >>self.stdout, _plugin.help()
            else:
                print >>self.stdout, "Please give a pluginname as option. Valid plugins are: %s" %(", ".join(plugins.getPluginnames()))
        except NameError:
            print >>self.stdout, "No plugins found"

    def completenames(self, text, *ignored):
        _complete=cmd.Cmd.completenames(self, text, *ignored)
        if self.plugins:
            for _pluginname in self.plugins:
                _plugin=plugins.getPlugin(_pluginname)
                for _cmd in _plugin.getCommands():
                    if _cmd.startswith(text):
                        _complete.append(_cmd)
        return _complete
    def complete_default(self, *ignored):
        logger.debug("complete(ignored: %s" %(ignored))

    def default(self, _line):
        _cmd, _arg, _line = self.parseline(_line)
        if self.plugins:
            for _pluginname in self.plugins:
                _plugin=plugins.getPlugin(_pluginname)
                if _plugin.hasCommand(_cmd):
                    try:
                        (_params, _kwds)=self.parseArgs(_arg)
                        logger.debug("default: calling %s.doCommand(%s, params: %s, kwds: %s)" %(_pluginname, _cmd, _params, _kwds))
                        return _plugin.doCommand(_cmd, *_params, **_kwds)
                    except Exception, e:
                        self.stdout.write("Error: %s\n" %e)
                        ComLog.debugTraceLog(logger)
                        return

        cmd.Cmd.default(self, _line)

    def parseArgs(self, _line):
        params=list()
        keys=dict()
        if _line and _line != "":
            _MATCH_KEY=re.compile("(?P<key>[^=]+)=(?P<value>\S+)")
            _params=re.split("\s+", _line)
            for _param in _params:
                _match=_MATCH_KEY.match(_param)
                if _match:
                    keys[_match.group("key")]=_match.group("value")
                else:
                    params.append(_param)
        return (params, keys)

    def check_for_fence_manual(self):
        import os.path
        return os.path.exists(fence_ack_server.FENCE_MANUAL_FIFO) and os.path.exists(fence_ack_server.FENCE_MANUAL_LOCKFILE)

    def check_for_pending_fence_clients(self):
        import re
        import os
        regexp=re.compile(fence_ack_server.FENCE_CLIENT_RE)
        pending=list()
        for file in os.listdir(fence_ack_server.PID_DIR):
            if regexp.match(file):
                logger.debug("check_for_pending_fence_clients match: %s" % file)
                pending.append(file)
        return pending

    def preloop(self):
        cmd.Cmd.preloop(self)
        logger.debug("User: %s, Password: %s" %(self.user, "***"))

        if self.user and self.passwd:
            self.stdout.write("Username: ")
            self.stdout.flush()
            user=self.stdin.readline()
            user=user.splitlines()[0]
            self.stdout.write("Password: ")
            self.stdout.flush()
            passwd=self.stdin.readline()
            passwd=passwd.splitlines()[0]
            logger.debug("User: %s, Password: %s" %(user, "***"))
            if self.user!=user or self.passwd!=passwd:
                print >>self.stdout, "Wrong username or password"
                raise AuthorizationError("Wrong username or password")
        self.orig_prompt=self.prompt
        self.postcmd("", "")
        self.stdout.write("Fenceacksv")
        self.do_version("")
        print >>self.stdout, self.sysinfo

    def precmd(self, s=""):
        self.prompt=self.orig_prompt
        return s

    def postcmd(self, stop, line):
        if self.check_for_fence_manual():
            print >>self.stdout, """Warning:  If the node has not been manually fenced
                (i.e. power cycled or disconnected from shared storage devices)
                the GFS file system may become corrupted and all its data
                unrecoverable!  Please verify that the node shown above has
                been reset or disconnected from storage."""
            self.prompt="""Fence manual is in progress. Please make sure the fenced node is powercylcled and
execute ackmanual here.
%s""" % self.orig_prompt

        pending=self.check_for_pending_fence_clients()
        if pending and len(pending) > 0:
            self.prompt="""
The following fenceclients seem to be pending you can kill them by the command kill pidfile
"""
            for file in pending:
                self.prompt=self.prompt+"""
%s/%s""" % (fence_ack_server.PID_DIR, file)

            self.prompt=self.prompt+"\n"+self.orig_prompt
        return stop

    def do_debug(self, rest):
        """
        Set debugmode on
        """
        ComLog.setLevel(logging.DEBUG)

    def do_info(self, rest):
        """
        Set info level
        """
        ComLog.setLevel(logging.INFO)

    def do_ask(self, rest):
        """
        Toggle askmode
        """
        if ComSystem.getExecMode()==ComSystem.ASK:
            logger.debug("Setting execmode to none")
            ComSystem.setExecMode("")
        else:
            logger.debug("Setting execmode to ask")
            ComSystem.setExecMode(ComSystem.ASK)
        print >>self.stdout, "Askmode is now: \"%s\"" %ComSystem.getExecMode()

    def do_shell(self, rest):
        _shell=self.shell
        if rest and rest != "":
            _shell=self.shell+" -c '%s'" %rest
        logger.debug("starting a shell.. %s" %_shell)
        self.child=ExpectShell(_shell, self.stdin, self.stdout)
        self.child.setecho(False)
        COMMAND_PROMPT = re.compile(".+$")
        self.child.sendline ("PS1='SHELL %s'" %self.prompt) # In case of sh-style
        i = self.child.expect ([pexpect.TIMEOUT, COMMAND_PROMPT], timeout=10)
        if i == 0:
            print >>self.stdout, "# Couldn't set sh-style prompt -- trying csh-style."
            self.child.sendline ("set prompt='[PEXPECT]\$ '")
            i = self.child.expect ([pexpect.TIMEOUT, COMMAND_PROMPT], timeout=10)
            if i == 0:
                print >>self.stdout, "Failed to set command prompt using sh or csh style."
                print >>self.stdout, "Response was:"
                print >>self.stdout, self.child.before
                exit=True
        try:
            if rest and rest != "":
                print >> self.stdout, self.child.after
                #self.child.sendeof()
            else:
                #self.child.sendline("")
                self.child.interact(chr(29), None, self.shell_output_filter)
        except Exception, e:
            logger.error("Error: %s" %e)
            print >>self.stdout, "Error: %s" %e
            ComLog.debugTraceLog(logger)
            self.child.close()
            self.child=None
            self.stdin.flush()
            self.stdout.flush()
            self.do_exit("")
        self.lastcmd=""
        #sys.stdin=sys.__stdin__
        #sys.stderr=sys.__stderr__

    def shell_output_filter(self, _output):
        logger.debug("output: %s" %_output)
        return _output

    def shell_input_filter(self, _input):
        #import struct
        #_break=struct.pack("ccccc", '\xff', '\xf4', '\xff', '\xfd', '\x06')
        #_return=struct.pack("cc", '\n', '\r')
        #i=_input.rfind(_break)
        #logger.debug("i: %u" %i)
        #if i >= 0:
        #    logger.debug("sending breaksignal to child")
        #    raise pexpect.EOF, "Break was send"
        logger.debug("Input: %s" %_input)
        return _input

    def help_shell(self):
        print >>self.stdout, "Starts a normal shell (%s)" %(self.shell)

    def help_version(self):
        print >>self.stdout, "Prints the version of this service" %(self.shell)

    def do_version(self, rest):
        print >>self.stdout, 'Version $Revision: 1.7 $'

    def help_fence_node(self):
        print >>self.stdout, "Fenced the given node"

    def do_fence_node(self, rest):
        from comoonics import ComSystem
        (rc, out) = ComSystem.execLocalStatusOutput("%s %s" %(self.fence_cmd, rest))
        print >>self.stdout, "Output: "+out
        self.lastcmd=""

    def do_ackmanual(self, rest):
        print >>self.stdout, "Acknowleding fencing..."
        import os
        if self.check_for_fence_manual():
            fifo=open(fence_ack_server.FENCE_MANUAL_FIFO, "w", 0)
            logger.debug("Writing %s to fifo")
            print >>fifo, fence_ack_server.FENCE_ACK_STRING
            logger.debug("closing fifo")
            fifo.close()
            import time
            logger.debug("waiting one second")
            time.sleep(1)
        else:
            print >>self.stdout, "No fence_manual in progress that means that"
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

    def help_start(self):
        print >>self.stdout, """Starts the given service (start cmd).
        """
    def do_start(self, rest):
        self.startService(rest)

    def help_restart(self):
        print >>self.stdout, """Restarts the given service (restart cmd [pidfile]).
        """
    def do_restart(self, rest):
        service_params=rest.split(" ")
        import os.path
        #logger.debug("rest %s =>%s" %(service_params[-1], os.path.splitext(service_params[-1])[1]))
        if not os.path.exists(service_params[-1]) or os.path.splitext(service_params[-1])[1] != ".pid":
            cmd=" ".join(service_params)
            service_name=os.path.basename(cmd.split(" ")[0])
            pidfile="%s/%s.pid" %(fence_ack_server.PID_DIR, service_name)
            #logger.debug("cmd: %s, service_name: %s, pidfile: %s" %(cmd, service_name, pidfile))
        else:
            cmd=" ".join(service_params[:-1])
            service_name=os.path.basename(cmd.split(" ")[0])
            pidfile=service_params[-1]
        try:
            self.killService(service_name, pidfile)
            self.startService(cmd)
        except:
            print >>self.stdout, "Could not restart service %s with cmd %s" %(service_name, cmd)
        self.lastcmd=""

    def help_stop(self):
        print >>self.stdout, """Stops a running services (stop service [pidfile]).
 Pidfile defaults to %s/servicename.pid """  %(fence_ack_server.PID_DIR)

    def do_stop(self, rest):
        try:
            service_params=rest.split(" ")
            if len(service_params) == 1:
                service_params.append(None)
            self.killService(service_params[0], service_params[1])
        except CouldNotFindFile, cnf:
            print >>self.stdout, "Could not find file %s" %(service_params[0])
        except:
            print >>self.stdout, "Could not kill service %s" %(rest)
        self.lastcmd=""

    def help_kill(self):
        print >>self.stdout, """Kills a running service (kill pidfile)."""

    def do_kill(self, rest):
        try:
            import os.path
            self.killService(os.path.splitext(os.path.basename(rest))[0], rest)
        except CouldNotFindFile, cnf:
            print >>self.stdout, "Could not find file %s" %(rest)
        except:
            print >>self.stdout, "Could not kill pid for %s" %(rest)
        self.lastcmd=""

    def do_exit(self, rest):
        return 1
    def help_exit(self):
        print >>self.stdout, "exit: terminates the command loop"

    def getPid(self, pidfile):
        import os.path
        try:
            pidf=open(pidfile)
            pid=pidf.readline()
            pid=int(pid)
            pidf.close()
            return pid
        except:
            raise CouldNotFindFile(pidfile)

    def killService(self, service_name, pidfile=None, signal=9):
        logger.debug("Killing service %s.." % service_name)
        if not pidfile:
            pidfile="%s/%s.pid" %(fence_ack_server.PID_DIR, service_name)
        logger.debug("Killing service %s/%s.." % (service_name, pidfile))
        pid=self.getPid(pidfile)
        logger.debug("Killing service %s/%s/%u.." % (service_name, pidfile, pid))
        print >>self.stdout, "Killing pid for %s:%u" %(service_name, pid)
        os.kill(pid, signal)
        os.remove(pidfile)
        print >>self.stdout, "OK"


    def startService(self, cmd):
        import os.path
        from comoonics import ComSystem
        service_name=os.path.basename(cmd.split(" ")[0])
        print >>self.stdout, "Starting service %s" %service_name
        #rc=os.system(cmd)
        (rc, out) = ComSystem.execLocalStatusOutput('/bin/sh -c "exec 0>&- 1>&- 2>&- 3>&- 4>&-; %s"' %cmd)
        if out and out != "":
            print >>self.stdout, out
        if rc>>8 > 0:
            print >>self.stdout, "Could not start service y command %s." % cmd
        else:
            print >>self.stdout, "OK"

if __name__ == '__main__':
    try:
        from comoonics.fenceacksv.plugins.ComSysreportPlugin import SysreportPlugin
        import comoonics.fenceacksv.plugins
        comoonics.fenceacksv.plugins.addPlugin(SysreportPlugin("../../../../comoonics-clustersuite/python/sysreport"))
    except:
        pass
    Shell().cmdloop()

##############
# $Log: shell.py,v $
# Revision 1.7  2007-09-10 15:01:00  marc
# - BZ #108, fixed problems with not installed plugins
#
# Revision 1.6  2007/09/10 08:14:44  marc
# - fixed output of ackmanual being before executing it BZ#19
#
# Revision 1.5  2007/09/07 14:22:34  marc
# - support for plugins (see comoonics.fenceacksv.plugins)
#   e.g sysrq and sysreport
# - rewritten documentation and being more helpful
#
# Revision 1.4  2006/12/04 17:39:04  marc
# Bugfix #19
#
# Revision 1.3  2006/09/18 12:16:00  marc
# added restart, kill, start, stop options
#
# Revision 1.2  2006/09/07 16:43:14  marc
# support for killing pidfiles
# support for restarting processes
#
# Revision 1.1  2006/08/28 16:04:46  marc
# initial revision
#