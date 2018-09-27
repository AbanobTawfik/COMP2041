#!/usr/bin/perl -w
use strict;
use warnings;
#creating main subroutine
sub main{
	#we want to get our file from the program arguement
	my $file = $ARGV[0];
	#open the file under file handle
	open(my $rf, '<', "$file");
	#store file contents into array
	my @array_of_lines = <$rf>;
	close $rf;
	#if the file is empty, just print an empty new line
	if(@array_of_lines == 0){
		exit 0;
	}
	#if the file has a odd number of lines (remainder of 1 when divided by 2)
	if(@array_of_lines%2 == 1){
		#print the index of the integer division by 2
		my $int = int(@array_of_lines/2);
		print "$array_of_lines[$int]";
	}
	#if the file has a even number of lines (remainder of 0 when divided by 2)
	if(@array_of_lines%2 == 0){
		#now we want to print the index of integer division by 2
		my $int = int(@array_of_lines/2);
		$int--;
		print "$array_of_lines[$int]";
		#and the next value after that, by incremeneting index
		$int++;
		print "$array_of_lines[$int]";
	}
}
#calling main subroutine
main();	
