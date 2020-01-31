# N2N Edge Node API
Desktop/Server Implementation of N2N VPN

## Dependencies

 * [ntop.org N2N](https://www.ntop.org/products/n2n/)

## Installation

To perform an initial install, establish an internet connection and clone the repository.
You will issue the following commands:
```
cd $HOME
git clone https://code.ornl.gov/uvdl/n2n.git
```

provide your UCAMS/XCAMS credentials, then continue:
```
make -C $HOME/n2n install
```

This will pull in the necessary dependencies including `n2n`, and configure it
as appropriate for your system.

## Usage:

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

## Files

 * `__init__.py` - support import
 * `Makefile` - installation automation
 * `README.md` - this file
 * `configure.py` - code to manage the n2n service

## Supported Platforms
These platforms are supported/tested:

 * Iris 2 R0/R1 based on:
   - [ ] [uvdl/yocto-ornl](https://github.com/uvdl/yocto-ornl/tree/develop)
   - [ ] [AWS/Ubuntu 18.04 LTS](https://code.ornl.gov/uvdl/general/tree/master/Devices/AWS)
