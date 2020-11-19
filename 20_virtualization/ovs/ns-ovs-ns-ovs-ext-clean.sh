#!/usr/bin/env bash

ip netns del ns2
ip netns del ns3
ip link set dev ovs88 down
ovs-vsctl del-br ovs88
ifconfig enp0s3 0
sudo rm /var/lib/dhcp/dhclient.leases
ip link set dev ovs89 down
ovs-vsctl del-br ovs89
ip link set dev ovs-tap4 down
ip link set dev ovs-tap3 down
ip link delete ovs-tap4
ip link delete ovs-tap3 
ip link set dev enp0s3 up
dhclient enp0s3