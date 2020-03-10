# OpenVSwitch Pipeline Lab
## Network Device Setup
### TAP Creation
Create 4 TAP devices T1, T2, T3, T4, and activate them
```bash
for i in $(seq 4);do ip tuntap add dev p$i mod tap; ip link set p$i up; done
```

### OVS Creation
The `fail-mode=secure` creates an OVS with empty flow table
```bash
ovs-vsctl add-br br0 -- set bridge br0 fail-mode=secure
```

### Bind TAP to OVS
```bash
ovs-vsctl add-port br0 p1 -- set interface br0 ofport_request=1
ovs-vsctl add-port br0 p2 -- set interface br0 ofport_request=2
ovs-vsctl add-port br0 p3 -- set interface br0 ofport_request=3
ovs-vsctl add-port br0 p4 -- set interface br0 ofport_request=4
```

Show the `br0` details
```bash
ovs-vsctl show
```

## Flow Table Manipulation
### Table0
Drop packets whose source address is multicasting or `STP`
```bash
ovs-ofctl add-flow br0 table=0,dl_src=01:00:00:00:00:00/01:00:00:00:00:00,actions=drop
ovs-ofctl add-flow br0 table=0,dl_dst=01:80:c2:00:00:00/ff:ff:ff:ff:ff:f0,actions=drop
```

Forward other packets to `Table1`
```bash
ovs-ofctl add-flow br0 "table=0,priority=0,actions=resubmit(,1)"
```

Tests:
- send multicasting `ovs-appctl ofproto/trace br0 in_port=1,dl_src=01:00:00:00:00:00`: drop
- send `STP`: `ovs-appctl ofproto/trace br0 in_port=1,dl_dst=01:80:c2:00:00:05`: drop
- send a standard packet: `ovs-appctl ofproto/trace br0 in_port=1,dl_dst=b8:ca:3a:79:18:fe`: resubmit to `Table1`
<!--- - send a standard packet: `ovs-appctl ofproto/trace br0 in_port=1,vlan_tci=0`: resubmit to `Table1` --->



### Table1
If no other rules match, then drop the packet
```bash
ovs-ofctl add-flow br0 table=1,priority=0,actions=drop
```

Send all packets from port 1 to `Table2`
```bash
ovs-ofctl add-flow br0 "table=1,priority=99,in_port=1,actions=resubmit(,2)"
```

For all packets from port 2, 3, 4 and have no VLAN ID, set VLAN ID respectively to 20, 30, 40 and send to `Table2`
```bash
ovs-ofctl add-flow br0 "table=1,priority=99,in_port=2,vlan_tci=0,actions=mod_vlan_vid:20,resubmit(,2)"
ovs-ofctl add-flow br0 "table=1,priority=99,in_port=3,vlan_tci=0,actions=mod_vlan_vid:30,resubmit(,2)"
ovs-ofctl add-flow br0 "table=1,priority=99,in_port=4,vlan_tci=0,actions=mod_vlan_vid:30,resubmit(,2)"
```

Tests:
- send to port 1 without VLAN ID `ovs-appctl ofproto/trace br0 in_port=1,vlan_tci=0`: resubmit to `Table2`
- send to port 1 with VLAN ID `ovs-appctl ofproto/trace br0 in_port=1,vlan_tci=5`: resubmit to `Table2`
- send to port 2 without VLAN ID `ovs-appctl ofproto/trace br0 in_port=2,vlan_tci=0`: set VLAN ID to 20 and resubmit to `Table2`
- send to port 3 with VLAN ID `ovs-appctl ofproto/trace br0 in_port=3,vlan_tci=88`: drop


### Table2
Create a flow entry in `Table10` witch caches `Inport`-`VLAN ID` for other future packets: 
- match: `VLAN ID` set as 20, 30 or 40
- match: `destinatin MAC address` is the `source MAC address` of this packet
- do: store the `Inport` to `Reg0` which will be used by `Table4`
```bash
ovs-ofctl add-flow br0 "table=2 actions=learn(table=10, NXM_OF_VLAN_TCI[0..11],NXM_OF_ETH_DST[]=NXM_OF_ETH_SRC[],load:NXM_OF_IN_PORT[]->NXM_NX_REG0[0..15]),resubmit(,3)"
```

Tests:
- send a packet to `port1` with VLAN ID 20 `ovs-appctl ofproto/trace br0 in_port=1,vlan_tci=20,dl_src=40:00:00:00:00:01 -generate`
- send a packet to `port1` without VLAN ID `ovs-appctl ofproto/trace br0 in_port=1,dl_src=50:00:00:00:00:01 -generate`
- introduce a conflict `ovs-appctl ofproto/trace br0 in_port=3,vlan_tci=0,dl_src=60:00:00:00:00:01 -generate`
- introduce a conflict `ovs-appctl ofproto/trace br0 in_port=4,vlan_tci=0,dl_src=60:00:00:00:00:01 -generate`
- show Table10 `ovs-ofctl dump-flows br0 table=10`


### Table3
Send all packets to both `Table4` and `Table10`
```bash
ovs-ofctl add-flow br0 "table=3 priority=50 actions=resubmit(,10),resubmit(,4)"
```

Tests: 
- send a packet to `port1` with VLAN ID 20 `ovs-appctl ofproto/trace br0 in_port=1,vlan_tci=20,dl_src=40:00:00:00:00:01 -generate`
- send a packet to `port1` without VLAN ID `ovs-appctl ofproto/trace br0 in_port=1,dl_src=50:00:00:00:00:01 -generate`
- show Table10 `ovs-ofctl dump-flows br0 table=10`
                                            

### Table4
For all the packets that match `Table10` (`reg0!=0`)
```bash
ovs-ofctl add-flow br0 "table=4,reg0=1,actions=1" # action=1 means send to port 1
ovs-ofctl add-flow br0 "table=4,reg0=2,actions=strip_vlan,2"
ovs-ofctl add-flow br0 "table=4,reg0=3,actions=strip_vlan,3"
ovs-ofctl add-flow br0 "table=4,reg0=4,actions=strip_vlan,4"
```
For all the packets that don't match `Table10` (`reg0=0`)
```bash
ovs-ofctl add-flow br0 "table=4,reg0=0,priority=99,dl_vlan=20,actions=1,strip_vlan,2"
ovs-ofctl add-flow br0 "table=4,reg0=0,priority=99,dl_vlan=30,actions=1,strip_vlan,3,4"
ovs-ofctl add-flow br0 "table=4,reg0=0,priority=50,actions=1"
```

Tests:
- send a packet that matches `table10`: `ovs-appctl ofproto/trace br0 in_port=4,vlan_tci=0,dl_src=f0:00:00:00:00:01,dl_dst=60:00:00:00:00:01 -generate`
- send a packet that doesn't match `table10`: `ovs-appctl ofproto/trace br0 in_port=4,vlan_tci=0,dl_src=60:00:00:00:00:01,dl_dst=70:00:00:00:00:01 -generate`