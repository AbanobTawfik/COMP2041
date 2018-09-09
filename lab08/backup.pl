#!/usr/bin/perl -w
use strict;
use warnings;
#creating main subroutine
sub main{
	#set file name equal to first arguement
	my $filename = $ARGV[0];
	my $count = 0;
	#scan through to find out the first time that the extension count doesnt exist already
	while(-e ".$filename.$count"){
		#increment counter
		$count++;
	}
	#open the original file for read in read mode
	open(my $rf, '<', "$filename") or die "./backup.pl: can't open $filename\n";
	#store the file content into the array
	my @array_of_lines = <$rf>;
	#close the file
	close $rf;
	#now we want to open our backup file in write mode
	open($rf, '>', "\.$filename\.$count") or die "./backup.pl: can't open \.$filename\.$count\n";
	#print line by line to the file, the content of our original file
	foreach my $line(@array_of_lines){
		print $rf "$line";
	}
	#close the file
	close $rf;
	#print the success message that their filed has been saved
	print "Backup of '$filename' saved as '\.$filename\.$count'\n"

}
#calling main subroutine
main();		
