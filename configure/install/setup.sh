#!/bin/bash

#
#         ######################################################################################
#	  #########      TEMPERATURE AWARE LINUX ( setup and installation tool )      ##########
#         ######################################################################################
#
#	This program consists of several initial operations and configurations which are necessary
#	for the smooth working of our temperature-aware application. Please run it as it is and in 
#	case of any problems refer to the installation and setup manual.
#
#


# uncomment the following line if the script fails
# sudo chmod 777 /bin/*

# the following command makes the application an executable
sudo chmod 777 temp-aware-daemon.sh

# the following command enables the application to be run as an executable directly as a command
sudo cp temp-aware-daemon.sh /bin


# uncomment the following line if you dont have gdm installed by default
# sudo apt-get --yes --force-yes install gdm

# !!! IMPORTANT !!!
# the following lines contain instructions about how to give root permissions to the script
# please install visudo incase you don't have it installed

# Step 1: Run the following command
# sudo visudo -f /etc/sudoers

# Step 2: Check your username and note it down using the following command
# whoami
# eg. My username is dip1812

# Step 3: The following lines show the contents of a typical sudoers file

#########################################################################################################
#													#
#													#
#													#
#	# This file MUST be edited with the 'visudo' command as root.					#
#	# 												#				
#	# Please consider adding local content in /etc/sudoers.d/ instead of 				#
#	# directly modifying this file. 								#
#	# 												#
#	# See the man page for details on how to write a sudoers file. 					#
#	# 												#
#													#
#	Defaults        env_reset 									#
#	Defaults        secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" 	#
#													#
#	# Host alias specification 									#
#													#
#	# User alias specification 									#
#													#
#	# Cmnd alias specification 									#
#													#
# 	# User privilege specification 									#
#	root    ALL=(ALL:ALL) ALL 									#
#													#
#	# Members of the admin group may gain root privileges 						#
#	%admin ALL=(ALL) ALL 										#
#	%dip1812 ALL=(ALL) ALL       <- insert this line here with your username 			#
#													#
#	# Allow members of group sudo to execute any command 						#
#	#%sudo   ALL=(ALL:ALL) ALL 									#
#													#
#	# See sudoers(5) for more information on "#include" directives: 				#
#													#
#	#includedir /etc/sudoers.d 									#
#													#
#	dip1812 ALL=(ALL) NOPASSWD: ALL     <- insert this line here with your username			#
#													#
#													#
#													#
#													#
#########################################################################################################

													
# The following commands will enable the script to be run at boot time					


sudo chmod 777 /etc/gdm/PostSession/Default								

echo "temp-aware-daemon.sh &" >> /etc/gdm/PostSession/Default	

# if everything goes as planned it should start every time you start your system. In case of failure, please
# refer to the installation manual
