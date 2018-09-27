#!/usr/bin/perl -w
use strict;
use warnings;
#creating main subroutine
sub main{
	#if nothing was passed in, we want to print just a new line and exit
	if(@ARGV == 0){
		print "\n";
		exit 0;
	}
	#for each word passed in to the program arguements
	foreach my $word(@ARGV){
		#we want to lowercase to make sure vowels are consistent regardless of case
		my $wordtmp = lc $word;
		#if the word contains 3 consecutive vowels {3} = group of 3
		#we want to print the original word
		if($wordtmp =~ /[aeiou]{3}/){
			print "$word ";
		}
	}
	#print new line at end since we have no new line character passed in
	print "\n";
}
#calling main subroutine
main();	
