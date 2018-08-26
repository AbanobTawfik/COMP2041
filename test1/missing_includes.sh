#!/bin/sh
#scan through all c files passed in
for c_files in $@
do
	#extract all the header files in the c file
	cat $c_files|egrep '#include "'|
	#now we want to scan through each line 1 by 1
	while read -r line
	do
		#we want to extract just the .h file only
		filecheck=$(echo "$line"|sed 's/.* "//'|sed 's/"//')
		#line below to check file name properly
		#echo "$filecheck"

		#now we test if the file does not exist if not print error message
		if test ! -e "$filecheck"
		then
			echo "$filecheck included into $c_files does not exist"
		fi
	done	
done
