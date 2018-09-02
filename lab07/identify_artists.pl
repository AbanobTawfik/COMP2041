#!/usr/bin/perl -w
use strict;
use warnings;
#reference to sorting my hash to get max value
#https://perlmaven.com/highest-hash-value
#creating main subroutine
sub main{
	############################################
	#         FIRST SECTION IS TO READ THROUGH #
	#         ALL LYRICS STORE DATA IN HASH    #
	############################################

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
			#lowercase the line so only interested in character not case sensitive
			$line = lc $line;	
			#split the array based on words
			my @array = split/[^a-z]+/i, $line;
			foreach my $word(@array){
				if("$word" eq ""){
					#go to next word
					next;
				}
				#add to the artist specific word count
				$artistKeyWordHash{$file}{$word}++;
				#add to the artist total word count	
				$artistWordHash{$file}++;
			}	
		}
		#close the file
		close $rf;
	}	
	#scan through program arguements
	foreach my $file(@ARGV){
		#create new hash each iteration for all log probabilities for artist + file
		my %logprobabilities;	
		#for each file we want to scan through it word by word, and add the log probabilities of each word
		#open the file 
		open(my $rf, '<', "$file") or die "./frequency.pl: can't open $file\n";
		#store file into array
		my @array_of_lines = <$rf>;
		#scan through array to get keyword count
		foreach my $line(@array_of_lines){
			#lowercase the line so only interested in character not case sensitive
			$line = lc $line;
			#split the array based on words
			my @array = split/[^a-z]+/i, $line;
			#scan through each word in the array and checking the log prabability of each word
			foreach my $word(@array){
				#if word empty string --> skip go to next
				if("$word" eq ""){
					#go to next word
					next;
				}
				#scan through the list of artists in our main hash
				foreach my $artist(keys %artistWordHash){
					#turn off warning for stupid uninitalised value error
					no warnings 'all';
					#numerator for the word = number of occurence for that word
					my $numerator = $artistKeyWordHash{$artist}{$word} + 1;
					#denominator = total number of words in the hash
					my $denominator = $artistWordHash{$artist};
					my $logvalue = $numerator/$denominator;
					#increment at the artists key the value 
					$logprobabilities{$artist}+=log($logvalue);
				}
				#re-enable warnings
				use warnings;
			}
		}
		#sorting artists by maximum order (see reference above in line 5), will sort the 
		#keys based on the logprobabilities value
		my @artistvalues = sort {$logprobabilities{$b} <=> $logprobabilities{$a} } keys %logprobabilities;
		#debugging purposes
#		foreach my $artist(@artistvalues){
#			print "andrew_rocks.txt: log_probability of $logprobabilities{$artist} for $artist\n";
#		}
		#print the mssg to stdout
		printf "%s most resembles the work of %s (log-probability=%.1f)\n", $file, $artistvalues[0], $logprobabilities{$artistvalues[0]};
		#close our file
		close $rf;
	}
	#now we want to to store our hash values into an array that is sorted by log probability
}
#calling main subroutine
main();
