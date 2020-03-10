#!/usr/bin/env bash

ifconfig enp0s3 0
sudo rm /var/lib/dhcp/dhclient.leases

ip link set dev ovs88 down
ovs-vsctl del-br ovs88

ip netns del ns2
ip link set dev ovs-tap2 down
ip link delete ovs-tap2

ip link set dev enp0s3 up
dhclient enp0s3