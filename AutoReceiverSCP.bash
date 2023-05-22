#!/bin/bash

############ Header ###################

# @author Robin Valtier
#
# @brief Works in pair with AutoSenderSCP. Waits for files sended by AutoSenderSCP 
# and stores heap status inside a file for each algorithms 
# and creates a sumup with min, max and avagere values for each.
# 
# @param $1 A prefix for files which will be created
# @param $2 sshd PID
# @param $3 Path of the OQS-OpenSSH directory
# @param $4 Absolute path of the SCPHeapTracker script

#######################################

# @brief Finds in a file the max and min value and computes the average
# @param $1 The name of the file, the file format is simple : 1 number by line
# @param $2 Name of the algorithm
# @return "algorithm\tmin\tmax\tavg"
function findMinMaxAvg() {
	avg=$((0))
	min=$((0))
	max=$((-1))
	numberOfValue=$((0))
	while IFS= read -r line
	do
		if [ $numberOfValue -eq 0 ] || [ $max -lt $line ]
		then
			max=$line
		fi

		if [ $numberOfValue -eq 0 ] || [ $min -gt $line ]
		then
			min=$line
		fi

		avg=$(($avg+$line))
		numberOfValue=$(($numberOfValue+1))
	done < "$1"
	avg=$(($avg/$numberOfValue))
	echo -e "$2\t$min\t$max\t$avg"
}

# @brief Receive a file through all scp algortihms
# @param $1 the name of the file
# @param $2 sshd PID
# @param $3 Path of the OQS-OpenSSH directory 
# @param $4 Absolute path of ScpHeapTracker script
# @return void
function receiveFileThroughAllAlgorithms()
{
	touch $1-sumup.txt
        echo "Receiving $1 :"

        privateKeys=$(ls $3regress/ssh-* | grep -v "\.")
        for privateKey in $privateKeys  
        do

                algorithm=$(echo $privateKey | cut -d'/' -f6)
                echo -ne " With $algorithm algorithm : ... "
                $($4 $2 > $1-$algorithm-heap-memory.txt)
                findMinMaxAvg $1-$algorithm-heap-memory.txt $algorithm >> $1-sumup.txt
		echo "Done"    
        done
}

############### MAIN ###############

if [ $# -ne 4 ] 
then
	echo "AutoReceiverSCP"
	echo -e " Usage :"
	echo -e "\t$0 <fileSuffix> <sshdPID> <oqsOpenSSHPath> <scpHeapTrackerAbsolutePath>"
	echo -e " Example :"
	echo -e "\t$0 firstAttempt 19089 ~/openssh/ /home/LeTesla/ScpHeapTracker.bash"
	exit
fi

receiveFileThroughAllAlgorithms $1 $2 $3 $4
