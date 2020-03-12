# Multiple Namespaces with Linux and OVS Bridges 
## Scenario
![Multiple Namespaces with Linux and OVS Bridges](multi-ns-br-ovs.jpg)

## Manipulation
### Linux Bridge Part
- create 2 networking namespaces:
```bash
ip netns add green
ip netns add red
```
- create 4 *veth* pairs:
```bash
ip link add dev g-veth0 type veth peer name g-veth0-bis
ip link add dev r-veth0 type veth peer name r-veth0-bis
ip link add dev g-veth1 type veth peer name g-veth1-bis
ip link add dev r-veth1 type veth peer name r-veth1-bis
```
- create 2 Linux bridges:
```bash
brctl addbr g-bridge
brctl addbr r-bridge
```
- create 1 OVS bridge:
```bash
ovs-vsctl add-br ovs
```
- activate all devices:
```bash
ip link set dev g-bridge up
ip link set dev r-bridge up
ip link set dev g-veth0 up
ip link set dev g-veth0-bis up
ip link set dev r-veth0 up
ip link set dev r-veth0-bis up
ip link set dev g-veth1 up
ip link set dev g-veth1-bis up
ip link set dev r-veth1 up
ip link set dev r-veth1-bis up
```
- put devices to the 2 namespaces:
```bash
ip link set g-veth0 netns green
ip link set r-veth0 netns red
```
- activate devices in the namespaces:
```bash
ip netns exec green ip link set dev g-veth0 up
ip netns exec green ip link set dev lo up
ip netns exec red ip link set dev r-veth0 up
ip netns exec red ip link set dev lo up
```
- add IP addresses to the devices: 
```bash
ip netns exec green ip addr add 8.8.8.8/24 dev g-veth0
ip netns exec red ip addr add 8.8.8.9/24 dev r-veth0
```
- bind interface to Linux bridges:
```bash
brctl addif g-bridge g-veth0-bis
brctl addif g-bridge g-veth1-bis
brctl addif r-bridge r-veth0-bis
brctl addif r-bridge r-veth1-bis
```
- bind OVS bridge:
```bash
ovs-vsctl add-port ovs g-veth1
ovs-vsctl add-port ovs r-veth1
```
- first test:
```bash
ip netns exec red ping 8.8.8.8
```

### OVS Part
- cleanup Linux bridge settings:
```bash
ip netns exec green ip addr del 8.8.8.8/24 dev g-veth0
ip netns exec red ip addr del 8.8.8.9/24 dev r-veth0
```
- setup the green DHCP namespace with VLAN100: 
```bash
ip netns add g-dhcp
ovs-vsctl add-port ovs g-tap
ovs-vsctl set interface g-tap type=internal
ovs-vsctl set port g-tap tag=100
ovs-vsctl set port g-veth1 tag=100
ip link set g-tap netns g-dhcp
ip netns exec g-dhcp ip link set dev lo up
ip netns exec g-dhcp ip link set dev g-tap up
ip netns exec g-dhcp ip addr add 192.168.1.8/24 dev g-tap
ip netns exec g-dhcp dnsmasq --interface=g-tap --dhcp-range=192.168.1.10,192.168.1.20,255.255.255.0
ip netns exec green dhclient g-veth0
```     
- setup the red DHCP namespace with VLAN200:
```bash
ip netns add r-dhcp
ovs-vsctl add-port ovs r-tap
ovs-vsctl set interface r-tap type=internal
ovs-vsctl set port r-tap tag=200
ovs-vsctl set port r-veth1 tag=200
ip link set r-tap netns r-dhcp
ip netns exec r-dhcp ip link set dev lo up
ip netns exec r-dhcp ip link set dev r-tap up
ip netns exec r-dhcp ip addr add 192.168.1.8/24 dev r-tap
ip netns exec r-dhcp dnsmasq --interface=r-tap --dhcp-range=192.168.1.10,192.168.1.20,255.255.255.0
ip netns exec red dhclient r-veth0
```
- show new IP address in each namespace: 
```bash
ip netns exec green ip addr
ip netns exec red ip addr
```
- test:  
```bash
ip netns exec red ping 192.168.1.x
```
