#!/bin/sh

#we want to open the file passed in
cat "$1"|egrep "COMP[29]041"|cut -d'|' -f3 |cut -d',' -f2 |cut -d' ' -f2|sed "s/.* //g"|sort|uniq -c |sort -n|tail -1|sed "s/.* //g"
