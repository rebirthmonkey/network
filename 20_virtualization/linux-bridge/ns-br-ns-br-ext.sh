#!/usr/bin/env bash

service network-manager stop
iptables -P FORWARD ACCEPT

# create 2 network namespaces:
ip netns add ns2
ip netns add ns3
ip netns list

# create 3 veth pairs:
ip link add dev tap2 type veth peer name br-tap2
ip link add dev tap3 type veth peer name br-tap3
ip link add dev tap4 type veth peer name br-tap4

# set veth to the namespaces:
ip link set tap2 netns ns2
ip link set tap3 netns ns3
ip link set tap4 netns ns3

# create and setup a Linux bridge `br88`:
brctl addbr br88
# brctl showmacs br88
brctl addif br88 br-tap2
brctl addif br88 br-tap3
brctl showmacs br88

# create and setup a Linux bridge `br89`:
brctl addbr br89
# brctl showmacs br89
brctl addif br89 br-tap4
brctl addif br89 enp0s3
brctl showmacs br89

# activate all the devices:
ip link set dev br-tap2 up
ip link set dev br-tap3 up
ip link set dev br-tap4 up
ip link set dev br88 up
ifconfig br89 up
dhclient br89 #get a ip address for the bridge 
ip netns exec ns2 ip link set dev lo up
ip netns exec ns2 ip link set dev tap2 up
ip netns exec ns3 ip link set dev lo up
ip netns exec ns3 ip link set dev tap3 up
ip netns exec ns3 ip link set dev tap4 up
ip netns exec ns3 dhclient tap4
brctl showmacs br88
brctl showmacs br89

# associate IP addresses to the devices:
ip netns exec ns2 ip addr add 192.168.88.2/24 dev tap2
ip netns exec ns3 ip addr add 192.168.88.3/24 dev tap3


# Test
ip netns exec ns2 ping 8.8.8.8
