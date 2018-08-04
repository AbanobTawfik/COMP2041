#!/bin/sh

#if program arguements are NOT == 2 then print error message and exit
if test $# != 2; 
then
	echo "Usage: ./echon.sh <number of lines> <string>"
	exit 1
fi

#if the program argument 1 is an integer > 0 we want to echo
#if the program is not integer we will ignore the error message and print our own
if test "$1" -ge 0 2>/dev/null;
then
	#initalise counter for the loop to 0
	counter=0
	#while the counter < number in arguement 1
	while test $counter -lt $1 2>/dev/null; 
	do
		#output our string supplied
		echo $2
		#increment the counter
		counter=$((counter + 1))
	done
	#otherwise we print out an error message for invalid input in args[0] and exit
	else
		echo "./echon.sh: argument 1 must be a non-negative integer"
		exit 1
fi
exit 0
