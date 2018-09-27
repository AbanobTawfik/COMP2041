#!/bin/sh

if test !$(perl -c legit.pl) == "legit.pl syntax OK\n"
then
	echo "autotest failed due to compilation errors"
	exit 1
fi 

rm -rf ".legit" &>/dev/null
touch a 
echo "test8 (a test on show)"
perl legit.pl init >>output1.txt
echo hello >a
perl legit.pl add a >>output1.txt
perl legit.pl commit -m commit1 >>output1.txt
perl legit.pl show ':a' >>output1.txt
perl legit.pl show '0:a' >>output1.txt
perl legit.pl show '1:a' &>>output1.txt
echo worldworld >> a
perl legit.pl add a >>output1.txt
perl legit.pl commit -m commit2 >>output1.txt
perl legit.pl show ':a' >>output1.txt
perl legit.pl show '0:a' >>output1.txt
perl legit.pl show '1:a' >>output1.txt
perl legit.pl show '2:a' &>>output1.txt

rm a
rm -rf ".legit" &>/dev/null

touch a
2041 legit init >>output2.txt
echo hello >a
2041 legit add a >>output2.txt
2041 legit commit -m commit1 >>output2.txt
2041 legit show ':a' >>output2.txt
2041 legit show '0:a' >>output2.txt
2041 legit show '1:a' &>>output2.txt
echo worldworld >> a
2041 legit add a >>output2.txt
2041 legit commit -m commit2 >>output2.txt
2041 legit show ':a' >>output2.txt
2041 legit show '0:a' >>output2.txt
2041 legit show '1:a' >>output2.txt
2041 legit show '2:a' &>>output2.txt
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
rm a
rm output1.txt
rm output2.txt