#!/usr/bin/python

import socket

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.connect(('localhost', 12242))

print "Connected to server"
data="""line1
line2
line3"""
for line in data.splitlines():
    sock.sendall(line+'\n')
    print "Sent: ",line
    response=sock.recv(8192)
    print "Received: ", response
sock.close()