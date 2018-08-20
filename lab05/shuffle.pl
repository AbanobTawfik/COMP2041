#!/usr/bin/perl -w
use strict;
use warnings;
#creating main subroutine
sub main{
	my $count = 0;
	#set my array of lines to be input from stdin
	my @array_of_lines = <>;
	#while there are still elements left in the array
	while(@array_of_lines > 0){
		#pick a random index
		my $random_index = rand(@array_of_lines);
		#print the array value at the random index
		print "$array_of_lines[$random_index]";
		#splice will remove that array item at that index so it will keep
		#removing till the array is empty
		splice @array_of_lines, $random_index,1;
	}
}
#calling main subroutine
main();
