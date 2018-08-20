#!/usr/bin/perl -w
use strict;
use warnings;
#creating main sub routine
sub main{
	#for each line in stdin
	foreach my $words (<STDIN>){
		#transliteralte [0-4]--> < and [6-9] --> >
		$words =~ tr /012346789/<<<<<>>>>/;
		#print the output
		print $words;
	}
}
#call main subroutine
main();
