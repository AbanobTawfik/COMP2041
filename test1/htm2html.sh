#!/bin/sh
#scan through current directory
for file in *
do
	#iff the suffix is .htm
	if test "${file: -4}" = ".htm"
	then
		#create modified file with html suffix
		modified_file=""$file"l"
		#test if it is already exisiting
		if test -e "$modified_file"
		then
			#error message for duplicate files
			echo "$modified_file exists"
			#exit with error
			exit 1
		fi
		cp "$file" "$modified_file"
		#remove the original jpg after conversion
		rm "$file"
	fi
done

exit 0	
