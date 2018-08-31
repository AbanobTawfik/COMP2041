#!/usr/bin/perl -w
use strict;
use warnings;
#creating main subroutine
sub main{
	#index of the file we trying to find n line
	my $index = $ARGV[0];
	#file name arguemnt 2
	my $filename = $ARGV[1];
	#open file in read mode
	open(my $fh, "<", "$filename");
	#counter for nth line
	my $seq = 0;
	#the flag for if found to break from loop
	my $found = 0;
	#scan through entire file
	while(my $line = <$fh>){
		#if the line has been found break from loop
		if($found == 1){
			last;
		}
		#if the current count is == n we want to print, and set the flag for found
		if($seq == ($index-1)){
			print $line;
			$found = 1;
		}
		#increment the counter by 1
		$seq++;
	}
	#close the file
	close $fh;
}
#calling main subroutine
main();
