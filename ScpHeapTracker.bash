#!/bin/bash

############# HEADER ###################

# @author Robin Valtier
# 
# @brief Displays the number of kilobytes in the heap memory of a scp transaction
# ATTENTION : This only works on sshd deamon which has no other transaction (ssh or scp)
# 
# @param $1 sshd PID

########################################

# CONSTANTS
ERROR="-1"
SCP_TRANSACTION_DEPTH="3"
REFRESH="0.1"
SCP_CMD="scp -t"
PS_NO_PROCESSUS="PID"

# @brief Tests if the processus with the PID given executes the command expected
# @param $1 The PID
# @param $2 The command, you can just give the begining of the command.
# @return boolean
isTheProcessusGettingTheCommandExpected() {
	cmd=$(ps --pid $1 -o cmd | tail -n 1)
	[[ "$cmd" == "$2"* ]]
}

# @brief Look for the PID of the child at the given depth
# Only works for processes which create only one child :
# root PID
# \____First Child (depth 1)
#	\____Second Child (depth 2)
#	     \_____ .... (depth N)
# @param $1 : root PID
# @param $2 : depth
# @param $3 : the command executed by the processus
# @return : The PID at the given depth, 
# or the last PID found if there are less children than the depth. 
# Returns -1 if the number of arguments is not correct
function searchForChildAtDepth() 
{
	if [ $# -ne 3 ]
	then 
		echo "$#"
		return
	fi

	desiredDepth=$(($2))
	currentPID=$1
	currentDepth=$((0))

	while [ $currentDepth -lt $desiredDepth ]
	do
		gatheredPID=$(ps --ppid $currentPID -o pid | tail -n 1)

		if [[ "$gatheredPID" == *"$PS_NO_PROCESSUS"* ]]
		then 
			currentDepth=0
			currentPID=$1
		else
			currentDepth=$(($currentDepth+1))
			currentPID=$gatheredPID
		fi
		
		if [ $currentDepth -ne $desiredDepth ]
		then
			continue
		fi
		
		if ! isTheProcessusGettingTheCommandExpected $currentPID $3
		then
			currentDepth=0
			currentPID=$1
		fi
	done

	echo $currentPID
}

# @brief Retrieve or will wait for a scp transaction from a sshd PID
# @param $1 : The PID of the sshd deamon
# @return : The pid of ssh transaction
function searchForSCPTransactionPID()
{
	if [ $# -ne 1 ]
	then
		echo "$ERROR"
		return
	fi

	sshdPID=$1
	echo $(searchForChildAtDepth $sshdPID $SCP_TRANSACTION_DEPTH "$SCP_CMD")
}

# @brief Monitors memory of process, stop when the process is destroyed .
# @param $1 pid of the process
# @return void
function startMonitoring() {
	heapSize="first"

	while [ -n "$heapSize" ]
	do
		if [ $heapSize != "first" ]
		then
			echo $heapSize
		fi
	        heapSize=$(pmap -X $1 | grep heap | awk '{print $6}')      
	done
}

############### MAIN ##############

if [ $# -ne 1 ]
then
	echo "ScpHeapTracker"
	echo -e " Usage :"
	echo -e "\t$0 <sshdPID>"
	echo -e " Examples :"
	echo -e "\t$0 12567"
	echo -e "\t$0 12387 0.1"
	exit
fi

transactionPID=$(searchForSCPTransactionPID $1)
startMonitoring $transactionPID

