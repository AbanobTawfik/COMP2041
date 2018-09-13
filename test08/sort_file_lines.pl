#!/usr/bin/perl -w
use strict;
use warnings;
#creating main subroutine
sub main{
	#set file name to be gathered from program arguement
	my $file = $ARGV[0];
	#open the file for read mode
	open(my $rf, '<', $file);
	#creating hash this will be used to sort lines by word count
	my %hash;
	#create array to store file lines
	my @array_of_lines = <$rf>;
	#close file as no further use needed from file
	close "$rf";
	#scan through the file line by line
	foreach my $line(@array_of_lines){
		#create an array of character by splitting with no provided delimiter
		my @character_array = split//,$line;
		#for each character we want to increment the hash at that the line by 1
		foreach my $character(@character_array){
			$hash{$line} +=1;
		}
	}
	#now we want the sorted array of lines by first sorting by value, then a secondary sort of alphabetically (key values)
	my @sorted_lines = sort {$hash{$a} <=> $hash{$b} or $a cmp $b} keys %hash;
	#now for each line in the sorted array print the line
	foreach my $sorted_line(@sorted_lines){
		print "$sorted_line";
	}
}
#calling main subroutine
main();
