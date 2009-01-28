#!/bin/bash

wget --output-document=/tmp/tar.tar.gz $* &&
cd / &&
tar xvzf /tmp/tar.tar.gz &&
rm /tmp/tar.tar.gz
