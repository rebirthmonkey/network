# 网络基础

## 标准流程

### 协议流程

node1（src）向node2（des）发送ping请求：

- 域名转IP：通过DNS获得node2的IP地址desIP

- 如果desIP与srcIP在一个子网中
  
  - 通过ARP把desIP转换成desMAC
  - 获取srcIP对应的网卡及srcMAC
  - 以**desMAC srcMAC desIP srcIP**的形式将packet寄给des
  
- 如果desIP与srcIP不在一个子网中，src查看它自身的route table

  - 如果desIP在route table中，则按route table把packet传递给指定hop
    - 在route table中获得hopIP
    - 通过ARP把hopIP转换成hopMAC
    - 在route table中获取对应网卡及srcMAC
    - 以**hopMAC srcMAC desIP srcIP**的形式将packet寄给hop
  - 如果desIP不在route table中，则把packet送到default gateway
    - 在route table中获得gwIP
    - 通过ARP吧gwIP转换成gwMAC
    - 在route table中获取对应网卡及srcMAC
    - 以**gwMAC srcMAC desIP srcIP**的形式将packet寄给GW

### 重要原则

- L3 desIP和srcIP不会在路由期间修改
- L2 desMAC和srcMAC会在每一跳过程中修改
- L2设备，如switch，不修改包头
- L3设备，如router，会修改desMAC和srcMAC从而实现往下一跳的接力

