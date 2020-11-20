#!/bin/bash
# This script maps drone i's telemetry USB names to USBtty_dronei

USB_mapping="10-usb-serial.rules"

cd /etc/udev/rules.d/

rm -f $USB_mapping
touch $USB_mapping

echo "SUBSYSTEM==\"tty\", ATTRS{idVendor}==\"0403\", ATTRS{idProduct}==\"6001\", ATTRS{serial}==\"AK05VSG3\",  SYMLINK+=\"ttyUSB_drone1\"  # This is the telemetry to Drone 1
SUBSYSTEM==\"tty\", ATTRS{idVendor}==\"0403\", ATTRS{idProduct}==\"6001\", ATTRS{serial}==\"AK05VS82\",  SYMLINK+=\"ttyUSB_drone2\"  # This is the telemetry to Drone 2
SUBSYSTEM==\"tty\", ATTRS{idVendor}==\"0403\", ATTRS{idProduct}==\"6001\", ATTRS{serial}==\"AQ004CCZ\",  SYMLINK+=\"ttyUSB_drone3\"  # This is the telemetry to Drone 3
SUBSYSTEM==\"tty\", ATTRS{idVendor}==\"0403\", ATTRS{idProduct}==\"6001\", ATTRS{serial}==\"AQ004IQ6\",  SYMLINK+=\"ttyUSB_drone4\"  # This is the telemetry to Drone 4
SUBSYSTEM==\"tty\", ATTRS{idVendor}==\"0403\", ATTRS{idProduct}==\"6001\", ATTRS{serial}==\"AQ003X1X\",  SYMLINK+=\"ttyUSB_drone5\"  # This is the telemetry to Drone 5
" >> $USB_mapping

gnome-terminal -e sudo udevadm trigger

echo Done!



