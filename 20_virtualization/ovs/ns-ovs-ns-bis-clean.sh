#!/usr/bin/env bash

ip netns del ns2
ip netns del ns3
ip link set dev ovs88 down
ovs-vsctl del-br ovs88