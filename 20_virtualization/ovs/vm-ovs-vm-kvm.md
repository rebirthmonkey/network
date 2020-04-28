# OVS Bridge between VMs
## Topology
![communicate between 2 VMs through a OVS bridge](vm-ovs-vm.jpg)

## Network Devices
- create a OVS private bridge: `ovs-vsctl add-br ovs88`
- enable forwarding: `echo 1 > /proc/sys/net/ipv4/ip_forward` 
- create 2 *TAP* devices:
 ```bash
ip tuntap add mode tap tap2
ip tuntap add mode tap tap3
```
- activate 2 *TAP* devices:  
```bash
ip link set tap2 up
ip link set tap3 up
```
- bind 2 *TAP* devices:
```bash
ovs-vsctl add-port ovs88 tap2
ovs-vsctl add-port ovs88 tap3
ip link set dev ovs88 up
```
- check: `ovs-vsctl show`

## KVM
- launch VM2 and VM3:
```bash
qemu-system-x86_64 -hda debian_wheezy_amd64_standard2.qcow2 -device e1000,netdev=net0,mac=00:11:22:33:44:02 -netdev tap,id=net0,ifname=tap2,script=no,downscript=no -name vm2 -daemonize
qemu-system-x86_64 -hda debian_wheezy_amd64_standard3.qcow2 -device e1000,netdev=net0,mac=00:11:22:33:44:03 -netdev tap,id=net0,ifname=tap3,script=no,downscript=no -name vm3 -daemonize
```

The script for the configuration is [here](vm-ovs-vm-kvm.sh) and for cleanup is [here](vm-ovs-vm-kvm-clean.sh).

- configure IP address of each VM (login: `root`, password: `root`):
  - VM2:
```bash
ip link set tap2 up
ip addr add 192.168.88.2/24 dev tap2
```   
  - VM3: 
```bash
ip link set tap3 up
ip addr add 192.168.88.3/24 dev tap3
```

## Test
- in VM2: `ping 192.168.88.3`

## Cleanup
The cleanup script is [here](vm-ovs-vm-kvm-clean.sh)

### Minitor Traffic
Monitor Traffic between VM2 and VM3 from the host: `tcpdump -i tap1 icmp`
