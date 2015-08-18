# Simple script to read a list of files line by line and cat all content into one file

#!/bin/bash

if [ $# -ne 2 ]
  then
        echo "Correct syntax is:  "
        echo " ./docatall.sh [options] "
        echo "  source_filename "
        echo "  target_filename "
        exit;
fi

i=1;

while read line;do
        echo "Line # $i: $line"
        cat $line >> /tmp/$2
        ((i++))
done < $1
echo "Done"
