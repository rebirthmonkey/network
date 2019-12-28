# VLAN

VLAN是在一个LAN中通过VLAN ID来建立多个VLAN，VLAN ID对应的bit是在Ethernet frame的payload的开头12bit，所以VLAN ID的大小是2^12=4096，在同一个L2网段上最多有4094（4096-2）个VLANs。Host虽然L2上连接在一起，但是逻辑上被分在了不同的VLAN上。VLAN中的一个host广播时，只有同一VLAN中的其他host可以收到。它其实就是把一个LAN广播域分成了多个VLAN广播域。在L3层把VLAN等同于L2 LAN对待。

### Port-based VLAN

Port-based VLAN的原理是把连接到一个switch的某几个端口的L2网段组成一个VLAN（直观上讲，就是把这几个ports组成一个mini-switch）。根据端口来划分VLAN，被设定的端口都在同一个VLAN中。例如，一个switch的1、2端口被定义为VLAN A，3、4端口组成VLAN B。

当支持VLAN的switch收到一个frame时：
-	如果这个frame来自非VLAN的环境（frame中无VLAN ID）：
	o	switch根据srcPort为frame插入一个VLAN ID，形成一个新的frame：desMAC@, srcMAC@, VLANID, data
	
- switch根据其“MAC@--port--VLANID”表列出该frame所在的VLAN的所有“MAC@--port--VLANID”行

- 如果是广播：switch会把该frame发送到该VLAN ID对应的所有ports上

-	如果不是广播：
	
	- 如果switch的表中存在desMAC@：switch会把frame发送到desMAC@对应的port上去

	-	如果switch的表中不存在desMAC@：switch会把frame广播到该VLAN ID的所有ports上
	
- 当frame出switch时：
	
	-	如果被发送的port连接一个VLAN的device，那么frame不做任何改动
	-	如果被发送的port连接到一个非VLAN的device，那么switch会把VLAN ID从frame中去除

#### 跨switch VLAN

这种划分模式将VLAN限制在了一台switch上。第二代port-based VLAN技术允许跨越多个switch的多个不同端口划分VLAN，不同switch上的若干个端口可以组成一个VLAN。Trunk port是用来连接多个switch，使它们之间可以进行switching table的交换，完成跨switch的L2通信。
-	L2 Intra-VLAN no Route Mode：当需要连接多个switch组成一个L2网络时，switch之间通过trunk port连接。当frame的desMAC@是在另一个switch上时，本switch的table上不存这条规则，所以switch会在对应的VLAN中广播这个frame。这时除了本switch的对应VLAN ports会收到外，trunk port也会收到这个frame，并把它传送到desSwitch上。desSwitch通过table把frame再传送到desPort上去。
-	L3 Inter-VLAN Route Mode：当网络中的不同VLAN间进行相互通信时，需要router的支持。Switch的trunk port直接连到router上，当switch发现VLAN ID不同时，把此frame直接通过trunk port发送到router上去，并通过L3路由此packet。

### MAC-based VLAN

根据每个host的MAC@来划分，配置哪个MAC@的host属于哪个VLAN。这种划分方法的优点在于当host物理位置移动时，即从一个switch换到其他switch时，VLAN不用重新配置。这种方法的缺点是初始化时，所有的用户都必须进行配置。这种划分的方法也导致了switch执行效率的降低，因为在每一个switch的端口都可能存在很多个VLAN组的成员，这样就无法限制广播包了。

### IP-based VLAN

这是比较主流的方案，这种划分方法是根据每个host的IP@划分。这种方法的优点是用户的物理位置改变了，不需要重新配置所属的VLAN，而且不需要附加的frame tag来识别VLAN。这种方法的缺点是效率低，因为检查每一个数据包的IP@是需要消耗更多时间。

