# N2N Edge Node API
Implementation of N2N VPN

## Dependencies

 * [ntop.org N2N](https://www.ntop.org/products/n2n/)

## Installation

To perform an initial install, establish an internet connection and clone the repository.
You will issue the following commands:
```
cd $HOME
git clone https://github.com/horiz31/n2n.git
```

provide your credentials, then continue:
```
make -C $HOME/n2n install
```

This will pull in the necessary dependencies, build `n2n` and configure it
as appropriate for your system.  Then, proceed to configure:
```
make -C $HOME/n2n provision
```

This will enter into an interactive session to help you setup your VPN.

## To run on windows
1. Install TAP from: http://build.openvpn.net/downloads/releases/tap-windows-9.24.2-I601-Win10.exe
2. Download compiled edge for windows [N2N_Windows_Edge_2.8.0.zip](https://github.com/horiz31/n2n/files/6784606/N2N_Windows_Edge_2.8.0.zip)  
3. edit edge.conf  
4. run edge.exe from command prompt AS ADMINISTRATOR  
note: you may need to edit the interface name to "edge0" or edit the -d parameter in edge.conf to match the interface name  

current functional edge.conf  
```
-d=edge0
-c=h31network
-k=horizon31
# supernode IP address
-l=video.horizon31.com:7777
-r
# edge IP address
-a=172.21.X.Y  <edit as needed,convention is to make the last two octets match the system's eth0 address>
# netmask
-s=255.255.0.0
-E
-A1
```

## Python Usage:

```python
from n2n import edge, edge_active
```

### connect to an existing network thru the default supernode (`video.mavnet.online`)
```python
edge(ssid='TheConnection', psk='ThePassphrase', ip='172.20.5.20/24', start=True)
```

### turn VPN on (keep same parameters as previously configured)
```python
edge(start=True)
```

### turn VPN off
```python
edge(start=False)
```

## Command Line

```
usage: configure.py [-h] [-A] [-a IP] [-c N] [-d DEV] [--enable] [--interactive] [--mavnet PATH] [-E] [-k N] [-l IP:PORT]
                    [--start] [--version]

Configure N2N

optional arguments:
  -h, --help            show this help message and exit
  -A, --aes             Use AES (default: False)
  -a IP, --address IP   IP address of edge node (default: None)
  -c N, --community N   Community name (default: None)
  -d DEV, --device DEV  TUN device (default: None)
  --enable              Enable EDGE service at boot (default: False)
  --interactive         Interactive provisioning/verification (default: False)
  --mavnet PATH         Use MAVNet configuration file to provision (default: None)
  -E, --multicast       Accept Multicast (default: False)
  -k N, --key N         Encryption Key (default: None)
  -l IP:PORT, --supernode IP:PORT
                        Supernode address:port (default: 52.222.1.20:1200)
  --start               Start EDGE service (default: False)
  --version             show program's version number and exit
```

### connect to an existing network thru the default supernode (`video.mavnet.online`)
```
sudo ./configure.py --address=172.20.5.20/24 --key="ThePassphrase" -c "TheConnection" --enable --start
```

This will configure the system to connect to the VPN with the given address and 255.255.255.0 netmask.
The service will be started and it will be setup to start on boot.

### Use a MAVNet provisioning file to configure EDGE
```
./configure.py --mavnet ~/scripts/Sim9/FSIM000000000009.mav --interactive
```

Will produce (as an example):
```
Verify Configuration:
{
  "start": false,
  "aes": false,
  "dev": "edge0",
  "ip": "172.20.5.9",
  "cid": "sim",
  "enable": false,
  "supernode": "52.222.1.20:1200",
  "multicast": true,
  "psk": "xxxxxxxx"
}
OK? (Yes):
```

Press `ENTER` to accept the configuration and create the `/etc/systemd/edge.conf` file.

*Observe that `enable` and `start` are `false` which means the EDGE service will not
be enabled to start on boot.  This is from the config file indicating that the `LOS`
device is disabled.  You can start the service manually or give the `--enable`/`--start` options.*
```
sudo systemctl enable edge
sudo systemctl start edge
```

## Files

 * `__init__.py` - support import
 * `Makefile` - installation automation
 * `README.md` - this file
 * `configure.py` - code to manage the n2n service

## Supported Platforms
These platforms are supported/tested:

 * Iris 2 R0/R1 based on:
   - [x] [uvdl/debian-var](https://github.com/uvdl/debian-var/tree/iris2)
   - [ ] [uvdl/yocto-ornl](https://github.com/uvdl/yocto-ornl/tree/develop)
 * Linux Workstations
   - [ ] [AWS/Ubuntu 18.04 LTS](https://code.ornl.gov/uvdl/general/tree/master/Devices/AWS)
 * Jetson Nano
   - [x] [JetPack 4.5.1]
 * Raspberry PI
   - [x] [Raspbian GNU/Linux 10 (buster)](https://www.raspberrypi.org/downloads/raspbian/)
