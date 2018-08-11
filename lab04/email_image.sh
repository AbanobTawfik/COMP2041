#!/bin/sh

for image in "$@"
do
	display "$image"
	echo -n "Address to e-mail this image to? "
	read email
	if test -z "$email"
	then
		echo "No e-mail address entered, try running again with a valid email"
		continue
	fi
	echo -n "Enter a subject: "
	read subject
	echo -n "Message to accompany image? "
	read content
	echo "$content"|mutt -s "$subject" -e 'set copy=no' -a "$image" -- "$email"
	echo "$image sent to $email"
done
