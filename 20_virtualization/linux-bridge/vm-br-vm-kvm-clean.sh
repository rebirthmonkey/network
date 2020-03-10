#!/usr/bin/env bash

sudo ip link set br88 down
sudo ip link set tap2 down
sudo ip link set tap3 down
sudo ip link del br88
sudo ip link del tap2
sudo ip link del tap3