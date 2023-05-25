#!/bin/bash

################ HEADER ##################

# @author Robin Valtier
#
# @brief This script works in pair with the AutoReceiverSCP. The purpose is simple, this is just a way
# to automatize sending a file with SCP through different encryption algorithms to compare them efficiency.  
#
# @param $1 The path of the file to send
# @param $2 The path of the OQS-OpenSSH directory

###########################################

# CONSTANTS
ALGORITHMS="regress/ssh-*"

# @brief Sends a file with SCP using all OQS-OpenSSH available algorithms
# @param $1 The file to send
# @param $2 The root directory of oqs-openssh (the path of the directory where there is the subdir regress )
# @param $3 user
# @param $4 IP Address
function sendFileThroughAllAlgorithms()
{
	echo "Sending $1 :"

	privateKeys=$(ls $2$ALGORITHMS | grep -v "\.")
	for privateKey in $privateKeys	
	do
		
		algorithm=$(echo $privateKey | cut -d'/' -f6)
		echo -ne " With $algorithm algorithm : ... "
		$($2scp -F $2regress/ssh_config -o KexAlgorithms=bike-l1-sha512 -o HostKeyAlgorithms=$algorithm -o PubkeyAcceptedKeyTypes=$algorithm -o PasswordAuthentication=no -i ~/openssh/regress/$algorithm $1 $3@$4:~/)
		echo "Done"	
		sleep 2
	done
}


################## MAIN ##############

if [ $# -ne 4 ]
then
	echo "AutoSenderSCP"
	echo " Usage :"
	echo -e "\t$0 <filePath> <abspath-oqs-opensshPath> <user> <IP>"
	echo -e " Example :"
	echo -e "\t$0 ~/smallFile.txt ~/openssh/ mif1233 10.10.10.10"
	exit
fi

sendFileThroughAllAlgorithms $1 $2 $3 $4
