#!/usr/bin/perl -w
use strict;
use warnings;
#creating main subroutine
sub main{
	#if the number of arguements supplied is invalid print error message and exit
	if(@ARGV != 2){
		print "usage: ./orca.pl \<Species\> \<File\>";
		exit 1;
	}
	#open the file for read 
	open(my $rf, '<', $ARGV[1]) or die "./orca.pl: can't open $ARGV[1]\n";
	#now want to store all the text in file into array
	my @array_of_lines = <$rf>;
	#initialise counter for the species number
	my $species_count = 0;
	#counter for number of pods
	my $pod_count = 0;
	#scan through the file line by line
	for(my $i = 0; $i < @array_of_lines; $i++){
		#remove leading date  (CAN HAVE MULTIPLE SPACES REEEEEEEEEEE)
		$array_of_lines[$i] =~ s/[0-9]+\/[0-9]+\/[0-9]+ +//;
		#remove leading spaces
		$array_of_lines[$i] =~ s/\s+$//;
		#if the line contains species
		if($array_of_lines[$i] =~ /^\d+ $ARGV[0]/){
			#print "$array_of_lines[$i]\n"; debug
			#trim extra part before digits
			$array_of_lines[$i] =~ s/ .*//;
			#add to the counter
			$species_count += $array_of_lines[$i];
			#increment pod counter
			$pod_count++;
		}
	}
	#print the final message
	print "$ARGV[0] observations: $pod_count pods, $species_count individuals\n";
}
#calling main subroutine
main();
