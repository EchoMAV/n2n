#!/usr/bin/env python
'''
Configure N2N
'''
import logging, os, subprocess

__version__ = '0.1'

logger = logging.getLogger(__name__)

# /etc/n2n/edge.conf
# Fill in template as needed and write configuration file
_ETC_N2N_EDGE_CONF_PATH = os.path.join(os.path.sep,'etc','n2n','edge.conf')
_ETC_N2N_EDGE_CONF = {
    'd':'edge0',
    'c':'',
    'k':'',
    'a':'',
    'l':'52.222.1.20:1200', # supernode (video.mavnet.online port 1200)
    'r':None,
}
_DEFAULT_SUPERNODE_PORT = 1200

def _syscall(cmd: str, ignore: bool = False):
    """Call OS with a diagnostic log."""
    logger.info(cmd)
    try:
        subprocess.check_call(cmd.split(' '), shell=False)
    except subprocess.CalledProcessError as e:
        logger.error(str(e))
        if not ignore:
            raise

def edge_active():
    """Determine if the VPN is up and running."""
    return os.system('systemctl status edge') == 0

def edge(enable: bool = False, cid: str = None, psk: str = None, ip: str = None, dev: str = 'edge0', **kwargs):
    """
    Become a WiFi access point with the credentials as given

    :option enable: A boolean indicating whether to enable or disable the VPN
    :option cid:    A string containing the community id to connect to
    :option psk:    A string containing the pre-shared key to use
    :option ip:     A string representing the IP address to assign to the edge node
    :option dev:    A string representing the TAP network device (NONE will inhibit routing)

    If the provided CID/PSK/IP are None (the default), then the edge node is stopped or started without changing
    the previous configuration.  In this way, one can 'provision' using a full set
    of parameters, then enable/disable using only the 'CID' parameter.

    Keyword arguments:

    :option aes:    A boolean indicating whether to use AES (True) or TwoFish (False, default)
    """
    if not enable:
        _syscall('systemctl stop edge')

    if cid is None or psk is None or ip is None:
        if enable:
            _syscall('systemctl start edge')
        return

    conf = _ETC_N2N_EDGE_CONF.copy()

    conf['c'] = cid
    conf['k'] = psk
    conf['a'] = ip
    if dev is not None:
        conf['d'] = dev
        conf['r'] = ''      # cause emission of '-r'
    else:
        conf['r'] = None    # inhibit emission of '-r'
    supernode = kwargs.get('supernode', None)
    if supernode is not None:
        conf['l'] = supernode
        if conf['l'].rfind(':') < 0:
            conf['l'] = '{}:{}'.format(supernode,_DEFAULT_SUPERNODE_PORT)
    aes = kwargs.get('aes', False)
    if aes:
        conf['A'] = ''      # cause emission of '-A'

    with open(_ETC_N2N_EDGE_CONF_PATH,'w') as f:
        for k in conf:
            if conf[k] is not None:
                f.write('-'+k+'='+conf[k]+'\n')
            else:
                f.write('-'+k+'\n')

    if enable:
        _syscall('systemctl restart edge')


# ---------------------------------------------------------------------------
# For command-line testing
# ---------------------------------------------------------------------------

def _auth(cid):
    """Get a pre-shared key as input from the user."""
    import getpass
    psk = getpass.getpass('Enter Passphrase for N2N\n{}: '.format(cid),None)
    return psk

if __name__ == "__main__":
    from argparse import ArgumentParser

    parser = ArgumentParser(description=__doc__)
    parser.add_argument(      '--aes', action='store_true', default=False, help='Use AES (default: %(default)s)')
    parser.add_argument('-a', '--address', metavar='IP', type=str, default=None, help='IP address of edge node (default: %(default)s)')
    parser.add_argument('-c', '--community', metavar='N', type=str, default=None, help='Community name (default: %(default)s)')
    parser.add_argument('-d', '--device', metavar='DEV', type=str, default=None, help='TAP device (default: %(default)s)')
    parser.add_argument(      '--enable', action='store_true', default=False, help='Enable EDGE (default: %(default)s)')
    parser.add_argument('-k', '--key', metavar='N', type=str, default=None, help='Encryption Key (default: %(default)s)')
    parser.add_argument('-l', '--supernode', metavar='IP:PORT', type=str, default='52.222.1.20:1200', help='Supernode address:port (default: %(default)s)')
    args = parser.parse_args()

    # make logging work for more than just WARNINGS+
    fmt = '%(asctime)s:%(levelname)s:%(name)s:%(funcName)s:%(message)s'
    logging.basicConfig(format=fmt,level=logging.INFO)

    d = {}
    d['aes'] = args.aes
    d['ip'] = args.address
    d['cid'] = args.community
    d['dev'] = args.device
    d['enable'] = args.enable
    d['psk'] = args.key
    d['supernode'] = args.supernode

    if d['psk'] is None:
        d['psk'] = _auth(d['cid'])

    edge(**d)

