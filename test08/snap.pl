#!/usr/bin/perl -w
use strict;
use warnings;
#creating main subroutine
sub main{
	#set the threshold for our snap to be program arguement 
	my $threshold = $ARGV[0];
	#create hash to count occurences
	my %hash;
	#create a variable holder for our snap 
	my $snap;
	#read stdin line by line
	while(<STDIN>){
		#increment the hash at key value of that line passed in
		$hash{$_} += 1;
		#if the value at the key is == threshold we want to
		if($hash{$_} == "$threshold"){
			#set the snapped line to be equal to the match
			$snap = $_;
			#break out of loop
			last;
		}
	}
	#print message
	print "Snap: $snap\n";
}
#calling main subroutine
main();
