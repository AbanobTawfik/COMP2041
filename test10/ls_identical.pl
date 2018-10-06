#!/usr/bin/perl -w
use strict;
use warnings;
use File::Compare;
#creating main subroutine
sub main{
	#create an array for storing the identical copies
	my @identical_files;
	#store the directories passed in into two arrays using glob
	my @directory1 = glob("$ARGV[0]/*");
	my @directory2 = glob("$ARGV[1]/*");
	#for each file in the first directory
	foreach my $file1(@directory1){
		#we want to make a variable to hold the file name with no path naming
		my $file1tmp = $file1;
		$file1tmp =~ s/.*\///;
		#now for each file in the second directory
		foreach my $file2(@directory2){
			#we want to make a variable to hold the file name with no path naming
			my $file2tmp = $file2;
			$file2tmp =~ s/.*\///;
			#if the two files in the directories are equal name
			if("$file1tmp" eq "$file2tmp"){
				#then we check if their content is identical
				if(compare("$file1", "$file2") == 0){
					#if they are, we want to push them to our identical files array
					push @identical_files, $file1tmp;
					#exit for loop since we found match
					last;
				}
			}
			#otherwise if the first if failed, we want to just go next
			next;
		}
	}
	#now we want to sort the array in alphabetical order
	@identical_files = sort{$a cmp $b} @identical_files;
	#for each file in the identical files
	foreach my $file(@identical_files){
		#print the file
		print "$file\n";
	}
}
#calling main subroutine
main();	
