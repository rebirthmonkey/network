# Linux Network

## 网络设备
- [网络设备](devices.md)

## Route
- [路由](route.md)

## iptable
- [iptable](iptable.md)



## 整体原理

当在一个linux network namespace产生一个网络包后

- 通过route table来判断发给哪个网络设备来处理该包
- Linux的网络设备往往都是L2的，所以可通过L2跨namespace互联
- 当包通过如veth、bridge等进入另一个namespace时，会再次通过该namespace的route table判断发给哪个网络设备进行处理

注意：Linux bridge在默认情况下只是L2转发，除非开启bridge-nf-call-iptables，k8s节点上的Linux bridge默认开启。