#!/usr/bin/perl -w
use strict;
use warnings;
#creating main subroutine
sub main{
	#initalise counter for my words
	my $words = 0;
	#convert the keyword into lowercase (to have common case) 
	my $keyword = lc $ARGV[0];
	#read through all of standard input
	while(my $line = <STDIN>){
		#convert  the line into the same case as our keyword so case has no effect on the match for our keyword (only interested in character not case specific)
		$line = lc $line;
		#now we want to split the line into an array of words with the identifier of a word being a sequence of characters
		my @array = split/[^a-z]+/i, $line;
		#for each word in the array
		foreach my $word(@array){
			#if the word matches our keyword supplied, add 1 to the counter
			if("$word" eq "$keyword"){
				$words = $words + 1;;
			}
		}
	}
	#print the count + message
	print "$keyword occurred $words times\n";
}
#calling main subroutine
main();	
