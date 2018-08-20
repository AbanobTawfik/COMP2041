#!/usr/bin/perl -w
use strict;
use warnings;
#creating main subroutine
sub main{
	#if the number of arguements is not exactly 2 print usage message and exit
	if(@ARGV != 2){
		print "Usage: ./echon.pl <number of lines> <string>\n";
		exit;
	}
	#if the arguement is not an integer from 0-9 repeated only, print an error message and exit
	if($ARGV[0] !~ /^[0-9]*$/){
		print "./echon.pl: argument 1 must be a non-negative integer\n";
		exit;
	}
	#now we want to run the main echo functionality
	#for number of times specified
	for(my $i = 0; $i < $ARGV[0]; $i++){
		#print arguement 2 
		print "$ARGV[1]\n";
	}
}
#calling main subroutine
main();
