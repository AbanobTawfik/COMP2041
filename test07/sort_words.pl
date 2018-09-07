#!/usr/bin/perl -w
use strict;
use warnings;
#creating main subroutine
sub main{
	#read from stdin everything
	my @array_of_lines = <>;
	#print to standard output each line
	for my $line(@array_of_lines){
		#split the words based on white spaces
		my @words = split/\s+/, $line;
		#sort the split words
		my @sorted_words = sort{$a cmp $b} @words;
		#print sorted words
		print "@sorted_words";
		#since we seperated based on white spaces includes new line, print a new line
		print "\n";

	}
}
#calling main subroutine
main();
