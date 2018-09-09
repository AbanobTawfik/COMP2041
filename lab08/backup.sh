#!/bin/sh

#set file name equal to first arguement
filename=$1
#set counter as copy version of file initially to 0
count=0
#scan through to find out the first time that the extension count doesnt exist already
while test -e ".$1.$count"
do
	#increment counter
	count="$((count+1))"
done
#now we want to copy from our program arguement file into our backup file
cp "$1" ".$1.$count"
#echo the success message
echo "Backup of '$1' saved as '.$1.$count'"
