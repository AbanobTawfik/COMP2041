#!/bin/sh

if test !$(perl -c legit.pl) == "legit.pl syntax OK\n"
then
	echo "autotest failed due to compilation errors"
	exit 1
fi 

rm -rf ".legit" &>/dev/null
touch a b 
echo "test7 (errors in add, commit and unknown commands)"
perl legit.pl init >>output1.txt
perl legit.pl add c d e f &>>output1.txt
perl legit.pl commit commit-1 -m -a &>>output1.txt
perl legit.pl branch 11 -d &>>output1.txt
perl legit.pl commit -a -m 'perl' j &>>output1.txt

rm -rf ".legit" &>/dev/null

2041 legit init >>output2.txt
2041 legit add c d e f &>>output2.txt
2041 legit commit commit-1 -m -a &>>output2.txt
2041 legit branch 11 -d &>>output2.txt
2041 legit commit -a -m 'perl' j &>>output2.txt

rm -rf ".legit" &>/dev/null

if cmp -s "output1.txt" "output2.txt"
then
	echo "autotest passed congratulations!"
else
	echo "autotest failed, different output than expected see below"
	echo "==============> your output <============================"
	cat output1.txt
	echo "==============> expected output <========================"
	cat output2.txt
fi
rm a b
rm output1.txt
rm output2.txt