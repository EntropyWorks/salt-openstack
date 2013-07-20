#!/bin/bash
# dirty check to see if things are actually HA
my_ip=$(ip addr show bond0 | grep "inet "| awk '{print $2}')
cluster="{% for key, args in pillar['endpoints']['rabbit']['servers'].iteritems() %}{{ args }} {% endfor %}"
ports="5671 3306"
for port in ${ports} ; do
        echo "-------------------------------------------"
        echo "Testing: ${cluster}"
        echo "Port: ${port}"
        echo "From: ${my_ip} "
        echo "-------------------------------------------"
        for ip in ${cluster}; do
                nc -vz -w1 ${ip} ${port} ;
        done
done
