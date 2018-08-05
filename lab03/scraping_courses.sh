#!/bin/sh
STRING_PREFIX_UNDERGRAD='http://www.handbook.unsw.edu.au/vbook2018/brCoursesByAtoZ.jsp?StudyLevel=Undergraduate&descr='
STRING_PREFIX_POSTGRAD='http://www.handbook.unsw.edu.au/vbook2018/brCoursesByAtoZ.jsp?StudyLevel=Postgraduate&descr='

#if no arguements supplied return error message + valid usage format
if test $# -lt 1
	then
		echo "Usage: ./scraping_courses.sh <course 1> <course 2> <course 3>"
fi
#began processing the course codes provided
for course in "$@"
do
	#now we want to extract the first letter to know which index in the handbook we are looking at for both versions of handbook
	letter=${course:0:1}
	#concatinate the first letter of the course code to the prefix for the handbook
	URL_UNDERGRAD="$STRING_PREFIX_UNDERGRAD$letter"
	URL_POSTGRAD="$STRING_PREFIX_POSTGRAD$letter"
	#now we want to extract and download that webpage using wget

	#retrieve the html file    
	#now we want to extract the lines with COURSE_CODE.html using egrep	
	#now we want to remove the text sorrounding our course code using set
	#using \\ around our course code allows us to perform our substitution

	#reference 
	wget $URL_UNDERGRAD $URL_POSTGRAD -q -O-|egrep "$1[0-9]{4}.html"|sed "s/.*\($1[0-9][0-9][0-9][0-9]\)\.html\">/\1 /"|sed "s/ [<][/][A][>][<][/][T][D][>]//"|sed "s/[<][/][A][>][<][/][T][D][>]//"|uniq|sort|uniq
done 
