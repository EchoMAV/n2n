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
edge(ssid='TheConnection', psk='ThePassphrase', ip='172.20.5.20/24')
```

### turn VPN on (keep same parameters as previously configured)
```python
edge(enable=True)
```

### turn VPN off
```python
edge(enable=False)
```

## Command Line

```
usage: configure.py [-h] [--aes] [-a IP] [-c N] [-d DEV] [--enable] [-k N]
                    [-l IP:PORT]

Configure N2N

optional arguments:
  -h, --help            show this help message and exit
  --aes                 Use AES (default: False)
  -a IP, --address IP   IP address of edge node (default: None)
  -c N, --community N   Community name (default: None)
  -d DEV, --device DEV  TAP device (default: None)
  --enable              Enable EDGE (default: False)
  -k N, --key N         Encryption Key (default: None)
  -l IP:PORT, --supernode IP:PORT
                        Supernode address:port (default: 52.222.1.20:1200)
```

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
