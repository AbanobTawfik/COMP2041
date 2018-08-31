#!/usr/bin/perl -w
use strict;
use warnings;
#creating main subroutine
sub main{
	#start of the sequence
	my $start = $ARGV[0];
	#end of the sequence
	my $end = $ARGV[1];
	#filename for the sequence
	my $filename = $ARGV[2];
	#open file in append/read mode if it does not exist create it
	open(my $fh, "+>>", "$filename");
	#scan from start --> end +1
	while($start != ($end+1)){
		#print to the file the current sequence
		print $fh "$start\n";
		#increment the sequence by 1
		$start++;
	}
	#close the file
	close $fh;
}
#calling main subroutine
main();
