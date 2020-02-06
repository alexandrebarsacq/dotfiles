#!/bin/bash

warning_threshold=9
hibernate_threshold=4

acpi -b | awk -F'[,:%]' '{print $2, $3}' | {
	read -r status capacity
	if [ "$status" = Discharging -a "$capacity" -le $warning_threshold ]; then
		if [ "$capacity" -le $hibernate_threshold ]; then
			systemctl hibernate
		else
			timeout -k 50 40 i3-nagbar -m "DAttery charge is at ${capacity}%. Hibernating at ${hibernate_threshold} !" -t warning 
            pid=$!
		fi
	fi
}

exit
