#!/usr/bin/perl -w
use strict;
use warnings;
#creating main subroutine
sub main{
	#if the number of arguements supplied is invalid print error message and exit
	if(@ARGV <= 0){
		print "usage: ./orca.pl \<ARGS\>";
		exit 1;
	}
	#otherwise scan through all of files supplied to program
	foreach my $file(@ARGV){
		#open the file for read 
		open(my $rf, '<', $file) or die "./orca.pl: can't open $file\n";
		#now want to store all the text in file into array
		my @array_of_lines = <$rf>;
		#initialise counter for the orca number
		my $orca_count = 0;
		#scan through the file line by line
		for(my $i = 0; $i < @array_of_lines; $i++){
			#remove leading date  (CAN HAVE MULTIPLE SPACES REEEEEEEEEEE)
			$array_of_lines[$i] =~ s/[0-9]+\/[0-9]+\/[0-9]+ +//;
			#remove leading spaces
			$array_of_lines[$i] =~ s/\s+$//;
			#if the line contains Orca
			if($array_of_lines[$i] =~ /^\d+ Orca/){
				#print "$array_of_lines[$i]\n"; debug
				#trim extra part before digits
				$array_of_lines[$i] =~ s/ .*//;
				#add to the counter
				$orca_count += $array_of_lines[$i];
			}
		}
		print "$orca_count Orcas reported in $file\n"
	}
}
#calling main subroutine
main();
