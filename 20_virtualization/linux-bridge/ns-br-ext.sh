#! /bin/bash

sudo service network-manager stop

ip netns add ns2

ip link add tap2 type veth peer name br-tap2
brctl addbr br88
brctl addif br88 br-tap2
brctl addif br88 enp0s3

ip link set br-tap2 up
ifconfig br88 up

dhclient br88

ip link set tap2 netns ns2
ip netns exec ns2 ip link set dev lo up
ip netns exec ns2 ip link set tap2 up
ip netns exec ns2 dhclient tap2