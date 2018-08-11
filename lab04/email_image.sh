#!/bin/sh
# scan through each program arguements
for image in "$@"
do
	#display the image to the user
	display "$image"
	#have a prompt message for user toe enter email on same line so -n! so no new line char
	echo -n "Address to e-mail this image to? "
	#read email from stdin
	read email
	#if there is no input for email we dont wana send anything
	if test -z "$email"
	#echo error message + continue next 
	then
		echo "No e-mail address entered, try running again with a valid email"
		continue
	fi
	#ask user for a subject for their email
	echo -n "Enter a subject: "
	#read subject from stdin
	read subject
	#ask user to enter a accompanying message
	echo -n "Message to accompany image? "
	#read their message from stdin
	read content
	#now we echo our content as body of email, -s for subject -a is our attatchment send out to the email
	echo "$content"|mutt -s "$subject" -e 'set copy=no' -a "$image" -- "$email"
	#send user success message
	echo "$image sent to $email"
done
