# OQS-OpenSSH-Analysis
Analysis of Open Quantum Safe project over OpenSSH. You will retrieve how to install and configure a server and a client with OQS-OpenSSH, and some scripts to collect data about SCP transactions.
## Setup
Puts `AutoReceiverSCP.bash` and `ScpHeapTracker.bash` on the server and `AutoSenderSCP.bash` on the client
**Example of sshd_config file**
```
	StrictModes		no
	Port			4242
	AddressFamily		inet
	ListenAddress		10.10.10.10 # (Private IP for Cloud)
	#ListenAddress		::1
	PidFile			/home/<user>/openssh/regress/pidfile
	AuthorizedKeysFile	/home/<user>/openssh/regress/authorized_keys_%u
	HostkeyAlgorithms	*
	PubkeyAcceptedKeyTypes *
	LogLevel		DEBUG3
	AcceptEnv		_XXX_TEST_*
	AcceptEnv		_XXX_TEST
	Subsystem	sftp	/home/<user>/openssh/sftp-server
	ModuliFile '/home/<user>/openssh/moduli'
SecurityKeyProvider /home/<user>/openssh/regress/misc/sk-dummy/sk-dummy.so
HostKey /home/<user>/openssh/regress/host.ssh-ed25519
HostKey /home/<user>/openssh/regress/host.sk-ssh-ed25519@openssh.com
...
```
## Get Started
1. Start the sshd server (check for sshd_config has the same port indicated inside the ssh_config's client)
2. Start `AutoReceiverSCP.bash`
3. Start `AutoSendSCP.bash`

## Commands
To start the server
```shell
~/openssh/sshd -D -f openssh/regress/sshd_config -o KexAlgorithms=bike-l1-sha512 &
```
