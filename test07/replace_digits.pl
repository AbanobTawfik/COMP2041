#!/usr/bin/perl -w
use strict;
use warnings;
#creating main subroutine
sub main{
	#open the file to read
	open(my $rf, '<', "$ARGV[0]") or die "./replace_digits.pl: can't open $ARGV[0]\n";
	#now creating array to store modified lines
	my @array_of_lines;
	#for all lines in the file
	foreach my $line(<$rf>){
		#replace all digits with the # on the line
		$line =~ s/[0-9]/#/g;
		#add to the array the modified line
		push @array_of_lines, $line;
	}
	#close the file when finished
	close "$rf";
	#open the file for write (will wipe file on open)
	open($rf, '>', "$ARGV[0]") or die "./replace_digits.pl: can't open $ARGV[0]\n";
	#for all lines in the array of modified lines
	foreach my $line(@array_of_lines){
		#print to the file the modified line to rewrite the modified file
		print $rf "$line";
	}
	#close the file 
	close "$rf";

}
#calling main subroutine
main();
