#!/usr/bin/perl -w
use strict;
use warnings;
#creating main subroutine
my $repository = ".legit";
my $index = "$repository/index";
my $rf;
my @array_of_lines;
sub main{
	#call pre-requisite on each program arguement
	if(@ARGV == 1){
		if($ARGV[0] eq "init"){
			init();
		}
	}
	if($ARGV[0] eq "add"){
		shift @ARGV;
		add(\@ARGV);
	}
	if($ARGV[0] eq "commit"){
		shift @ARGV;
		commit(\@ARGV);
	}
	exit 0;
}
#calling main subroutine
main();	

sub init{
	if(-e "$repository"){
		print "legit.pl: error: .legit already exists\n";
		return;
	}else{
		mkdir "$repository";
		print "Initialized empty legit repository in .legit\n";
		return;
	}

}	

sub add{
	my @arguements = @{$_[0]};
	if(! -e  "$repository"){
		no_repository();
	}
	if(! -e "$index"){
		mkdir "$index";
	}
	foreach my $file(@arguements){
		if(! -e "$file"){
			print "legit.pl: fatal error: \'$file\' did not match any files\n";
			exit 1;
		}
	}

	foreach my $file(@arguements){
		open($rf, '<', "$file");
		@array_of_lines = <$rf>;
		close $rf;
		open($rf, '>', "$index/$file");
		foreach my $line(@array_of_lines){
			print $rf "$line";
		}
		close $rf;
	}
}

sub commit{
	my @arguements = @{$_[0]};
	my $commit_message;
	if(@arguements == 3){
		$commit_message = $arguements[2];
	}
	if($arguements[0] ne "\-m"){
		print "./legit.pl: usage: ./legit.pl commit [-a] -m \'message\'\n";
		exit 1;
	}
	if(! -e  "$repository"){
		no_repository();
	}
	my $count = 0;
	#scan through to find out the first time that the extension count doesnt exist already
	while(-e "$repository/commit$count"){
		#increment counter
		$count++;
	}
	mkdir "$repository/commit$count";
	my @index_directory = glob("$index/*");
	foreach my $file(@index_directory){
		print "$file\n";
	}

}

sub no_repository{
	print "legit.pl: error: the repository has not been initialized try \'\.\/legit\.pl init\' and retry";
	exit 1;
}
