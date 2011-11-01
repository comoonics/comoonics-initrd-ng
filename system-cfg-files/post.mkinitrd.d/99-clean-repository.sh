#!/bin/bash

for item in nodeid nodename; do
    echo_local_debug "Cleaning repository value $item"
    repository_del_value $item
done