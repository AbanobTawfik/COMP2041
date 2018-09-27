#!/bin/sh

if test !$(perl -c legit.pl) == "legit.pl syntax OK\n"
then
	echo "autotest failed due to compilation errors"
	exit 1
fi 

rm -rf ".legit" &>/dev/null
touch a b 
touch output1.txt output2.txt
echo "test8 (another test on status)"
perl legit.pl init >>output1.txt
echo hello >a
echo world >b
perl legit.pl add a b >>output1.txt
perl legit.pl commit -m commit1 >>output1.txt
echo helloooo >>a
perl legit.pl add a >>output1.txt
perl legit.pl commit -m commit2 >>output1.txt
perl legit.pl add b >>output1.txt
perl legit.pl status >>output1.txt

rm a b
rm -rf ".legit" &>/dev/null

touch a b 
2041 legit init >>output2.txt
echo hello >a
echo world >b
2041 legit add a b >>output2.txt
2041 legit commit -m commit1 >>output2.txt
echo helloooo >>a
2041 legit add a >>output2.txt
2041 legit commit -m commit2 >>output2.txt
2041 legit add b >>output2.txt
2041 legit status >>output2.txt

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