#!/usr/bin/perl -w
use strict;
use warnings;
#creating main subroutine
my $using_recursion = 0;
if($ARGV[0] =~/^-r/){
	$using_recursion = 1;
	shift @ARGV;
}
#global declaration of visited hash + pre-requisites list
my %seen;
my @prerequisites = ();

#this subroutine only takes 1 arguement each call, (course code)
sub pre_requisites{
	#to stop 1 stupid warning on uninitialised values when passing in arguements
	no warnings 'all';
	#set the course to be first subroutine arguement
	my ($course) = $_[0];
	#get the post + under grad handbook pages since courses can have multiple different pre-req's
	my $url_postgrad = "http://www.handbook.unsw.edu.au/postgraduate/courses/2018/$course.html";
	my $url_undergrad = "http://www.handbook.unsw.edu.au/undergraduate/courses/2018/$course.html";
	#open both of the html pages using wget
	open my $F, "wget -q -O- $url_postgrad $url_undergrad|" or die;
	#turning warnings back on now the file has been processed iwthout uninitalised value when it is clearly initalised
	use warnings 'all';
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
	    		#turn of warnings otherwise we get issue in hash uninitalised even though it's global
	    		no warnings 'all';
	    		#if the course has been seen in the hash we go to the next match to avoid duplicates
				if($seen{$1} == 1){
					next;
				}
				#otherwise we will want to add it to our pre-requisites list
				else{
	    			push @prerequisites, "$1";
	    			#set the course in the hash as visited already
	    			$seen{$1} = 1;
	    			#if we are using recursion we will call  prerequisites on the matched pattern aswell
	    			if($using_recursion == 1){
	    				#call pre-requisites on the course
	    				&pre_requisites($1);
	    			}
				}
	    	}
	    }
	}
	#close the file 
	close $F;
}
sub main{
	#call pre-requisite on each program arguement
	foreach my $course(@ARGV){
		&pre_requisites($course);
	}

	#now we want to print our pre-requisite array in ALPHABETICAL order (using sort)
	foreach my $pre_requisite_courses(sort @prerequisites){
		print "$pre_requisite_courses\n";
	}
}
#calling main subroutine
main();
