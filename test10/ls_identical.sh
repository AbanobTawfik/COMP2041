#!/bin/sh
#get directories from program arguements
directory1=$1
directory2=$2
#we only need to scan through 1 directory and compare each file in that directory to the entire other directory
for file in "$directory1"/*
do 
	#first we want to cut all path name from the file to get just file name
	file1name=$(echo "$file"|cut -d'/' -f2)
	#now we want to go through the other directory 
	for file2 in "$directory2"/*
	do
		#cut all the path name from the file to just get the file name
		file2name=$(echo "$file2"|cut -d'/' -f2)
		#if the two files are identically name
		if test "$file1name" = "$file2name"
		then
			#and if the files contain equal content
			if cmp -s "$file" "$file2"
			then
				#then print the file content and break from this loop
				echo "$file1name"
				break
			fi
		fi
		#otherwise we had different file names, so continue to next file in the second directory
		continue
	done   
done 
