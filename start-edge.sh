#!/bin/bash
SUDO=$(test ${EUID} -ne 0 && which sudo)

/usr/sbin/edge /etc/systemd/edge.conf
sleep 5
#to do, make sure that video service is active first

#possible to start edge video stream now, but this may consume cell bandwdith even when no one is listening
#if systemctl is-active --quiet video ; then
#  echo "Video service is running, starting edge video stream" 
#  gst-client pipeline_play edge
#else
#  echo "Video service is not running, so not starting edge stream"
#fi
