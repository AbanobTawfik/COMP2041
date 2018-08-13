#!/bin/sh
#reference for finding substring for strings
#https://stackoverflow.com/questions/229551/how-to-check-if-a-string-contains-a-substring-in-bash
#setup arguements to variables
#reference for finding substring for shell this took forever to make word properly
#https://askubuntu.com/questions/299710/how-to-determine-if-a-string-is-a-substring-of-another-in-bash
#reference for removing all text between brackets using sed
#https://unix.stackexchange.com/questions/14838/sed-one-liner-to-delete-everything-between-a-pair-of-brackets
myFakeSong="$1"
substring="Triple J Hottest 100, [0-9][0-9][0-9][0-9]\|[0-9][0-9][0-9][0-9]"
albumPreReq="Triple J Hottest 100, "
#setup variable for path
TripleJ="Triple_J_Hottest_100"
#if incorrect arguements supplied print error message
if test "$#" -ne 2
then
	echo "usage: ./create_music.sh <.mp3 file> <directory>"
	exit
fi
#retrieve wikipedia page
wget -q -O- 'https://en.wikipedia.org/wiki/Triple_J_Hottest_100?action=raw'|
#now we want to find the "Hottest 100 top tens and summaries part of the web page
while read HTTPline
do
	#now we want to read the file line by line and look for
	#the line with |style="text-align:center; vertical-align:middle;"|'''[[Triple J Hottest 100, 2017|2017]]'''
	if test "${HTTPline/$substring}" != "$HTTPline"
	then
		year=$(echo $HTTPline|sed "s/.*[[]//"|cut -d"|" -f1|cut -d"," -f2|awk '{$1=$1};1'|tr -d ' '|sed "s/[^[A-Z]*[^ ]*]//"|sed "s/^[a-z]*//I"|sed "s/\.//")
		#test if the year is an empty string
		if test -n "$year"
		then
			#update the current year 
			songYear=$year
			#set album name for the id3 tags
			album="$albumPreReq$year"
			#create a directory for that year
			mkdir -p "$2"/"$album"/
			#start a counter for the top 10
			count=1
			while read song && test $count -lt 11
			do

			#extract title removing all extra characters and tags, and removing all white spaces + trailing spaces using awk
			
			#sed "s/[^[]*|//g" removes the extra information from the wikipedia page, removes all characters such as
				#oifedjejig| <-- characters followed by | character
			#tr -d '[]"#' removes the formatting characters
			#sed "s/– .*//" removes all characters after the en dash character
			#sed "s/.* – //" removes all characters before the en dash character
			#sed "s/([^()]*)//g" removes all extra information in the paranthesis
			#awk '{$1=$1};1' removes all leading and trailing wqhite spaces, it reconstructs the word without the spaces
			#sed "s/\//-/g" will remove all /'s with -'s to work with file names
			#taking left side of our line 			
			#replace all / with hyphens (-) to work with file names

			Artist=$(echo "$song"|sed "s/[^[]*|//g" |tr -d '[]"#'|sed "s/– .*//"|sed "s/\//-/g"|awk '{$1=$1};1')
			#taking right side of our line
			songName=$(echo "$song"|sed "s/[^[]*|//g" |tr -d '[]"#'|sed "s/.* – //"|sed "s/([^()]*)//g"|sed "s/\//-/g"|awk '{$1=$1};1')
			#in the case of an empty artist continue (happened)
			if test -z "$Artist"
			then
				continue
			fi
			#in the case of an empty song name continue (happened)
			if test -z "$songName"
			then
				continue
			fi
			#set track number to be the count
			trackNumber=$(($count)) 
			#create a file in same manner as they were in previous exercise
			file=""$2"/"$album"/"$trackNumber" - "$songName" - "$Artist".mp3"
			#copy our song file over the sample file in arguement 1
			cp "$1" "$file"
			#to update the id3 tag same as previous exercise uncomment the next line below! 
			#id3 -a "$Artist" -A "$album" -t "$songName" -T "$trackNumber" -y "$songYear" "$file" &> /dev/null
			#increment the counter
			count=$((count+1))			
			done
		fi
	fi

done
