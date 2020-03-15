# Linux Device TAP Lab

## TAP Device Manipulation
- create a TAP device: `ip tuntap add dev tap89 mode tap`
- attach an IP address: `ip addr add 192.168.88.88/24 dev tap89`
- listen to port 8888 for all network devices: `nc -l -p 8888`
- open another terminal, establish a session on the port 8888 of `tap89`, and send messages: `nc 192.168.88.88 8888`
- we can send messages now


## Send data through a TAP file
- create and activate a TAP device
```bash
ip tuntap add dev tap89 mode tap
ip link set dev tap89 up
```
- open a new terminal and monitor `tap1`: `tcpdump -i tap89 -vv`
- in another terminal, compile and execute the `tap.c` program:
```bash
gcc -Wall tap.c -o tapw
sudo ./tapw
```
- we can see that the `tcpdump` monitors data sent from `tap89`

## Clean
ip tuntap del dev tap89 mode tap
