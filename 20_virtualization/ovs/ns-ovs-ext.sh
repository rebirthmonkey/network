#! /bin/bash

service network-manager stop

ip netns add ns2

ip link add tap2 type veth peer name ovs-tap2

ovs-vsctl add-br ovs88
ovs-vsctl add-port ovs88 ovs-tap2
ovs-vsctl add-port ovs88 enp0s3

ip link set ovs-tap2 up
ifconfig ovs88 up

dhclient ovs88

ip link set tap2 netns ns2
ip netns exec ns2 ip link set dev lo up
ip netns exec ns2 ip link set tap2 up
ip netns exec ns2 dhclient tap2

ip netns exec ns2 ping 8.8.8.8