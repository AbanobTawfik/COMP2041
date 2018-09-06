#!/usr/bin/perl -w
use strict;
use warnings;
#creating main subroutine
sub main{
	#call pre-requisite on each program arguement
	if(@ARGV == 1){
		if($ARGV[0] eq "init"){
			init();
		}
	}
	exit 0;
}
#calling main subroutine
main();	

sub init{
	if(-e "\.legit"){
		print "legit.pl: error: .legit already exists\n";
		return;
	}else{
		my $VCS = ".legit";
		mkdir "$VCS";
		print "Initialized empty legit repository in .legit\n";
		return;
	}

}	
