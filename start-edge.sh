#!/bin/bash
SUDO=$(test ${EUID} -ne 0 && which sudo)

/usr/sbin/edge /etc/systemd/edge.conf


