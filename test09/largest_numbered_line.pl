#!/usr/bin/perl -w
use strict;
use warnings;
#creating main subroutine
sub main{
	#we want to create a hash, that stores lines with the keys being the largest integer on the line
	#appended
	my %hash;
	#set array to be result from stdin
	my @array_of_lines = <>;
	#we want an array that contains the result of values from the sorted hash
	my @max_lines;
	#for each line from standard input
	foreach my $line(@array_of_lines){
		#we want to create a temporary line
		my $linetmp = $line;
		#we want to first, remove everything except negative values, assigned to digit or decimal places
		$line =~ s/\-+/\-/g;
		$line =~ s/\.+/\./g;
		$line =~ s/(\d+)\-/$1/g;
		$line =~ s/[^[\-?\d \.?]//g;
		#we want to remove trailing and multple spaces, and condense multiple spaces into a single space
		$line =~ s/\s+/ /g;
		$line =~ s/^\s+//g;
		$line =~ s/\s+$//g;
		$line =~ s/ \.(\d+)/0\.$0/g;
		$line =~ s/^\.$//g;
		#we also want to trim the new line from the original line since we append the lines
		$linetmp =~ s/\n//;
		#now we want to store all digits on the line under array index's
		my @integers_in_array = split/ /,$line;
		#we sort the array now in descending order
		@integers_in_array = grep{$_ ne "\."} @integers_in_array;
		@integers_in_array = grep{$_ ne "\-"} @integers_in_array;
		@integers_in_array = grep{$_ ne "\-\-"} @integers_in_array;

		@integers_in_array = sort{$b <=> $a} @integers_in_array;
		#if there are values in the array we want to take first which will be the maximum
		if(@integers_in_array > 0){
			#we want to trim the .0 since 42 == 42.0 so we can store under same hash key
			$integers_in_array[0] =~ s/\.0$//;
			#if there is already a value in that hash key
			if(defined $hash{$integers_in_array[0]}){
				#append the new line to the current line
				$hash{$integers_in_array[0]} = "$hash{$integers_in_array[0]}\n$linetmp";
			}else{
				#otherwise we want to just store it in without a new line append
				$hash{$integers_in_array[0]} = "$linetmp";
			}
		}
	}
	#now we want to go through the hash pushing the values in the key to an array
	foreach my $key(sort{$b <=> $a} keys %hash){
		push @max_lines, $hash{$key};
	}
	#the lines with the largest numbers will be the first value in the array
	if(@max_lines > 0){
		print "$max_lines[0]\n";
	}
}
#calling main subroutine
main();	
