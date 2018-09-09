#!/usr/bin/perl -w
use strict;
use warnings;
#reference for reading and opening files in directory
#https://stackoverflow.com/questions/2149368/how-can-i-loop-through-files-in-a-directory-in-perl
#creating main subroutine
sub main{
	if(@ARGV == 1){
		&save();
	}
	elsif(@ARGV == 2){
		&load("$ARGV[1]");
	}else{
		print "./backup.pl usage: [save] or [load version]"
	}
	
}

sub save{
	#open the current directory under the variable directory
	my @directory = <*>;
	my $count = 0;
	#scan through to find out the first time that the extension count doesnt exist already
	while(-e ".snapshot.$count"){
		#increment counter
		$count++;
	}
	my $backup_directory = ".snapshot.$count";
	print "Creating snapshot $count\n";
	mkdir "$backup_directory";
	foreach my $file(@directory){
		if("$file" eq ".." or "$file" eq "." or "$file" eq "snapshot.pl"){
			next;
		}
		#open the original file for read in read mode
		open(my $rf, '<', "$file") or die "./backup.pl: can't open $file\n";
		#store the file content into the array
		my @array_of_lines = <$rf>;
		#close the file
		close $rf;
		#now we want to open our backup file in write mode
		open($rf, '>', "$backup_directory/$file") or die "./backup.pl: can't open $backup_directory/$file";
		#print line by line to the file, the content of our original file
		foreach my $line(@array_of_lines){
			print $rf "$line";
		}
		#close the file
		close $rf;
		#print the success message that their filed has been saved
	}
}

sub load{
	my $version = $_[0];
	if(-z ".snapshot.$version"){
		print "current version requested does not exist\n";
	}else{
		&save();
		print "Restoring snapshot $version\n";
		#store directory files from backup into an array
		my @directory = <".snapshot.$version/*">;
		#scan through file by file (overwriting as needed)
		foreach my $file(@directory){
			#open the original file for read in read mode
			open(my $rf, '<', "$file") or die "./backup.pl: can't open $file\n";
			#store the file content into the array
			my @array_of_lines = <$rf>;
			#close the file
			close $rf;
			#get rid of the .snapshot.n/ part since we want the file in original directory
			$file =~ s/.+\///;
			#now we want to open our backup file in write mode which will also rewrite file from scratch
			open($rf, '>', "$file") or die "./backup.pl: can't open $file";
			#print line by line to the file, the content of our original file
			foreach my $line(@array_of_lines){
				print $rf "$line";
			}
			#close the file
			close $rf;
		}	
	}
}
#calling main subroutine
main();		
