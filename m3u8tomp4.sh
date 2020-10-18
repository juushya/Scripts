#!/bin/bash

# quick script
# ffmpeg to convert m3u8 to mp4 + assign sequential filename - file0.mp4, file1.mp4 & so on
# put all m3u8 links captured through burp / proxy in a file - /tmp/2

count=0 #setting a counter for incremental output filename

for i in `cat /tmp/2`; 
do 
        ffmpeg -i $i -c copy -bsf:a aac_adtstoasc file-$count.mp4; 
        ((count++)); 
        sleep $[ ( $RANDOM % 10 )  + 1 ]s #add a random delay
done;
