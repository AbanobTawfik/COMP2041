#!/usr/bin/perl -w
use strict;
use warnings;
#creating main subroutine
sub main{
	#create empty array for the pre-requisites
	my @prerequisites = ();
	#for all the courses passed in as program arguements
	foreach my $course(@ARGV){
		#get the post + under grad handbook pages since courses can have multiple different pre-req's
		my $url_postgrad = "http://www.handbook.unsw.edu.au/postgraduate/courses/2018/$course.html";
		my $url_undergrad = "http://www.handbook.unsw.edu.au/undergraduate/courses/2018/$course.html";
		#open both of the html pages using wget
		open my $F, "wget -q -O- $url_postgrad $url_undergrad|" or die;
		#scant hrough the file line by line
		while (my $line = <$F>) {
			#if the line contains "pre-requisite"
		    if($line =~ /<p>Prerequisite/){
				#remove all characters after the ending paragraph tag and full stop
				$line =~ s/\.<\/p>.+//;
				#remove all characters after ending paragraph tag no full stop
				$line =~ s/<\/p>.+//;
				#now we want to scan through the line matching the course code pattern
		    	while($line =~ /([A-Z]{4}[0-9]{4})/g){
		    		#push each course code into the next array index
		    		push @prerequisites, "$1";
		    	}
		    }
		}
		#close the file 
		close $F;
	}
	#now we want to print our pre-requisite array in ALPHABETICAL order (using sort)
	foreach my $pre_requisite(sort @prerequisites){
		print "$pre_requisite\n";
	}

}
#calling main subroutine
main();	
