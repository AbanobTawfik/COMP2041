#!/usr/bin/perl -w
use strict;
use warnings;
#creating main subroutine
sub main{
	#create hash to check for duplicates
	my %hash;
	#scan through program arguements
	foreach my $word(@ARGV){
		$hash{$word} += 1;
		#if the word already exists in the hash skip dont print
		if($hash{$word} > 1){
			next;
		}
		#otherwise print the word
		print "$word ";
		#set the flag on for the word in hash 
	}
	#print new line at end
	print "\n";
}
#calling main subroutine
main();
