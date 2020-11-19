#!/usr/bin/env bash

ip netns del ns2
ip netns del ns3
ip link set dev br88 down
brctl delbr br88
ifconfig enp0s3 0
sudo rm /var/lib/dhcp/dhclient.leases
ifconfig br89 down
brctl delbr br89
ifconfig br-tap4 down
ip link delete br-tap4
sudo service network-manager restart