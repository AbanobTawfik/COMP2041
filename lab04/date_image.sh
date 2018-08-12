#!/bin/sh
# scan through each program arguements
for image in "$@"
do
	#extract dates from ls using cut based on space its field 6-8 
	dateOfExtraction=$(ls -l "$image"|cut -d' ' -f6-8)
	#now we convert the modified file with itself 
	convert -gravity south -pointsize 36 -draw "text 0,10 '$dateOfExtraction'" "$image" "$image"
done
