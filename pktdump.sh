#!/bin/bash

# dump n2n packets

if [ x$1 = x ]
then	echo -e "usage:\t`basename $0` file-prefix [ interface [supernode]]"
	echo -e "\n\tfile-prefix is completed with a three-digit number"
	echo -e "\tinterface default is 'edge0'\n"
	echo -e "\tsupernode default is '52.222.1.20'\n"
	exit 9
fi

IF=${2:-edge0}
SN=${3:-52.222.1.20}
ID=`id -un`

##echo "acquiring packets on $IF for user $ID; press ^C when done"
echo "acquiring packets on $IF; press ^C when done"

set -x
mkdir -p $1
sudo /usr/sbin/tcpdump -i $IF -Z root -s 0 -C 100 -W 999 -w $1 dst $SN or src $SN
