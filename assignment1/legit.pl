#!/usr/bin/perl -w
use strict;
use warnings;
use File::Compare;
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
			exit 0;
		}
		if($ARGV[0] eq "log"){
			logg();
			exit 0;
		}
	}
	if($ARGV[0] eq "add"){
		shift @ARGV;
		add(\@ARGV);
		exit 0;
	}
	if($ARGV[0] eq "commit"){
		shift @ARGV;
		commit(\@ARGV);
		exit 0;
	}
	if($ARGV[0] eq "show"){
		shift @ARGV;
		show(\@ARGV);
		exit 0;
	}
	exit 1;
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
	if(! -e  "$repository"){
		no_repository();
	}
	my @arguements = @{$_[0]};
	if(! -e "$index"){
		mkdir "$index";
	}
	foreach my $file(@arguements){
		if(! -e "$file"){
			print "legit.pl: error: can not open \'$file\'\n";
			exit 1;
		}
	}
	foreach my $file(@arguements){
		open($rf, '<', "$file") or die "./legit.pl: could not open $file\n";
		@array_of_lines = <$rf>;
		close $rf;
		open($rf, '>', "$index/$file") or die "./legit.pl: could not open $index/$file\n";
		foreach my $line(@array_of_lines){
			print $rf "$line";
		}
		close $rf;
	}
}

sub commit{
	if(! -e  "$repository"){
		no_repository();
	}
	my @arguements = @{$_[0]};
	my $commit_message;
	my $a_flag_on = 0;
	my $commit_changed_flag = 0;
	my $change_flag = 0;
	if(@arguements < 2 || @arguements > 3){
		commit_error();
	}
	if(@arguements == 3){
		if($arguements[0] ne "-m" and $arguements[1] ne "-m"){
			commit_error();
		}
		if($arguements[0] ne "-a" and $arguements[1] ne "-a"){
			commit_error();
		}
		$a_flag_on = 1;
		$commit_message = "$arguements[2]";
	}
	if(@arguements == 2){
		if($arguements[0] ne "-m"){
			commit_error();
		}
		$commit_message = "$arguements[1]";
	}
	my $count = 0;
	#scan through to find out the first time that the extension count doesnt exist already
	while(-e "$repository/commit$count"){
		#increment counter
		$count++;
	}
	my $previous_commit_count = $count - 1;
	my @index_directory = glob("$index/*");
	if($previous_commit_count >= 0){
		my @previous_commit = glob("$repository/commit$previous_commit_count/*");
		foreach my $file(@previous_commit){
			my $filetmp = $file;
			$filetmp =~ s/.*\///;
			if($filetmp eq "message.txt"){
				print 
				next;
			}
			if(compare("$index/$filetmp","$repository/commit$previous_commit_count/$filetmp") != 0){
				$change_flag = 1;
				last;
			}
		}
		foreach my $file(@index_directory){
			my $filetmp = $file;
			$filetmp =~ s/.*\///;
			if(compare("$index/$filetmp","$repository/commit$previous_commit_count/$filetmp") != 0){
				$change_flag = 1;
				last;
			}
		}
	}else{
		$change_flag = 1;
	}
	if($change_flag == 0){
		print "nothing to commit\n";
		return;
	}
	mkdir "$repository/commit$count";
	foreach my $file(@index_directory){
		open($rf, '<', "$file") or die "./legit.pl: could not open $file\n";
		@array_of_lines = <$rf>;
		close $rf;
		$file =~ s/.*\///;
		open($rf, '>', "$repository/commit$count/$file") or die "./legit.pl: could not open $repository/commit$count/$file\n";
		foreach my $line (@array_of_lines){
			print $rf "$line";
		}
		close $rf;
	}
	open($rf, '>', "$repository/commit$count/message.txt") or die "./legit.pl: could not open $repository/commit$count/message\n";
	print $rf "$commit_message\n";
	close $rf;
	print "Committed as commit $count\n";

}

sub commit_error{
	print "./legit.pl: usage: ./legit.pl commit [-a] -m \'message\'\n";
	exit 1;
}

sub logg{
	if(! -e  "$repository"){
		no_repository();
	}
	#now want to show all commit messages 
	my @log_messages;
	my @commits = glob("$repository/commit*");
	foreach my $commit(@commits){
		open($rf, '<', "$commit/message.txt");
		@array_of_lines = <$rf>;
		close $rf;
		$commit =~ s/.*commit//;
		push @log_messages, "$commit @array_of_lines";
	}
	@log_messages = sort {$b cmp $a} @log_messages;
	foreach my $line(@log_messages){
		print "$line";
	}
}

sub show{
	if(! -e  "$repository"){
		no_repository();
	}
	my @arguements = @{$_[0]};
	if(@arguements != 1){
		show_error();
	}
	my $commit_number = $arguements[0];
	$commit_number =~ s/:.*//;
	my $show_file = $arguements[0];
	$show_file =~ s/.*://;
	if($commit_number eq ""){
		if(!-e "$index/$show_file"){
			print "legit.pl: error: \'$show_file\' not found in index\n";
			exit 1;
		}
		open($rf, '<', "$index/$show_file") or die "./legit.pl: could not open $index/$show_file\n";
		@array_of_lines = <$rf>;
		close $rf;
		foreach my $line(@array_of_lines){
			print "$line";
		}
		return;
	}else{
		if(! -e "$repository/commit$commit_number"){
			print "legit.pl: error: unknown commit \'$commit_number\'\n";
			exit 1;
		}
		if(!-e "$repository/commit$commit_number/$show_file"){
			print "legit.pl: error: \'$show_file\' not found in commit $commit_number\n";
			exit 1;
		}
		open($rf, '<', "$repository/commit$commit_number/$show_file") or die "./legit.pl: could not open $repository/commit$commit_number/$show_file\n";
		@array_of_lines = <$rf>;
		close $rf;
		foreach my $line(@array_of_lines){
			print "$line";
		}
	}
}


sub show_error{
	print "./legit.pl: usage: ./legit.pl [n]:\'file\'\n";
	exit 1;
}

sub no_repository{
	print "legit.pl: error: no .legit directory containing legit repository exists\n";
	exit 1;
}
