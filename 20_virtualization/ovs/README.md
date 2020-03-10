# Open-VSwitch

## Commands
### `ovs-vsctl`
- `ovs-vsctl add-br sw`: add a new OVS bridge 
- `ovs-vsctl list bridge sw`: lookup
- `ovs-vsctl del-br sw`: remove the bridge
- `ovs-vsctl show`: show the `OVS` configuration of a server
  - `OVS manager` is for the whole server
  - `OVS controller` is for a dedicated switch

### `ovs-ofctl`
- `ovs-ofctl dump-flows sw`: show all the flow tables
  - `table=0`: output for one table
  - `--color`: don't work for `ssh`
- `ovs-ofctl del-flows sw`: cleanup the flow tables
- authorize all IP flows between 1 and 2:
```bash
ovs-ofctl add-flow sw arp,actions=normal
ovs-ofctl add-flow sw priority=800,ip,nw_src=8.8.8.7,nw_dst=8.8.8.8,actions=normal
ovs-ofctl add-flow sw priority=800,ip,nw_src=8.8.8.8,nw_dst=8.8.8.7,actions=normal
```
- `ovs-ofctl dump-flows sw`: show the flow tables


## OpenVSwitch Lab
- [OpenVSwitch Manipulation](ovs-manipulation.md)
- [Namespace-OVS-Namespace Communication](ns-ovs-ns.md)
- [Namespace-OVS-Namespace Communication bis](ns-ovs-ns-bis.md)
- [Namespace-OVS-Internet Communication](ns-ovs-ext.md)
- [???Namespace-OVS-Namespace-OVS-Internet Communication]()
- [VM-OVS-VM Communication: KVM](vm-ovs-vm-kvm.md)
- [VM-OVS-VM Communication: Libvirt](vm-ovs-vm-libvirt/vm-ovs-vm-libvirt.md)
- [Multi-Namespace-Br-OVS Scenario](multi-ns-br-ovs.md)
- [FlowTable Pipeline](ovs-pipeline.md)
- [VXLan Tunneling](tunneling/ovs-tunneling.md)