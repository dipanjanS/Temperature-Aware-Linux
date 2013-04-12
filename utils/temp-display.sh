#!/bin/bash

CPU_NUMS=0
CORE_NUMS=0
LOOP=0
SLEEP=0
CLEAR=0
TEMP_UNIT=$'\xc2\xb0'C

function usage {
	echo "Usage: coretemp-sensors [-t timeout] [-c]"
	echo -e "\t -t: loop mode with timeout seconds sleep"
	echo -e "\t -c: clear screen before reporting"
	exit 1
}

function clr {
	if [ ${CLEAR} -eq 1 ]; then
		clear
	fi
}

function init {
	CPU_NUMS=`cat /proc/cpuinfo | grep -i -c GenuineIntel`
	if [ ${CPU_NUMS} -lt 1 ]; then
		echo "No GenuineIntel vendor_id CPU found"
		exit 1
	fi

	CORE_NUMS=`cat /proc/cpuinfo | grep -i 'cpu cores' | sort -u | sed -e 's/[[:alpha:]:]//g'`

	CPUFAMILY=`cat /proc/cpuinfo | grep -i 'cpu family' | sort -u | sed -e 's/[[:alpha:]:]//g'`
	if [ ${CPUFAMILY} -lt 6 ]; then
		echo "CPU family >= 6 required"
		exit 1
	fi
}

function report_coretemp {
	
	cd /sys/devices/platform/coretemp.0
	echo -e "driver: `cat name`"

	CID=0
	corenum=0
	for CID in $(seq $CORE_NUMS); do
		let CID=$CID*2
		LABEL=`cat temp${CID}_label`
		INPUT=`cat temp${CID}_input`
		MAX=`cat temp${CID}_max`
		CRIT=`cat temp${CID}_crit`
		OTHERTEMP=`cat /sys/class/thermal/thermal_zone0/temp`
		
		let INPUT=INPUT/1000;
		let MAX=MAX/1000;
		let CRIT=CRIT/1000;
		let OTHERTEMP=OTHERTEMP/1000;
		
		
		let MAX_THRESHOLD13=$MAX-13*$MAX/100;
		let MAX_THRESHOLD7=$MAX-7*$MAX/100;

		# Display purposes only
		SPC="  "
		if [ ${INPUT} -gt 99 ]; then
			SPC=" "
		fi
		INPUT_STR="\t ${INPUT}${TEMP_UNIT}${SPC}"
		if [ ${INPUT} -gt ${MAX} ]; then
			INPUT_STR="\e[01;41m\t ${INPUT}${TEMP_UNIT}${SPC}\e[00m"
		elif [ ${INPUT} -gt ${MAX_THRESHOLD7} ]; then
			INPUT_STR="\e[01;45m\t ${INPUT}${TEMP_UNIT}${SPC}\e[00m"
		elif [ ${INPUT} -gt ${MAX_THRESHOLD13} ]; then
			INPUT_STR="\e[01;41m\t ${INPUT}${TEMP_UNIT}${SPC}\e[00m"
		fi
		MAX_STR=" ${MAX}${TEMP_UNIT} "
		CRIT_STR=" ${CRIT}${TEMP_UNIT}"
		echo -e "$LABEL: \e[01;41m ${INPUT}${TEMP_UNIT}${SPC}\e[00m (max =+$MAX_STR crit =+$CRIT_STR)"
		#echo "core $corenum :" $INPUT 
		corenum=`expr $corenum + 1`
		
	done
	
	echo -e "Avg : \t\e[01;41m ${OTHERTEMP}${TEMP_UNIT}${SPC}\e[00m (max =+$MAX_STR crit =+$CRIT_STR)\n"
}

init

while getopts t:ch option; do
	case "${option}"
	in
		t) let LOOP=1; let SLEEP=${OPTARG};;
		c) let CLEAR=1;;
		h) usage
		exit 1;;
	esac
done

if [ ${LOOP} -eq 0 ]; then
	report_coretemp
	exit 0
fi

while [ ${LOOP} -eq 1 ]; do
	#clear
	report_coretemp
	
	sleep $SLEEP
done
