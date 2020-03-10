# Linux Bridge： Inter-Namespace Communication through Linux Bridge
Communication between 2 Namespaces

## Topology
![communicate between 2 namespaces through a Linux bridge](ns-br-ns.jpg) 

## Prerequisite
- VirtualBox Network on `Internal` mode

## Manipulation
- create 2 network namespaces:
```bash
ip netns add ns2
ip netns add ns3
ip netns list
```

- create 2 veth pairs:
```bash
ip link add dev tap2 type veth peer name br-tap2
ip link add dev tap3 type veth peer name br-tap3
```

- set veth to the namespaces:
```bash
ip link set tap2 netns ns2
ip link set tap3 netns ns3
```

- create and setup a Linux bridge `br88`: 
```bash
brctl addbr br88
brctl showmacs br88
brctl addif br88 br-tap2
brctl addif br88 br-tap3
brctl showmacs br88
```

- activate all the devices:
```bash
ip link set dev br-tap2 up
ip link set dev br-tap3 up
ip link set dev br88 up
ip netns exec ns2 ip link set dev lo up
ip netns exec ns2 ip link set dev tap2 up
ip netns exec ns3 ip link set dev lo up
ip netns exec ns3 ip link set dev tap3 up
brctl showmacs br88
```

- associate IP addresses to the devices: 
```bash
ip netns exec ns2 ip addr add 192.168.88.2/24 dev tap2
ip netns exec ns3 ip addr add 192.168.88.3/24 dev tap3
```

The script can be found [here](ns-br-ns.sh) and the cleanup script is [here](ns-br-ns-clean.sh)

## Test
```bash
ip netns exec ns2 ping 192.168.88.3
```

## Bug
In VirtualBox with `NAT` or `Bridge` network mode, maybe the ping doesn't work
- solution: activate forwarding in the VM: `iptables -P FORWARD ACCEPT`