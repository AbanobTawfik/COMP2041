#!/bin/sh
# scan through directory
for file in *
do
	#if the file IS a jpg file we want to convert it so check last 3 chars for .jpg
	if test "${file: -4}" = ".jpg"
	then	
		#create a modified version which is a png version swap .jpg to .png
		modified_file=$(echo $file | sed "s/.jpg/.png/")
		#check if the file already exists now
		#as said in man -e FILE
		#					   FILE exists
		if test -e "$modified_file"
		then
			#error message for duplicate files
			echo "$modified_file already exists"
			#continue dont delete and convert it exists!
			continue
		fi
		#convert the file from jpg to png
		convert "$file" "$modified_file"
		#remove the original jpg after conversion
		rm "$file"
	fi
done
