#!/usr/bin/perl -w
use strict;
use warnings;
#creating main subroutine
sub main{
	#if the 
	if(@ARGV == 0){
		print "Usage: ./identical_files.pl <files>\n";
	}
	#create a hash for all the files
	my %files;
	#create a array to store file names
	my @filenames;
	#fore all files passed into program
	foreach my $file(@ARGV){
		#add the file to the array of files, and open the file for read
		push @filenames, $file;
		open(my $rf, '<', "$file") or die "./replace_digits.pl: can't open $file\n";
		#create an array to store file content in
		my @array_of_lines;
		#add each line of file into array
		foreach my $line(<$rf>){
			push @array_of_lines,"$line";
		}
		#set the hash with key file name, set value to array
		$files{$file} = "@array_of_lines";
		#close file
		close "$rf";
	}
	#now create an array to store all the file contents in
	my @filecontent;
	#create an array to store all duplicate file names
	my @duplicates;
	#for all files in the hash
	foreach my $keys(keys %files){
		#if the file exists in our visited file areas
		if(grep(/^$files{$keys}$/, @filecontent)){
			#indicates duplicate add to duplicate file array
			push @duplicates, $keys;
			#now we want to add the files that are also duplicates of the current files
			foreach my $duplicate2(@filenames){
				#if the file was a duplicate we want to find all other files that is also duplicate of that file
				if(grep(/^$files{$duplicate2}$/, $files{$keys})){
					#this is to make sure that files cant be duplicates of themselves
					if($duplicate2 eq $keys){
						next;
					}
					#add the file name to the duplicate file list
					push @duplicates, $duplicate2;
				}				
			}
		}else{
			#otherwise we push the file to the file array
			push @filecontent, $files{$keys};
			#add the filename to the filename array
			push @filenames, $keys;
		}
	}
	#now want to make sure we that we dont print duplicates twice
	my @duplicate_lines;
	#count to check if all files are identical
	my $count = 0;
	#scan through program inputs
	foreach my $file(@ARGV){
		#if the file name exists in the duplicates we want to add 1 to the count
		if(grep(/^$file$/,@duplicates)){
			$count++;
		}
	}
	#if the count is equal to number of files passed in
	if($count == @ARGV){
		#print all files are identical
		print "All files are identical\n";
	}
	#otherwise we want to print error messages
	else{
		#for all files that are passed in
		foreach my $unique(@filenames){
			#if the file existed  as a duplicate we want to skip
			if(grep(/^$unique$/, @duplicates)){
				next;
			}
			#otherwise we want to print unique files
			else{
				#if the file has already been printed as unique we want to go next
				if(grep(/^$unique$/, @duplicate_lines)){
					next;
				}
				#otherwise
				else{
					#print the file is not identical
					print "$unique is not identical\n";	
					#add the duplicate line to the unique file array
					push @duplicate_lines, $unique;	
				}		
			}
		}
	}
}
#calling main subroutine
main();	
