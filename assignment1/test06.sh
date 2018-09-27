#!/bin/sh

if test !$(perl -c legit.pl) == "legit.pl syntax OK\n"
then
	echo "autotest failed due to compilation errors"
	exit 1
fi 

rm -rf ".legit" &>/dev/null
touch output1.txt output2.txt
echo "test6 (branch and checkout with status)"
perl legit.pl init >>output1.txt
touch a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
echo hello >a
perl legit.pl add a b c d e f g h i j k l m n o p q r s t u v w x y z >>output1.txt
perl legit.pl commit -m commit-1 >>output1.txt
perl legit.pl branch b1 >>output1.txt
perl legit.pl checkout b1 >>output1.txt
echo world >>a
perl legit.pl 'rm' a &>> output1.txt
perl legit.pl 'rm' --cached a &>> output1.txt
perl legit.pl 'rm' --force b &>> output1.txt
echo "hello world" > a
perl legit.pl add a
perl legit.pl commit -a -m commit-2 >>output1.txt
perl legit.pl commit -a -m commit-3 &>>output1.txt
perl legit.pl status >>output1.txt
perl legit.pl log >>output1.txt

rm a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z &>/dev/null
rm -rf ".legit" &>/dev/null

2041 legit init >>output2.txt
touch a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
echo hello >a
2041 legit add a b c d e f g h i j k l m n o p q r s t u v w x y z >>output2.txt
2041 legit commit -m commit-1 >>output2.txt
2041 legit branch b1 >>output2.txt
2041 legit checkout b1 >>output2.txt
echo world >>a
2041 legit 'rm' a &>> output2.txt
2041 legit 'rm' --cached a &>> output2.txt
2041 legit 'rm' --force b &>> output2.txt
echo "hello world" > a
2041 legit add a
2041 legit commit -a -m commit-2 >>output2.txt
2041 legit commit -a -m commit-3 &>>output2.txt
2041 legit status >>output2.txt
2041 legit log >>output2.txt

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
rm a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z &>/dev/null
rm output1.txt
rm output2.txt