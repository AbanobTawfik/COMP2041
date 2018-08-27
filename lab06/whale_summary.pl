#!/usr/bin/perl -w
#reference for sorting keys in perl hash
#https://perlmaven.com/how-to-sort-a-hash-in-perl
use strict;
use warnings;
#creating main subroutine
sub main{
	#if the number of arguements supplied is invalid print error message and exit
	if(@ARGV <= 0){
		print "usage: ./orca.pl \<ARGS\>";
		exit 1;
	}
	#create empty hash for both #individuals and #pods
	my %whale_list;
	my %pod_list;
	#otherwise scan through all of files supplied to program
	foreach my $file(@ARGV){
		#open the file for read 
		open(my $rf, '<', $file) or die "./orca.pl: can't open $file\n";
		#now want to store all the text in file into array
		my @array_of_lines = <$rf>;
		#scan through the file line by line
		for(my $i = 0; $i < @array_of_lines; $i++){
			#remove leading date  (CAN HAVE MULTIPLE SPACES REEEEEEEEEEE)
			$array_of_lines[$i] =~ s/[0-9]+\/[0-9]+\/[0-9]+ +//;
			#remove leading spaces
			$array_of_lines[$i] =~ s/\s+$//;
			#convert entire line to lower case
			$array_of_lines[$i] = lc $array_of_lines[$i];
			#turn all extra white spaces into just a single white space
			$array_of_lines[$i] =~ s/\s+/ /g;
			#convert from plularl to singular
			$array_of_lines[$i] =~ s/s$//;
			#if the line contains Orca
			if($array_of_lines[$i] =~ /^(\d+)\s+(.+)$/){
				#add the count of the individual whales in pod to the the whale list at correct key value
				$whale_list{$2} += $1;
				#add 1 to the pod count for the whale species
				$pod_list{$2}++;
			}
		}
	}
	#print in alphabetical order in hash table
	foreach my $species(sort keys %whale_list){
		print "$species observations: $pod_list{$species} pods, $whale_list{$species} individuals\n"
	}
}
#calling main subroutine
main();
