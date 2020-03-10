# Linux Bridge with Namespace
Communication from namespace to Internet

## Topology
![communicate from a namespace to Internet through a Linux bridge](ns-br-ext.jpg) 

## Prerequisite
- VirtualBox Network on `NAT` mode
- In the VM, stop the `network-manager`: `sudo service network-manager stop`

## Manipulation
- create a namespace: `ip netns add ns2`

- create a VETH pair: `ip link add tap2 type veth peer name br-tap2`
- create a Linux bridge: `brctl addbr br88`
- bind VETH to the bridge: `brctl addif br88 br-tap2`
- bind physical interface to the bridge: `brctl addif br88 enp0s3`

- activate VETH: `ip link set br-tap2 up`
- activete Linux bridge: `ifconfig br88 up`

- get an IP address for the bridge: `dhclient br88` 

- put a VETH to the namespace: `ip link set tap2 netns ns2`
- activate interface in the namespace: `ip netns exec ns2 ip link set dev lo up`
- activate interface in the namespace: `ip netns exec ns2 ip link set tap2 up`

- get an IP address for the VETH: `ip netns exec ns2 dhclient tap2`

The script can be found [here](ns-br-ext.sh) and the cleanup script is [here](ns-br-ext-clean.sh)

## Test
- `ip netns exec ns2 ping 8.8.8.8`