#!/usr/bin/perl -w
use strict;
use warnings;
#creating main subroutine
sub main{
	#if there are no arguements passed, print nothing (similair to last test)
	if(@ARGV == 0){
		print "\n";
	}
	#create an array for storing the data
	my @data;
	#push program arguements into the array
	foreach my $word(@ARGV){
		push @data, $word;
	}
	#now we want to sort the array (order is irrelevant since we pick middle, but i chose ascending)
	@data = sort{$a <=> $b} @data;
	#to get the middle index its the (arraysize-1)/2 
	my $index = (@data-1) / 2;
	#print the middle index of the array
	print "$data[$index]\n";
}
#calling main subroutine
main();	
