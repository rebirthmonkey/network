# Linux Bridge
## 简介

在Linux中能够起到虚拟交换机作用的网络设备是网桥（Bridge）。在一般模式下，它是一个L2的转发设备，主要功能是根据MAC地址学习来将数据包转发到网桥的不同端口（Port）上。

但当它开启bridge-nf-call-iptables之后，就变成一个网卡模式。从任何一个port收到数据包之后，会调用网络栈交由route table进行路由判断，从而交给指定的网络设备处理（也可以交回给bridge本身）。

一旦一张虚拟网卡被“插”在网桥上，它就会变成该网桥的“从设备”。从设备会被“剥夺”调用网络协议栈处理数据包的资格，从而“降级”成为网桥上的一个端口。而这个端口唯一的作用，就是接收流入的数据包，然后把这些数据包的“生杀大权”（比如转发或者丢弃），全部交给对应的网桥。


## Lab
- [Namespace-Bridge-Namespace Communication](ns-br-ns.md)
- [Namespace-Bridge-Internet Communication](ns-br-ext.md)
- [???Namespace-Bridge-Namespace-Bridge-Internet Communication]()：帮着实现以下
- [VM-Bridge-VM Communication](vm-br-vm-kvm.md)
- [???VM-Bridge-Internet Communication](vm-br-ext.md)