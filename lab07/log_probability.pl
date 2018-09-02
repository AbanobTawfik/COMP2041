#!/usr/bin/perl -w
use strict;
use warnings;
#creating main subroutine
sub main{
	#initalise counter for my keyword counter
	my $keyword_count = 0;
	#initialise counter for my word counter
	my $word_count = 0;
	#convert the keyword into lowercase (to have common case) 
	my $keyword = lc $ARGV[0];
	#create hash for artist and the word usage
	my %artistKeyWordHash;
	my %artistWordHash;
	#scan through list of files as specified in hint
	foreach my $file(glob "lyrics/*.txt"){
		#open the file 
		open(my $rf, '<', "$file") or die "./frequency.pl: can't open $file\n";
		#store file into array
		my @array_of_lines = <$rf>;
		#remove lyrics/ from the file name
		$file =~ s/lyrics\///;
		#remove the .txt file extension
		$file =~ s/\.txt//;
		#replace the underscores with spaces
		$file =~ s/_/ /g;
		#scan through array to get keyword count
		foreach my $line(@array_of_lines){
			#lowercase entire line to match the case of our keyword so it is a character match
			$line = lc $line;
			#split the array based on words
			my @array = split/[^a-z]+/i, $line;
			foreach my $word(@array){
				#if the word matches our keyword supplied, add 1 to the counter
				if("$word" eq "$keyword"){
					$artistKeyWordHash{$file}++;
				}
				if("$word" eq ""){
					#go to next word
					next;
				}
				#otherwise we add one to our word count
				else{
					$artistWordHash{$file}++;
				}
			}	
		}
	}
	foreach my $artist(sort keys %artistWordHash){
		#avoid stupid uninitalised value error
		no warnings 'all';
		#addidtive smoothing
		my $keywordmatch = $artistKeyWordHash{$artist} + 1;
		my $wordcount = $artistWordHash{$artist};
		my $frequency = log($keywordmatch/$wordcount);
		printf "log((%d + 1)/%6d) = %8.4f %s\n",$keywordmatch - 1,$wordcount,$frequency,$artist;
	}
}
#calling main subroutine
main();	
