#!/bin/sh
#scan through the directories passed through
#reference i used for hiding output from the pesky ida output
#https://serverfault.com/questions/41964/how-to-hide-the-output-of-a-shell-application-in-linux
#reference I used for triming leading and trailing white spaces
#https://unix.stackexchange.com/questions/102008/how-do-i-trim-leading-and-trailing-whitespace-from-each-line-of-some-output
for directory in "$@"
do
	#extract Album real quick 
	Album=$(echo "$directory"|cut -d'/' -f2|awk '{$1=$1};1')
	#extract year of song real quick CUT WHITE SPACE COS IT WAS MESSING UP WITH THE YEAR
	Year=$(echo "$directory"|cut -d'/' -f2|cut -d',' -f2|awk '{$1=$1};1')
	#now we want to scan through entire directory
	for song in "$directory"/*
	do
		#IF IT IS AN MP3 FILE we want to extract title + artist
		#and then change the data
		if test "${song: -4}" = ".mp3"
		then
			#extract Track number from file name removing everything before backslash (cut wont work because of multiple backslashes haHAA)
			Track=$(echo "$song"|sed "s/ - .*//"|sed "s/.*[/]//"|awk '{$1=$1};1')
			#extract title from file name
			Title=$(echo "$song"|cut -d'-' -f 2-<<<"$song"|sed "s/ - .*.mp3//"|awk '{$1=$1};1')
			#extract artist from file name and remove assosciated .mp3
			Artist=$(echo "$song"|sed "s/$Title - //"|sed "s/.mp3//"|sed "s/.* - //"|awk '{$1=$1};1')
			#now we want to use id3 to convert tags
			#from manual
			#-t sets title to first 28 characters input
			#-T sets the Track to number input
			#-a sets the artist for the first 28 characters input
			#-A sets the Album for the first 28 characters input
			#-y sets the year tag to the first 4 characters input
			#using id3 to change tags in song file now
			id3 -a "$Artist" -A "$Album" -t "$Title" -T "$Track" -y "$Year" "$song" &> /dev/null
		fi
	done
done
