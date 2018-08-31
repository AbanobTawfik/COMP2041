#!/bin/sh

#get start range of our numbers
start=$1
#get end rage of our numbers
end=$2
#file name to store sequence
filename=$3
#run shell command seq 
seq $start $end >$filename
