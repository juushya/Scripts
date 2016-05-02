#!/bin/bash

# Convert Metasploit cred output for ipmi hashes into Kvasir-acceptable format
# Import csv in Kvasir via mass import or per host using Metasploit credentials csv option
# creds -s ipmi -o ipmi-creds-raw-out.csv
# ./ipmi_msf2kvasir.sh ipmi-creds-raw-out.csv > ipmi-creds-out-kvasir.csv

file=$1
while read -r line
do
	echo $line | grep -q rakp
	if [ $? -eq 0 ]
	then
		a[0]=`echo $line | grep -v private_type | cut -d , -f 1`	#IP
		a[1]=`echo $line | grep -v private_type | cut -d , -f 3`	#port
		a[2]=`echo $line | grep -v private_type | cut -d , -f 5 | cut -d ' ' -f 2 | cut -d : -f 1`	#username
		a[3]=`echo $line | grep -v private_type | cut -d , -f 5 | cut -d ' ' -f 2 | cut -d : -f 2`	#hash
		a[4]='rakp_hmac_sha1_hash'	#hash type for ipmi

		echo "${a[0]},${a[1]},"'"'${a[2]}'"','"'${a[3]},'"'${a[4]}'"'

	else
		a[0]=`echo $line | grep -v private_type | cut -d , -f 1`	#IP
		a[1]=`echo $line | grep -v private_type | cut -d , -f 3`	#port
		a[2]=`echo $line | grep -v private_type | cut -d , -f 4`	#username
		a[3]=`echo $line | grep -v private_type | cut -d '"' -f 10`	#password
		a[4]='rakp_hmac_sha1_hash'	#hash type for ipmi

		echo "${a[0]},${a[1]},${a[2]},"'"'${a[3]}'"','"''"','"'${a[4]}'"'
	fi

done < $file
