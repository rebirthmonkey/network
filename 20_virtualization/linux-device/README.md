# Linux Device Lab

## 主要流程

### ingress

入的流量进入一个网络设备，如果L2联通则先在L2流通，然后调用network stack交由route table。route table判断接下来数据包交由哪个网络设备处理，然后转交给该网络设备。

### egress

出的流量会直接调用network stack交由route table。route table判断该数据包交由哪个网络设备处理，然后转交给该网络设备。

## 网络栈

Linux网络栈包括了：网卡（Network Interface）、回环设备（Loopback Device）、路由表（Routing Table）和 iptables 规则。对于一个进程来说这些要素，其实就构成了它发起和响应网络请求的基本环境。

## Namespace


## VEth Pair
VEth Pair设备的特点是：它被创建出来后，总是以两张虚拟网卡（Veth Peer）的形式成对出现的。
从其中一个“网卡”发出的数据包，可以直接出现在与它对应的另一张“网卡”上，哪怕这两个“网卡”在不同的namespace里。
这就使得Veth Pair常常被用作连接不同Network Namespace的“网线”。

- [VEth Pair Lab](lab_veth/README.md)


## TUN/TAP

在 Linux 中，TUN 设备是一种工作在三层（Network Layer）的虚拟网络设备。TUN 设备的功能非常简单，即：在操作系统内核和用户应用程序之间传递 IP 包。以 flannel0 设备为例：当操作系统将一个 IP 包发送给 flannel0 设备之后，flannel0 就会把这个 IP 包，交给创建这个设备的应用程序，也就是 Flannel 进程。这是一个从内核态（Linux 操作系统）向用户态（Flannel 进程）的流动方向。反之，如果 Flannel 进程向 flannel0 设备发送了一个 IP 包，那么这个 IP 包就会出现在宿主机网络栈中，然后根据宿主机的路由表进行下一步处理，这是一个从用户态向内核态的流动方向。

- [Tap Lab](lab_tap/README.md)
