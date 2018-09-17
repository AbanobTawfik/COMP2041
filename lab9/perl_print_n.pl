#!/usr/bin/perl -w
use strict;
use warnings;
#creating main subroutine
sub main{
	my $n = $ARGV[0];
	my %backslash;
	my $print_n = " ";
	my $backslash = "";
	if($n > 1){
		$print_n = "print \"";
	}
	my $closing_quotes =" ";
	for(my $count = 1; $count<$n;$count++){
		$backslash{$count} = "$backslash";
		$backslash= "$backslash$backslash\\\\";
	}
	for(my $count = 1; $count<$n;$count++){
		$print_n = "$print_n print$backslash{$count}\\\"";
		$closing_quotes = "$closing_quotes $backslash{$n-$count}\\\"";
	}
	if($n > 1){
		$closing_quotes = "$closing_quotes\\n\"\;";
	}
	if($n <= 1){
		$print_n = "";
		$backslash = "";
	}
	my $printwords = "$ARGV[1]\n";
	$printwords =~ s/(\W)/\\$1/g;
	print "$print_n$printwords$closing_quotes\n";

}

#calling main subroutine
main();
#print " print \" print \\\" Perl that prints Perl that Prints Perl\\\" \"\n";
