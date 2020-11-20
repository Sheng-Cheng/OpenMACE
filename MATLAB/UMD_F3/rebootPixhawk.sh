#!/bin/bash
# Reboot the pixhawk with the ID provided to this script.
# NOTE: This script requires USB mappings defined in /etc/udev/rules.d/10-usb-serial.rules
echo ==============================================================================
echo = To reboot vehicle, type \"reboot\" in the new terminal.                    
echo = To turn off the safety switch, type \"arm safetyoff\" in the new terminal. 
echo = For more information, inquire mavproxy\'s website.                         
echo ==============================================================================

for ((i=1; i<=$#; i++)); do
	# echo ${@:$i:1} # display the ith input argument
	gnome-terminal -e "mavproxy.py --master=/dev/ttyUSB_drone${@:$i:1}"
	sleep 1s
done


