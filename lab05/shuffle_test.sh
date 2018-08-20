#!/bin/sh
#initialise a counter to see how many tests passed
tests_passed=0
#will attempt to compile the perl program and will print out any error messages if there are any
if test !$(perl -c shuffle.pl) == "shuffle.pl syntax OK\n"
then
	#exit on compilation error
	echo "autotest failed due to compilation errors"
	exit 1
fi 
#now we want to run the program with piped in seq to test different cases 
echo "Test 1, Singular digit"
echo "----------------------"
#sleep for 1s to allow user to read outputs
sleep 1
#sequence the number 1 into test1 file
seq 1 > test1.txt
#run our perl program and output the output to output1 file
perl shuffle.pl <test1.txt > output1.txt
#want to store the difference of the test and output (should be the same) into a variable
difference=$(diff output1.txt test1.txt)
#if the difference is none that means test is successful
if test -z "$difference"
then
	#output success message 
	tests_passed="$((tests_passed+1))"
	echo "test 1, passed!"
	echo "---------------"
else
	#otherwise we want to output test failed and display the difference
	#cat will output all file contents 
	echo "test failed, see below for difference"
	echo "your output"
	cat output1.txt
	echo "expected output"
	cat test1.txt
	echo "---------------"
fi
#sleep for 0.5s so user can read
sleep 0.5
#making a harder more comprehensive test
echo "Test 2, a more comprehensive approach."
echo "your program will be run 100 times on the same file with 1000 lines, each run will add a file to the pool."
echo "everytime a file is added it will be compared to all existing files byte by byte."
echo "-------------------------------------"
#sleep for 5s so user can understand how the test works
sleep 5
#now we want to simply make sure each time it is run with 1000 lines that it will produce a unique result that hasn't been seen
#to do this we will run the program 100 times and make sure that each run is unique (not small small small chance that repeat input)
#however with 1000 lines it is extremely unlikely

#output our file with 1000 lines to test1.txt
seq 1000 > test1.txt
#initialise all our variables
number_of_tests=100
count=0
number_of_hits=0
flag=0
number_of_misses=0
#while loop to perform 100 iterations
while test "$count" -lt "$number_of_tests"
do
	#display to user which test count we are at
	echo "file number $count being added to the file pool"
	#run the shuffle on the 1000 elements
	perl shuffle.pl <test1.txt >output$count.txt
	#now we want to compare our output to ALL exisiting output
	for output in output[0-9]*.txt
	do
		#store in variable res the difference between the two files
		res=$(cmp -s "output$count.txt" "$output")
		#if the variable is an empty string we continue
		if test -z "$res"
		then
			continue
		#otherwise we want to trigger flag that we found a duplicate match
		else
			flag=1
		fi
	done
	#if our flag value is = that means we have no duplicates yet, so we can add 1 to our unique counter (number of hits)
	if test "$flag" -eq 0
	then
		number_of_hits="$((number_of_hits+1))"
	#otherwise we found a duplicate add 1 to our number of misses counter
	else
		number_of_misses="$((number_of_misses+1))"
	fi
	#reset flag on each iteration otherwise it will stay at 1
	flag=0
	#increment our loop counter
	count="$((count+1))"
	#sleep 0.1ms so user can have a more paced out testing
	sleep 0.1
done
#removes all the temporary files created
rm -r test[0-9]*.txt output[0-9]*.txt;
#if the number of misses is equal to 0 that means all unique outputs
if test "$number_of_misses" -eq 0
then
	#add 1 to our number of autotests passed
	tests_passed="$((tests_passed+1))"
fi
#output the statistics from the autotesting to user
echo "=====> $tests_passed tests passed out of 2 tests <====="
echo "statistics from comprehensive run"
echo "number of unique outputs - $number_of_hits"
echo "number of duplicate files - $number_of_misses"
echo "out of the 100 random files you had produced $number_of_hits random results congratulations!"
