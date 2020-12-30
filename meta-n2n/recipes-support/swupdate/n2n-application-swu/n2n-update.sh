#!/bin/bash

S=/tmp/data/
D=/tmp/otherPartition/
systemd_unitdir=/lib/systemd

if [ $# -lt 1 ]; then
	exit 0;
fi

function get_current_root_device
{
	for i in `cat /proc/cmdline`; do
		if [ ${i:0:5} = "root=" ]; then
			CURRENT_ROOT="${i:5}"
		fi
	done
}

function get_update_part
{
	CURRENT_PART="${CURRENT_ROOT: -1}"
	if [ $CURRENT_PART = "1" ]; then
		UPDATE_PART="2";
	else
		UPDATE_PART="1";
	fi
}

function get_update_device
{
	UPDATE_ROOT=${CURRENT_ROOT%?}${UPDATE_PART}
}

if [ $1 == "preinst" ] ; then
	# get the current root device
	get_current_root_device

	# get the device to be updated
	get_update_part
	get_update_device

	# create a symlink for the update process
	ln -sf $UPDATE_ROOT /dev/update

	mkdir -p ${S}
	mkdir -p ${D}
	exit 0
fi

if [ $1 == "postinst" ] ; then
	get_current_root_device

	mount -t ext4 /dev/update ${D}

	# if there isn't anythign in that partition then we 
	# don't want to think the update was successful
	if [ -z "$(ls -A ${D})" ]
		then
			exit 1
    fi
    mkdir -p ${D}root
    cp -rf ${S}n2n/ ${D}root/

    # FIXME :: not a fan of relying on python3.5 here, need to find a way around this
    cp -rf ${S}n2n/ ${D}usr/lib/python3.5/site-packages/
    cp -rf ${S}general/ ${D}usr/lib/python3.5/site-packages/
    cp -rf ${S}gpio/ ${D}usr/lib/python3.5/site-packages/

	# remove tarball from upload
	rm -f ${S}/n2n-application.tar.gz
	# put config files in the needed places, when read
    # we can put all config files in /config/ since it is the data partition
	mkdir -p ${D}/config/mavnet-confs/

    # copy rules
	
	# put service unit files in the needed places
	install -d ${D}${systemd_unitdir}
    # n2n services
    install -m 0644 ${S}/n2n/edge.service ${D}${systemd_system_unitdir}/

	#  enable services
	makdir -p ${D}/etc/systemd/system/multi-user.target.wants
    # n2n services
    ln -sf ${systemd_system_unitdir}/n2n.service \
        ${D}${sysconfdir}/systemd/system/multi-user.target.wants/n2n.service

	# ensure the FMU uart is in the right mode for mavlink I/O
	stty -F /dev/ttymxc3 cs8 -parenb -cstopb

	umount ${S}

	get_update_part

	fw_setenv mmcbootpart $UPDATE_PART
	fw_setenv mmcrootpart $UPDATE_PART
	exit 0
fi
