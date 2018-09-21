#!/usr/bin/perl -w
use strict;
use warnings;
use File::Compare;
#creating main subroutine
my $repository = ".legit";
my $branch = "master";
my $commits = "commit";
my $index = "$repository/$branch/index";
my $global_remove = 0;
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
	if($ARGV[0] eq "rm"){
		shift @ARGV;
		rm(\@ARGV);
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
		mkdir "$repository/$branch";
		open($rf, '>', "$repository/current_branch.txt");
		print $rf "$branch";
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
		if(-e "$index/$file"){
			if(!-e "$file"){
				unlink "$index/$file";
				$global_remove = 1;
				return;
			}	
		}
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
	if($a_flag_on == 1){
		add_all_files_to_index();
	}
	my $count = 0;
	#scan through to find out the first time that the extension count doesnt exist already
	while(-e "$repository/$branch/commit$count"){
		#increment counter
		$count++;
	}
	my $previous_commit_count = $count - 1;
	my @index_directory = glob("$index/*");
	if($previous_commit_count >= 0){
		my @previous_commit = glob("$repository/$branch/commit$previous_commit_count/*");
		foreach my $file(@previous_commit){
			my $filetmp = $file;
			$filetmp =~ s/.*\///;
			if($filetmp eq "message.txt"){ 
				next;
			}
			if(!-e "$index/$filetmp"){
				$change_flag = 1;
				last;
			}
			if(compare("$index/$filetmp","$repository/$branch/commit$previous_commit_count/$filetmp") != 0){
				$change_flag = 1;
				last;
			}
		}
		foreach my $file(@index_directory){
			my $filetmp = $file;
			$filetmp =~ s/.*\///;
			if(compare("$index/$filetmp","$repository/$branch/commit$previous_commit_count/$filetmp") != 0){
				$change_flag = 1;
				last;
			}
		}
	}else{
		$change_flag = 1;
	}
	if($global_remove == 1){
		$change_flag = 1;
	}
	if($change_flag == 0){
		print "nothing to commit\n";
		return;
	}
	mkdir "$repository/$branch/commit$count";
	foreach my $file(@index_directory){
		open($rf, '<', "$file") or die "./legit.pl: could not open $file\n";
		@array_of_lines = <$rf>;
		close $rf;
		$file =~ s/.*\///;
		open($rf, '>', "$repository/$branch/commit$count/$file") or die "./legit.pl: could not open $repository/$branch/commit$count/$file\n";
		foreach my $line (@array_of_lines){
			print $rf "$line";
		}
		close $rf;
	}
	open($rf, '>', "$repository/$branch/commit$count/message.txt") or die "./legit.pl: could not open $repository/$branch/commit$count/message\n";
	print $rf "$commit_message\n";
	close $rf;
	print "Committed as commit $count\n";

}

sub add_all_files_to_index{
	my @arguements = <*>;
	if(! -e "$index"){
		mkdir "$index";
	}
	foreach my $file(@arguements){
		if("$file" eq ".." or "$file" eq "." or "$file" eq "legit.pl"){
			next;
		}
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
	my @commits = glob("$repository/$branch/commit*");
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
		if(! -e "$repository/$branch/commit$commit_number"){
			print "legit.pl: error: unknown commit \'$commit_number\'\n";
			exit 1;
		}
		if(!-e "$repository/$branch/commit$commit_number/$show_file"){
			print "legit.pl: error: \'$show_file\' not found in commit $commit_number\n";
			exit 1;
		}
		open($rf, '<', "$repository/$branch/commit$commit_number/$show_file") or die "./legit.pl: could not open $repository/$branch/commit$commit_number/$show_file\n";
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

sub rm{
	my @arguements = @{$_[0]};
	my $cached_remove_flag = 0;
	my $force_remove_flag = 0;
	my $shift_counter = 0;
	if(@arguements >= 2 and $arguements[0] eq "--cached"){
		$shift_counter++;
		$cached_remove_flag = 1;
	}
	if(@arguements >= 2 and $arguements[0] eq "--force"){
		$shift_counter++;
		$force_remove_flag = 1;
	}
	if(@arguements >= 2 and $arguements[1] eq "--cached"){
		$shift_counter++;
		$cached_remove_flag = 1;
	}
	if(@arguements >= 2 and $arguements[1] eq "--force"){
		$shift_counter++;
		$force_remove_flag = 1;
	}
	for(my $i = 0; $i < $shift_counter; $i++){
		shift @arguements;
	}
	my $count = 0;
	#scan through to find out the first time that the extension count doesnt exist already
	while(-e "$repository/$branch/commit$count"){
		#increment counter
		$count++;
	}
	my $previous_commit_count = $count - 1;
	#force bypasses flag
	if($force_remove_flag == 1){
		foreach my $file(@arguements){
			if(!-e "$index/$file"){
				print "legit.pl: error: \'$file\' is not in the legit repository\n";
				exit 1;
			}
			unlink "$index/$file";
			unlink "$file";
		}
	}elsif($cached_remove_flag == 1){
		foreach my $file(@arguements){
			if(!-e "$index/$file"){
				print "legit.pl: error: \'$file\' is not in the legit repository\n";
				exit 1;
			}
			if((compare("$index/$file","$repository/$branch/commit$previous_commit_count/$file") == 0)  or (compare("$file","$index/$file") == 0)){
				unlink "$index/$file";
				return;
			}
			rm_errors($file,$previous_commit_count);
		}
	}else{
		foreach my $file(@arguements){
			if(!-e "$file"){
				print "./legit.pl: \'$file\' was not found in the index\n";
				exit 1;
			}
			if(! -e "$index/$file"){
				print "legit.pl: error: \'$file\' is not in the legit repository\n";
				next;
			}
			if(compare("$file","$repository/$branch/commit$previous_commit_count/$file") == 0 and compare("$file","$index/$file") == 0){
				unlink "$file";
				unlink "$index/$file";
				return;
			}
			rm_errors($file,$previous_commit_count);
		}
	}
}

sub rm_errors{
	my $file = $_[0];
	my $previous_commit_count = $_[1];

	if(compare("$file","$repository/$branch/commit$previous_commit_count/$file") == 1 and compare("$file","$index/$file") == 1 and compare("$index/$file","$repository/$branch/commit$previous_commit_count/$file") == 1){
		print "legit.pl: error: \'$file\' in index is different to both working file and repository\n";
		return;
	}
	if(compare("$file","$index/$file") == 1){
		print "legit.pl: error: \'$file\' in repository is different to working file\n";
		return;
	}
	if(!-e "$repository/commit$previous_commit_count/$file" and -e "$index/$file"){
		print "legit.pl: error: \'$file\' has changes staged in the index\n";
		return;
	}
	if(compare("$file","$repository/commit$previous_commit_count/$file") == 1){
		print "legit.pl: error: \'$file\' has changes staged in the index\n";
		return;
	}
}

sub no_repository{
	print "legit.pl: error: no .legit directory containing legit repository exists\n";
	exit 1;
}
