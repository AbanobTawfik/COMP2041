#!/usr/bin/perl -w
use strict;
use warnings;
#creating main subroutine
sub main{
	#extract the number of nests in our print
	my $n = $ARGV[0];
	if($n <= 0){
		$n = 1;
	}
	#create hash for the different backslash amounts (2n+1)
	my %backslash;
	#now we want to create initally empty variables for print_n and backslash
	my $print_n = " ";
	my $backslash = "";
	#if our number of prints > 1 we want to start with our initial print "
	if($n > 1){
		$print_n = "print \"";
	}
	#now we need variables for the closing quotes
	my $closing_quotes =" ";
	#now we want to loop $n-1 times 
	for(my $count = 1; $count<$n;$count++){
		#we want to store into hash the backslash current value
		$backslash{$count} = "$backslash";
		#backslash = current amount of backslashes * 2 + 1
		$backslash= "$backslash$backslash\\\\";
	}
	#now for our print and closing quotes, 
	for(my $count = 1; $count<$n;$count++){
		#increment print with the backslashes at hash value with a escaped " character at end
		$print_n = "$print_n print$backslash{$count}\\\"";
		#increment closing quotes with the backslashes at hash value with a escaped " character at end
		$closing_quotes = "$closing_quotes $backslash{$n-$count}\\\"";
	}
	#if our n > 1 we want to add ending semi-colon and new line to the end escaped out
	if($n > 1){
		$closing_quotes = "$closing_quotes\\n\"\;";
	}
	#if n = 1 or 0 we dont want any nesting so clear the variables
	if($n <= 1){
		$print_n = "";
		$backslash = "";
	}
	#store the passed in string into variable with new line chracter ont he end
	my $printwords = "$ARGV[1]\n";
	#now we want to add escape character backslashed in to our special characters
	$printwords =~ s/([\\\/\(\)\[\]\'\'\"\"])/$backslash\\$1/g;
	#print the current state
	print "$print_n $printwords $closing_quotes\n";

}

#calling main subroutine
main();
#print " print \" print \\\" Perl that prints Perl that Prints Perl\\\" \"\n";
