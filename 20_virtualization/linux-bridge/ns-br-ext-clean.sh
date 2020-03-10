#!/usr/bin/env bash

ifconfig enp0s3 0
sudo rm /var/lib/dhcp/dhclient.leases
ifconfig br88 down
brctl delbr br88
ip netns del ns2
ifconfig br-tap2 down
ip link delete br-tap2