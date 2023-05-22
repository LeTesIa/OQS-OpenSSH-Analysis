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
ALGORITHMS="regress/ssh-*

# @brief Sends a file with SCP using all OQS-OpenSSH available algorithms
# @param $1 The file to send
# @param $2 The root directory of oqs-openssh (the path of the directory where there is the subdir regress )
function sendFileThroughAllAlgorithms()
{
	echo "Sending $1 :"

	privateKeys=$(ls $2$ALGORITHMS | grep -v "\.")
	for privateKey in $privateKeys	
	do
		
		algorithm=$(echo $privateKey | cut -d'/' -f6)
		echo -ne " With $algorithm algorithm : ... "
		$(~/openssh/scp -F ~/openssh/regress/ssh_config -o KexAlgorithms=bike-l1-sha512 -o HostKeyAlgorithms=$algorithm -o PubkeyAcceptedKeyTypes=$algorithm -o PasswordAuthentication=no -i ~/openssh/regress/$algorithm $1 mif73291@193.219.91.103:~/)
		echo "Done"	
		sleep 2
	done
}


if [ $# -ne 2 ]
then
	echo "AutoSenderSCP"
	echo " Usage :"
	echo -e "\t$0 <filePath> <oqs-opensshPath>"
	echo -e " Example :"
	echo -e "\t$0 ~/smallFile.txt ~/openssh" 
	exit
fi

sendFileThroughAllAlgorithms $1 $2
