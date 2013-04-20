#!/bin/bash
#
#         ######################################################################################
#	  #########      TEMPERATURE AWARE LINUX ( temperature monitoring tool )      ##########
#         ######################################################################################
#
#	This program reads hardware temperature values corresponding to individual cores and also the system
#	aggregate temperature. All readings are taken dynamically and analyzed. If the temperature crosses a 
#	pre-set threshold, several thermal-aware techniques are used to control and maintain the system temperature		
#	below the threshold level. The main techniques include,
#					1. DFS
#					2. Core Hopping
#					3. Heat Balancing
#					4. Deferred Execution
#
#

#Set maximum desired temperature.
MAX_TEMP=60

# The frequency will increase when low temperature is reached.
let LOW_TEMP=$MAX_TEMP-5

CORES=$(nproc) # Get number of CPU cores.

# Temperatures internally are calculated to the thousandth.
MAX_TEMP=${MAX_TEMP}000
LOW_TEMP=${LOW_TEMP}000

# FREQ_LIST is a list (array) of all available cpu frequencies the system allows.
declare -a FREQ_LIST=($(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies))

# CURRENT_FREQ relates to the FREQ_LIST by keeping record of the currently set frequency.
let CURRENT_FREQ=1

# This find the hottest core and the coolest core of the system at any instance
function max_temp {
	get_temp
	TEMP_ARR=($TEMP1 $TEMP2)
	len=${#TEMP_ARR[*]};
	hottest=${TEMP_ARR[0]}
	coldest=${TEMP_ARR[0]}
	hotcore=0
	coldcore=0
	c=0
	
	for i in ${TEMP_ARR[@]}
	do
     		if [[ $i -gt $hottest ]]
     		then
        		hottest=$i
     			hotcore=$c
     		fi
		
		if [[ $i -lt $coldest ]]
     		then
        		coldest=$i
        		coldcore=$c
     		fi
     		c=`expr $c + 1`
	done
	
	if [[ $CORES -eq 4 ]]
     	then
     		if [[ $hotcore -eq 1 ]]
     		then 	
     			hotcore=3
     		fi
     		if [[ $coldest -eq 1 ]]
     		then 		
     			coldcore=3
     		fi
     	fi
}

# write the CPU frequency value to the system file to scale the CPU frequency up or down as required
function set_freq {
	echo ${FREQ_LIST[$1]}
	for((i=0;i<$CORES;i++)); do
		echo ${FREQ_LIST[$1]} > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_max_freq
	done
}

# scales the CPU frequency up one notch each time it is called
function throttle {
	if [ $CURRENT_FREQ -ne $((${#FREQ_LIST[@]}-1)) ]
	then
		let CURRENT_FREQ+=1
		set_freq $CURRENT_FREQ
	fi
}

# scales the CPU frequency down one notch each time it is called
function unthrottle {
	if [ $CURRENT_FREQ -ne 0 ]
	then
		let CURRENT_FREQ-=1
		set_freq $CURRENT_FREQ
	fi
}

# controls temperature by checking if hottest core temperature crosses threshold then it calls allocate_core
function control_process {
	max_temp
	if [ $hottest -ge $MAX_TEMP ]
	then
		allocate_core
	fi
}

# performs core hopping by allocating CPU intensive processes to the coolest core
function allocate_core {
	PROCESS=$(ps -eo pcpu,%mem,pid,comm | sort -nr | head -n 1 | awk '{print $3;}')
	
	if [[ $CORES -eq 2 ]]
     	then
     		CORE=($(taskset -c -p $PROCESS | awk '{print $6;}' | tr ',' ' '))
     	fi
     	
     	if [[ $CORES -eq 4 ]]
     	then
     		CORE=($(taskset -c -p $PROCESS | awk '{print $6;}' | tr '-' ' '))
     	fi
	
     	len=${#CORE[*]};
	CPU_AFF=$(ps -F ax | awk '{print $2,$7}' | grep $PROCESS | awk '{print $2}')
	
	max_temp
	
	for i in ${CORE[@]}
	do
		if [ $i -ne $coldcore ]
		then
			taskset -c -p $coldcore $PROCESS   
			break
		fi
	done
}

# implements heat balancing where processes are migrated from the hotter to cooler cores
function swap_cores {
	max_temp
	hot_temp=`expr $hottest - 0`
	
	if [ $hot_temp -ge $MAX_TEMP ]
	then
		
		if [ $CORES -eq 2 ]
		then
			PROCESS_LIST=($(ps -F -ef | awk '{print $2,$7}' | grep "$hotcore$" | awk '{print $1}' | head -n 25))
			
			for procid in ${PROCESS_LIST[@]}
			do
				taskset -c -p $coldcore $procid
			done

		elif [ $CORES -eq 4 ]
		then
			PROCESS_LIST1=($(ps -F -ef | awk '{print $2,$7}' | grep "$hotcore$" | awk '{print $1}' | head -n 15))

			for procid1 in ${PROCESS_LIST1[@]}
			do
				taskset -c -p $coldcore $procid1
			done

			if [ $hotcore -eq 0 ]
			then
				newhotcore=1
				newcoldcore=2
			
			elif [ $hotcore -eq 3 ] 
			then
				newhotcore=2
				newcoldcore=1
			fi

			PROCESS_LIST2=($(ps -F -ef | awk '{print $2,$7}' | grep "$newhotcore$" | awk '{print $1}' | head -n 15))

			for procid2 in ${PROCESS_LIST2[@]}
			do
				taskset -c -p $newcoldcore $procid2
			done
		fi
	fi
}

# implements deferred execution of CPU intensive processes which are responsible for rise in system temperature
function suspend_process {
	get_process_id
	SELECT_PROCESS=$(ps -eo pcpu,%mem,pid,comm | sort -nr | head -n 2 | awk '{print $3;}')
	max_temp
	
	temp=`expr $hottest - 4000`
	if [ $temp -ge $MAX_TEMP ]
	then
		for procid in ${SELECT_PROCESS[@]}
		do
			if [[ $procid -ne $pid ]]
			then
				kill -STOP $procid
				sleep 5
				kill -CONT $procid
				break
			fi
		done
	fi
}

# Get the system temperature values	
function get_temp {
	
	TEMP=$(cat /sys/class/thermal/thermal_zone0/temp)
	TEMP1=($(cat /sys/devices/platform/coretemp.0/temp2_input))
	TEMP2=($(cat /sys/devices/platform/coretemp.0/temp4_input))
	#TEMP=$(cat /sys/class/hwmon/hwmon0/temp1_input) 
	#TEMP=$(cat /sys/class/hwmon/hwmon1/device/temp1_input)
	TEMP=`expr $TEMP + 2000`
}

# Get the process id of this application
function get_process_id {
	pid=$$
}


# main method
while true; do
	get_temp
	if   [ $TEMP -ge $MAX_TEMP ]
	then # Throttle if too hot.
		throttle
	elif [ $TEMP -le $LOW_TEMP ]
	then
		unthrottle
	fi
	
	control_process
	suspend_process
	swap_cores
	sleep 3  #monitor every 3 seconds so that load caused is less.
	
done
