#!/bin/sh

if test !$(perl -c legit.pl) == "legit.pl syntax OK\n"
then
	echo "autotest failed due to compilation errors"
	exit 1
fi 

rm -rf ".legit" &>/dev/null

echo "test0 (initilization)"
perl legit.pl init >>output1.txt
if test ! -e ".legit"
then
	echo "autotest failed, the .init file was not created"
	exit 1
fi
perl legit.pl init >>output1.txt
rm -rf ".legit" &>/dev/null
2041 legit init >> output2.txt
2041 legit init &>> output2.txt 
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

rm output1.txt
rm output2.txt