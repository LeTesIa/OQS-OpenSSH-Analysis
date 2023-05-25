# OQS-OpenSSH-Analysis
Analysis of Open Quantum Safe project over OpenSSH. You will retrieve how to install and configure a server and a client with OQS-OpenSSH, and some scripts to collect data about SCP transactions.
## Setup
Puts `AutoReceiverSCP.bash` and `ScpHeapTracker.bash` on the server and `AutoSenderSCP.bash` on the client
## Get Started
1. Start the sshd server (check for sshd_config has the same port indicated inside the ssh_config's client)
2. Start `AutoReceiverSCP.bash`
3. Start `AutoSendSCP.bash`

## Commands
To start the server
```shell
~/openssh/sshd -D -f openssh/regress/sshd_config -o KexAlgorithms=bike-l1-sha512 &
```
