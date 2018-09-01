#!/usr/bin/perl -w
use strict;
use warnings;
#creating main subroutine
sub main{
	#initalise counter for my words
	my $words = 0;
	#read through all of standard input
	while(my $line = <STDIN>){
		#now we want to split the line into an array of words with the identifier of a word being a sequence of characters
		my @array = split/[^a-z]+/i, $line;
		#for each word in the array
		foreach my $word(@array){
			#if the word is an empty string
			if("$word" eq ""){
				#go to next word
				next;
			}
			#otherwise we add one to our word count
			else{
				$words = $words + 1;;
			}
		}
	}
	#print the count + words
	print "$words words\n";
}
#calling main subroutine
main();	
