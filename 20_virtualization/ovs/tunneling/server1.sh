#!/usr/bin/env bash


#clear
: '
La première fois que la vm est lancé, executer les commandes suivantes:
printf "auto enp0s3\n \
iface enp0s3 inet static\n \
netmask 255.255.255.0\n \
address 192.168.1.43\n \
gateway 192.168.1.13\n" >> /etc/network/interfaces
ifdown enp0s3
ifup enp0s3

A chaque redemarrage de la vm lancer:
route del -net 192.168.1.0 netmask 255.255.255.0 gw 0.0.0.0 dev enp0s3
'

#Crée le bridge
ovs-vsctl add-br br-tun

#Crée le namspace
ip netns add vm1

#crée le canal de communication en entre le namespace et le bridge
ip link add eth0-vm1 type veth peer name brtun-veth

#connecte les différentes interfaces
ip link set eth0-vm1 netns vm1
ovs-vsctl add-port br-tun brtun-veth
ovs-vsctl add-port br-tun enp0s3


#Configure l'adresse du bridge
ip link set brtun-veth up
ifconfig br-tun down
ifconfig br-tun 192.168.55.2 netmask 255.255.255.0 up

#Redirige le traffic local à travers le bridge
route add -net 192.168.1.0/24 gw 192.168.55.2 dev br-tun

#Map l'adresse de l'autre bout du VXLAN à l'adresse de son server
route add -net 192.168.50.0/24 gw 192.168.1.13 dev br-tun

#Configure le namespace
ip netns exec vm1 ip link set dev lo up
ip netns exec vm1 ip link set eth0-vm1 up
ip netns exec vm1 ip address add 10.0.0.1/24 dev eth0-vm1
ip netns exec vm1 ip link set dev eth0-vm1 address 00:00:00:00:00:01
ip netns exec vm1 ip route add default dev eth0-vm1


#Crée le VXLAN
ovs-vsctl add-port br-tun vtep -- set interface vtep type=vxlan option:local_ip=192.168.55.2 option:remote_ip=192.168.50.2 option:key=flow ofport_request=10

#Ajoute le header vxlan au paquets issuent du namespace et leur assigne une VNI (id de tunnel)
ovs-ofctl add-flow br-tun "table=0,in_port=1,actions=set_field:100->tun_id,resubmit(,1)"
ovs-ofctl add-flow br-tun "table=0,actions=resubmit(,1)"

#Règles permetant la communication entre les deux namespaces
ovs-ofctl add-flow br-tun "table=1,priority=150,tun_id=100,dl_dst=00:00:00:00:00:01,actions=output:1"
ovs-ofctl add-flow br-tun "table=1,priority=150,tun_id=100,dl_dst=00:00:00:00:00:02,actions=output:10"
ovs-ofctl add-flow br-tun "table=1,priority=150,tun_id=100,arp,nw_dst=10.0.0.1,actions=output:1"
ovs-ofctl add-flow br-tun "table=1,priority=150,tun_id=100,arp,nw_dst=10.0.0.2,actions=output:10"

#Autorise la communication entre les deux serveurs
ovs-ofctl add-flow br-tun "table=1,priority=50,actions=normal"