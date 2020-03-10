#!/usr/bin/env bash

sudo ip link set ovs88 down
sudo ip link set tap2 down
sudo ip link set tap3 down
sudo ovs-vsctl del-br ovs88
sudo ip link del tap2
sudo ip link del tap3