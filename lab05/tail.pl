#!/usr/bin/perl -w
#reference for file opening in perl
#https://perlmaven.com/open_and_read_from_files
use strict;
use warnings;
#creating main subroutine
sub main{
	#default number of lines to print is 10
	my $default_lines = 10;
	#if the number of arguements > 0 and the first arguement is an integer
	if(@ARGV > 0 && $ARGV[0] =~ /^-{1}[0-9]*$/){
		#update the number of lines to print to be arg 0
		$default_lines = $ARGV[0];
		#remove pipe so it doesnt look like a negative number
		$default_lines =~ s/-//g;
		#shift the arguements to get rid of the piped integer
		shift @ARGV
	}
	if(@ARGV == 0){
		#set my array of lines to be input from stdin
		my @array_of_lines = <>;
		#if the number of lines in the file is less than the number of lines we want to print begin indexing at start 
		#to avoid negative array indexing
		if(@array_of_lines+1 < $default_lines){
			
			#set the fefault lines = size of array
			$default_lines = @array_of_lines
		}
		#start index to print = the total size of array - default_lines
		for(my $i = @array_of_lines - $default_lines; $i < @array_of_lines; $i++){
			print $array_of_lines[$i];
		}
	}else{
		foreach my $file (@ARGV){
			#open the $file under the variable read file(rf) in read mode hence the <, or print error message
			open(my $rf, '<', $file) or die "./tail.pl: can't open $file\n";
			#print the prompt if more than 1 file
			print "==> $file <==\n" if @ARGV>1;
			#undef the areray so we can reuse it avoid compilation errors
			my $array_of_lines = undef;
			#keep track of current default_lines value
			my $temp_lines = $default_lines;
			#store the entire file into an array 
			my @array_of_lines = <$rf>;
			#undef i so we can re-use the variable avoids compilation error
			my $i = undef;
			#if the number of lines in the file is less than the number of lines we want to print begin indexing at start 
			#to avoid negative array indexing
			if(@array_of_lines <= $default_lines){
				#set the fefault lines = size of array
				$default_lines = @array_of_lines;
			}
			#read from the total size of array of lines - default lines, to the end of the file
			for(my $i = @array_of_lines - $default_lines; $i < @array_of_lines; $i++){
				print $array_of_lines[$i];
			}
			$default_lines = $temp_lines;
			#close file once read
			close $rf;
		}
	}
}
#calling main subroutine
main();
