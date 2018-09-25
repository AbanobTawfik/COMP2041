#!/usr/bin/perl -w
use strict;
use warnings;
use File::Compare;
use File::Copy::Recursive qw(dircopy);
use List::MoreUtils qw(uniq);
use File::Path 'rmtree';
use File::Copy;
#creating main subroutine
my $repository = ".legit";
my $branch = "master";
my $commits = "commit";
my $index = "$repository/index";
my $global_remove = 0;
my $rf;
my @array_of_lines;
my $merge_allowed = 0;
sub main{
	if(-e "$repository/current_branch.txt"){
		open($rf, '<', "$repository/current_branch.txt");
		@array_of_lines = <$rf>;
		close $rf;
		$branch = $array_of_lines[0];	
		$index = "$repository/index";
	}
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
		if($ARGV[0] eq "status"){
			status();
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
		exit 0;
	}
	if($ARGV[0] eq "branch"){
		shift @ARGV;
		branch(\@ARGV);
		exit 0;
	}
	if($ARGV[0] eq "checkout"){
		shift @ARGV;
		checkout(\@ARGV);
	}
	if($ARGV[0] eq "merge"){
		shift @ARGV;
		merge(\@ARGV);
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
		print $rf "master";
		close $rf;
		mkdir "$repository/\.$branch";
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
	my $count = find_last_commit_number();
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
	save($branch);
		print "Committed as commit $count\n";
	if($merge_allowed == 1){
		update_working_directory_from_index($count);
	}
}

sub update_working_directory_from_index{
	my $count = $_[0];
	my @files = glob("$index/*");
	foreach my $file(@files){
		my $filetmp = $file;
		$filetmp =~ s/.*\///;
		if("$filetmp" eq ".." or "$filetmp" eq "." or "$filetmp" eq "legit.pl" or "$filetmp" eq "message.txt"){
			next;
		}
		if(! -e "$filetmp" or compare("$file", "$filetmp") == 1){
			open($rf, '<', "$file");
			@array_of_lines = <$rf>;
			close $rf;
			open($rf, '>', "$filetmp");
			foreach my $line(@array_of_lines){
				print $rf "$line";
			}
			close $rf;
		}
		if(compare("$file","$filetmp") == 0){
			next;
		}
	}
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
		if(! -e "$index/$file"){
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

sub find_last_commit_number{
	my $count = 0;
	my @commit_numbers;
	my @branches = glob("$repository/*");
	foreach my $branch(@branches){
		if("$branch" eq "$repository/index"){
			next;
		}
		$branch =~ s/.*\///;
		if($branch eq "current_branch.txt"){
			next;
		}else{
			my @commits = glob("$repository/$branch/*");
			foreach my $commit(@commits){
				$commit =~ s/.*\///;
				if("$commit" eq "index"){
					next;
				}else{
					$commit =~ s/commit//;
					push @commit_numbers, $commit;
				}
			}
		}
	}
	@commit_numbers = sort{$b <=> $a} @commit_numbers;
	if(@commit_numbers == 0){
		return 0;
	}else{
		return $commit_numbers[0] + 1;
	}
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
	if(! -e  "$repository"){
		no_repository();
	}
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

	my $count = find_last_commit_number();
	my $previous_commit_count = $count - 1;
	if($cached_remove_flag == 1){
		foreach my $file(@arguements){
			if(!-e "$index/$file"){
				print "legit.pl: error: \'$file\' is not in the legit repository\n";
				exit 1;
			}
		}
		if($force_remove_flag == 1){
			foreach my $file(@arguements){
				unlink "$index/$file";
			}
			return;
		}
		foreach my $file(@arguements){
			if((compare("$index/$file","$repository/$branch/commit$previous_commit_count/$file") == 0)  or (compare("$file","$index/$file") == 0)){
				unlink "$index/$file";
				next;
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
				exit 1;
			}
		}
		if($force_remove_flag == 1){
			foreach my $file(@arguements){
				if(!-e "$index/$file"){
					print "legit.pl: error: \'$file\' is not in the legit repository\n";
					exit 1;
				}
				unlink "$index/$file";
				unlink "$file";
			}
			return;
		}
		foreach my $file(@arguements){
			if(compare("$file","$repository/$branch/commit$previous_commit_count/$file") == 0 and compare("$file","$index/$file") == 0){
				unlink "$file";
				unlink "$index/$file";
				next;
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

sub status{
	if(! -e  "$repository"){
		no_repository();
	}
	my %file_hash;
	my $count = 0;
	while(-e "$repository/$branch/commit$count"){
		$count++;
	}
	my $previous_commit_count = $count - 1;
	my @index_files = glob("$index/*");
	my @commit_files = glob("$repository/$branch/commit$previous_commit_count/*");
	my @directory_files = glob("*");
	my @all_files;
	foreach my $file(@index_files){
		$file =~ s/.*\///;;
		$file_hash{$file}++;
		if($file_hash{$file} <= 1){
			push @all_files, $file;
			$file_hash{$file}++;
		}
	}
	foreach my $file(@commit_files){
		$file =~ s/.*\///;
		$file_hash{$file}++;
		if($file_hash{$file} <= 1){
			push @all_files, $file;
			$file_hash{$file}++;
		}
	}
	foreach my $file(@directory_files){
		$file_hash{$file}++;
		if($file_hash{$file} <= 1){
			push @all_files, $file;
			$file_hash{$file}++;
		}
	}
	@all_files = sort {$a cmp $b} @all_files;
	foreach my $file(@all_files){
		status_message($file, $previous_commit_count);
	}

}

sub status_message{
	my $file = $_[0];
	my $previous_commit_count = $_[1];
	if("$file" eq ".." or "$file" eq "." or "$file" eq "message.txt" or "$file" eq "current_branch.txt"){
		return;
	}
	if(compare("$file","$repository/$branch/commit$previous_commit_count/$file") == 0){
		print "$file - same as repo\n";
	}elsif(compare("$file", "$index/$file") == 1 and compare("$index/$file","$repository/$branch/commit$previous_commit_count/$file") == 1){
		print "$file - file changed, different changes staged for commit\n";
	}elsif(compare("$file", "$index/$file") == 0 and compare("$index/$file","$repository/$branch/commit$previous_commit_count/$file") == 1){
		print "$file - file changed, changes staged for commit\n";
	}elsif(compare("$file","$index/$file") == 1 and compare("$index/$file","$repository/$branch/commit$previous_commit_count/$file") == 0){
		print "$file - file changed, changes not staged for commit\n";
	}elsif(!-e "$file" and compare("$index/$file", "$repository/$branch/commit$previous_commit_count/$file") == 0){
		print "$file - file deleted\n";
	}elsif((! -e "$file") and (! -e "$index/file") and (-e "$repository/$branch/commit$previous_commit_count/$file")){
		print "$file - deleted\n";
	}elsif(compare("$file", "$index/$file") == 0 and (! -e "$repository/$branch/commit$previous_commit_count/$file")){
		print "$file - added to index\n";
	}elsif((-e "$file") and (! -e "$index/$file")){
		print "$file - untracked\n";
	}
}

sub branch{
	if(! -e  "$repository"){
		no_repository();
	}
	my @arguements = @{$_[0]};
	my $delete_flag = 0;
	my $branch_name;
	if(@arguements > 2){
		print "legit.pl: error: usage \.\/legit\.pl -d \[branch name\]\n";
	}
	if(@arguements == 1 and $arguements[0] eq "-d"){
		print "legit.pl: error: usage \.\/legit\.pl -d \[branch name\]\n";
	}
	if(@arguements == 2 and $arguements[0] eq "-d"){
		$delete_flag = 1;
		$branch_name = $arguements[1];
	}
	if(@arguements == 1){
		$branch_name = $arguements[0];
	}
	if(($delete_flag == 0) and (find_last_commit_number() == 0)){
		print "legit.pl: error: your repository does not have any commits yet\n";
		exit 1;
	}
	if((@arguements == 1) and (-e "$repository/$branch_name")){
		print "legit.pl: error: branch \'$branch_name\' already exists\n";
		exit 1;
	}
	if(@arguements == 0){
		my @branches = glob("$repository/*");
		foreach my $branch(@branches){
			$branch =~ s/.*\///;
			if($branch eq "current_branch.txt" or $branch eq "index"){
				next;
			}else{
				print "$branch\n";
			}
		}
		return;
	}

	if($delete_flag == 1){
		if(!-e "$repository/$branch_name"){
			print "legit.pl: error: branch \'$branch_name\' does not exist\n";
			exit 1;
		}
		my $count;
		my @commits = glob("$repository/$branch/commit*");
		my @commit_numbers_current_branch;
		foreach my $commit(@commits){
			$commit =~ s/.*commit//;
			push @commit_numbers_current_branch, "$commit";
		}
		@commit_numbers_current_branch = sort {$b cmp $a} @commit_numbers_current_branch;
		$count = $commit_numbers_current_branch[0];
		my $previous_commit = $commit_numbers_current_branch[1];
		my $count2;
		my @commits2 = glob("$repository/$branch_name/commit*");
		my @commit_numbers_merge_branch;
		foreach my $commit(@commits2){
			$commit =~ s/.*commit//;
			push @commit_numbers_merge_branch, "$commit";
		}
		@commit_numbers_merge_branch = sort {$b cmp $a} @commit_numbers_merge_branch;
		$count2 = $commit_numbers_merge_branch[0];
		my $previous_commit2 = $commit_numbers_merge_branch[1];
		my @current_branch_last_commit = glob("$repository/$branch/commit$count/*");
		my @merge_branch_last_commit = glob("$repository/$branch_name/commit$count2/*");
		
		my $check = check_if_merge_is_possible(\@current_branch_last_commit, \@merge_branch_last_commit,$count,$count2,$branch_name,$previous_commit, $previous_commit2);
		if($check != 1){
			print "legit.pl: error: branch \'$branch_name\' has unmerged changes\n";
			exit 1;
		}
		if("$branch_name" eq "$branch"){
			print "legit.pl: error: can not delete branch \'$branch_name\'\n";
			exit 1;
		}
		if(!-e "$repository/$branch_name"){
			print "legit.pl: error: branch \'$branch_name\' does not exist\n";
			exit 1;
		}else{
			rmtree(["$repository/$branch_name"]);
			rmtree(["$repository/\.$branch_name"]);
			print "Deleted branch \'$branch_name\'\n";
			return;
		}
	}else{
		dircopy("$repository/$branch", "$repository/$branch_name");
		mkdir "$repository/$branch_name";
		mkdir "$repository/\.$branch_name";
		save($branch_name);
		return;
	}
}

sub save{
	my $branch_name = $_[0];
	my @directory = <*>;
	foreach my $file(@directory){
		if("$file" eq "legit\.pl"){
			next;
		}
		open($rf, '<', "$file");
		@array_of_lines = <$rf>;
		close $rf;
		open($rf, '>', "$repository/\.$branch_name/$file");
		foreach my $line(@array_of_lines){
			print $rf "$line";
		}
		close $rf;
	}
}

sub checkout{
	if(! -e  "$repository"){
		no_repository();
	}
	my @arguements = @{$_[0]};
	if(@arguements != 1){
		print "legit.pl: usage: ./legit.pl checkout [branch_name]\n";
		exit 1;
	}
	my $branch_name = $arguements[0];

	if(! -e "$repository/$branch_name"){
		print "legit.pl: error: unknown branch \'$branch_name\'\n";
		exit 1;
	}
	if("$branch" eq "$branch_name"){
		print "legit.pl: error: already on branch \'$branch_name\'\n";
	}else{
		#update working directory to current state in index
		#updated_save($branch_name, $branch);

		my $count;
		my @commits = glob("$repository/$branch/commit*");
		my @commit_numbers_current_branch;
		foreach my $commit(@commits){
			$commit =~ s/.*commit//;
			push @commit_numbers_current_branch, "$commit";
		}
		@commit_numbers_current_branch = sort {$b cmp $a} @commit_numbers_current_branch;
		$count = $commit_numbers_current_branch[0];
		my $count2;
		my @commits2 = glob("$repository/$branch_name/commit*");
		my @commit_numbers_merge_branch;
		foreach my $commit(@commits2){
			$commit =~ s/.*commit//;
			push @commit_numbers_merge_branch, "$commit";
		}
		@commit_numbers_merge_branch = sort {$b cmp $a} @commit_numbers_merge_branch;
		$count2 = $commit_numbers_merge_branch[0];
		check_override($branch_name, $count, $count2);
		add_new_files();
		if($count != $count2){
			update_working_directory($branch_name);
		}

		open($rf, '>', "$repository/current_branch.txt");
		print $rf "$branch_name";
		close $rf;

		print "Switched to branch \'$branch_name\'\n";
	}
}

sub check_override{
	my $check = 0;
	my $branch_name = $_[0];
	my $count = $_[1];
	my $count2 = $_[2];
	my @directory = <*>;
	my @unsaved_work;
	if($count == $count2){
		return;
	}
	foreach my $file(@directory){
		if("$file" eq ".." or "$file" eq "." or "$file" eq "legit.pl" or "$file" eq "diary.txt"){
			next;
		}
		if((compare("$file","$index/$file") != 0) and (compare("$file","repository/$branch/commit$count/$file")!= 0) and (compare("$file","$repository/$branch_name/commit$count2/$file") != 0)
			and (compare("$file", "$repository/\.$branch/$file") != 0) and (compare("$file", "$repository/\.$branch_name/$file") != 0)){
			push @unsaved_work, $file;
		}
	}
	if(@unsaved_work >= 1){
		print "legit.pl: error: Your changes to the following files would be overwritten by checkout:\n";
		foreach my $file(@unsaved_work){
			print "$file\n";
		}
		exit 1;
	}

}

sub add_new_files{
	my @directory = <*>;
	foreach my $file(@directory){
		if("$file" eq ".." or "$file" eq "." or "$file" eq "legit.pl"){
			next;
		}
		if(! -e "$repository/\.$branch/$file"){
			open($rf, '<', "$file");
			@array_of_lines = <$rf>;
			close $rf;
			open($rf, '>', "$repository/\.$branch/$file");
			foreach my $line(@array_of_lines){
				print $rf "$line";
			}
			close $rf;			
		}
	}
}

sub update_working_directory{
	my $branch_name = $_[0];
	my @directory = <*>;
	my @branch_save = glob("$repository/\.$branch_name/*");
	foreach my $file(@directory){
		if($file eq "legit.pl"){
			next;
		}else{
			unlink "$file";
		}
	}
	foreach my $file(@branch_save){
		open($rf, '<', "$file");
		@array_of_lines = <$rf>;
		close $rf;
		$file =~ s/.*\///;
		open($rf, '>', "$file");
		foreach my $line(@array_of_lines){
			print $rf "$line";
		}
		close $rf;
	}
}

sub merge{
	if(! -e  "$repository"){
		no_repository();
	}
	my @arguements = @{$_[0]};
	if(@arguements != 3 and ($arguements[0] ne "-m" or $arguements[1] ne "-m")){
		print "legit.pl: error: usage \.\/legit\.pl <merge> <branch> <-m> <commit_message>\n";
		exit 1;
	}
	my $commit_message;
	my $branch_name;
	if($arguements[0] eq "-m"){
		$commit_message = $arguements[1];
		$branch_name = $arguements[2];
	}
	if($arguements[1] eq "-m"){
		$branch_name = $arguements[0];
		$commit_message = $arguements[2];
	}
	if(! defined $commit_message){
		print "legit.pl: error: empty commit message\n";
	}

	if(! -e "$repository/$branch_name"){
		print "legit.pl: error: unknown branch \'$branch_name\'\n";
	}

	my $count;
	my @commits = glob("$repository/$branch/commit*");
	my @commit_numbers_current_branch;
	foreach my $commit(@commits){
		$commit =~ s/.*commit//;
		push @commit_numbers_current_branch, "$commit";
	}
	@commit_numbers_current_branch = sort {$b cmp $a} @commit_numbers_current_branch;
	$count = $commit_numbers_current_branch[0];
	my $previous_commit = $commit_numbers_current_branch[1];
	my $count2;
	my @commits2 = glob("$repository/$branch_name/commit*");
	my @commit_numbers_merge_branch;
	foreach my $commit(@commits2){
		$commit =~ s/.*commit//;
		push @commit_numbers_merge_branch, "$commit";
	}
	@commit_numbers_merge_branch = sort {$b cmp $a} @commit_numbers_merge_branch;
	$count2 = $commit_numbers_merge_branch[0];
	my $previous_commit2 = $commit_numbers_merge_branch[1];
	if((!defined $count2) or (!defined $count) or ($count2 > $count)){
		fast_forward($branch_name, $count2);
		print "Fast-forward: no commit created\n";
		exit 1;
	}
	if(($count2 == $count) or ("$branch_name" eq "$branch")){
		print "Already up to date\n";
		exit 1;
	}

	#now want to attempt to merge, by combining the last two commits of a branch into
	#the current branch.
	my @current_branch_last_commit = glob("$repository/$branch/commit$count/*");
	my @merge_branch_last_commit = glob("$repository/$branch_name/commit$count2/*");
	#check if merge is possible

	my $check = check_if_merge_is_possible(\@current_branch_last_commit, \@merge_branch_last_commit,$count,$count2,$branch_name,$previous_commit, $previous_commit2);
	if($check == 1){
		exit 1;
	}
	perform_merge(\@current_branch_last_commit, \@merge_branch_last_commit, $branch_name,$count,$count2,$previous_commit, $previous_commit2);
	my @commit_arguements;
	$commit_arguements[0] = "-m";
	$commit_arguements[1] = "$commit_message";
	$merge_allowed = 1;
	commit(\@commit_arguements);
	add_all_extra_commits($branch_name);

}

sub add_all_extra_commits{
	my $branch_name = $_[0];
	my @merge_branch_directory = glob("$repository/$branch_name/*");

	foreach my $commit(@merge_branch_directory){
		$commit =~ s/.*\///;
		if(!-e "$repository/$branch/$commit"){
			dircopy("$repository/$branch_name/$commit", "$repository/$branch/$commit");
		}
	}
}

sub fast_forward{
	my $branch_name = $_[0];
	my $count = $_[1];
	my @files = glob("$repository/$branch_name/commit$count/*");
	foreach my $file(@files){
		open($rf, '<', "$file") or die "could not open \'$file\'\n";
		@array_of_lines = <$rf>;
		close $rf;
		$file =~ s/.*\///;
		mkdir "$repository/$branch/commit$count";
		open($rf, '>', "$repository/$branch/commit$count/$file") or die "could not open \'$repository/$branch/commit$count/$file\'\n";
		foreach my $line(@array_of_lines){
			print $rf "$line";
		}
		close $rf;
	}
	update_working_directory($branch_name);
}

sub check_if_merge_is_possible{
	my @current_branch_last_commit = @{$_[0]};
	my @merge_branch_last_commit = @{$_[1]};
	my $count2 = $_[2];
	my $count = $_[3];
	my $branch_name = $_[4];
	my $previous_commit2 = $_[5];
	my $previous_commit = $_[6];
	my %hash;
	my $check_flag = 0;
	my @failed_merge_files;
	if($count == $count2){
		return 1;
	}
	if(! defined $count){
		$count = 0;
	}
	if(! defined $count2){
		$count2 = 0;
	}
	if(! defined $previous_commit){
		$previous_commit = 0;
	}
	if(! defined $previous_commit2){
		$previous_commit2 = 0;
	}
	foreach my $file(@current_branch_last_commit){
		undef %hash;
		$file =~ s/.*\///;

		if((compare("$repository/$branch/commit$count2/$file", "$repository/$branch_name/commit$count/$file") == 0)){
			next;
		}
		if((compare("$repository/$branch/commit$count2/$file", "$repository/$branch_name/commit$count/$file") == 1) and 
			((!-e "$repository/$branch/commit$previous_commit2/$file") or (!-e "$repository/$branch_name/commit$previous_commit/$file"))){
			push @failed_merge_files, $file;
			next;
		}
		if("$file" eq "message.txt"){
			next;
		}

		if(! -e "$repository/$branch_name/commit$count/$file"){
			next;
		}
		if(-e "$repository/$branch_name/commit$count/$file"){
			open($rf, '<', "$repository/$branch_name/commit$count/$file") or die "could not open \'$repository/$branch_name/commit$count/$file\'\n";
			@array_of_lines = <$rf>;
			close $rf;
			open($rf, '<', "$repository/$branch/commit$count2/$file") or die "could not open \'$repository/$branch/commit$count2/$file\'\n";
			my @array_of_lines2 = <$rf>;
			close $rf;
			open($rf, '<', "$repository/$branch_name/commit$previous_commit/$file") or die "could not open \'$repository/$branch_name/commit$previous_commit/$file\'\n";
			my @previous_array_of_lines = <$rf>;
			close $rf;
			open($rf, '<', "$repository/$branch/commit$previous_commit2/$file") or die "could not open \'$repository/$branch/commit$previous_commit2/$file\'\n";
			my @previous_array_of_lines2 = <$rf>;
			close $rf;
			foreach my $line(@array_of_lines, @previous_array_of_lines, @array_of_lines2){
				if(grep(/^$line$/, @previous_array_of_lines) and grep(/^$line$/,@array_of_lines) and grep(/^$line$/, @array_of_lines2)){
					$hash{$line} = 2;
					next;
				}
				if(grep(/^$line$/, @previous_array_of_lines) and (! grep(/^$line$/,@array_of_lines)) and (! grep(/^$line$/,@array_of_lines2))){
					$hash{$line} = 0;
					next;
				}

				if(grep(/^$line$/, @previous_array_of_lines) and (! grep(/^$line$/,@array_of_lines)) and ( grep(/^$line$/,@array_of_lines2))){
					$hash{$line} = 1;
					next;
				}
				if(grep(/^$line$/, @previous_array_of_lines) and ( grep(/^$line$/,@array_of_lines)) and (! grep(/^$line$/,@array_of_lines2))){
					$hash{$line} = 1;
					next;
				}
				if(! grep(/^$line$/, @previous_array_of_lines) and (! grep(/^$line$/,@array_of_lines)) and ( grep(/^$line$/,@array_of_lines2))){
					$hash{$line} = 1;
					next;
				}
				if(! grep(/^$line$/, @previous_array_of_lines) and ( grep(/^$line$/,@array_of_lines)) and (! grep(/^$line$/,@array_of_lines2))){
					$hash{$line} = 1;
					next;
				}
				
			}
		}
		foreach my $key(sort keys %hash){
			if($hash{$key} == 0){
				push @failed_merge_files, $file;
			}
		}
	}
	@failed_merge_files = uniq(@failed_merge_files);
	if(@failed_merge_files > 0){
		$check_flag = 1;
		print "legit.pl: error: These files can not be merged:\n";
		@failed_merge_files = sort {$a cmp $b} @failed_merge_files;
		foreach my $failed_merge_file(@failed_merge_files){
			print "$failed_merge_file\n";
		}
	}
	return $check_flag;
}



sub perform_merge{
	my @current_branch_last_commit = @{$_[0]};
	my @merge_branch_last_commit = @{$_[1]};
	my $branch_name = $_[2];
	my $count = $_[3];
	my $count2 = $_[4];
	my $previous_commit2 = $_[5];
	my $previous_commit = $_[6];
	foreach my $file(@current_branch_last_commit){
		my $filetmp = $file;
		$filetmp =~ s/.*\///;
		if("$filetmp" eq "message.txt"){
			next;
		}
		if((compare("$index/$filetmp","$file") == 0) and (compare("$file", "$repository/$branch_name/commit$count2/$filetmp") == 0)){
			next;
		}
		if((! -e "$index/$filetmp") and ((compare("$file", "$repository/$branch_name/commit$count2/$filetmp") == 0)) or (! -e "$repository/$branch_name/commit$count2/$filetmp")){
			open($rf, '<', "$file");
			@array_of_lines = <$rf>;
			close $rf;
			open ($rf, '>', "$index/$filetmp");
			foreach my $line(@array_of_lines){
				print $rf "$line";
			}
			close $rf;
			next;
		}
		if((compare("$file", "$repository/$branch_name/commit$count2/$filetmp") == 1)){
			print "Auto-merging $filetmp\n";
			open($rf, '<', "$file") or die "could not open \'$file\'\n";
			@array_of_lines = <$rf>;
			close $rf;
			open($rf, '<', "$repository/$branch_name/commit$count2/$filetmp") or die "could not open \'$repository/$branch_name/commit$count2/$filetmp\'\n";
			my @array_of_lines2 = <$rf>;
			close $rf;
			open($rf, '<', "$repository/$branch/commit$previous_commit2/$filetmp") or die "could not open \'$repository/$branch/commit$previous_commit2/$filetmp\'\n";
			my @previous_array_of_lines = <$rf>;
			close $rf;
			open($rf, '<', "$repository/$branch_name/commit$previous_commit/$filetmp") or die "could not open \'$repository/$branch_name/commit$previous_commit/$filetmp\'\n";
			my @previous_array_of_lines2 = <$rf>;
			close $rf;
			open($rf, '>', "$index/$filetmp") or die "could not open \'$index/$filetmp\'\n";

			for(my $i = 0; $i < @array_of_lines; $i++){
				if($i > @array_of_lines2){
					print $rf "$array_of_lines[$i]";
					next;
				}
				if("$array_of_lines[$i]" eq "$array_of_lines2[$i]"){
					print $rf "$array_of_lines[$i]";
				}else{
					if("$array_of_lines[$i]" eq "$previous_array_of_lines[$i]"){
						print $rf "$array_of_lines2[$i]";
					}else{
						print $rf "$array_of_lines[$i]";
					}
				}
			}
			close $rf;
		}
	}

	foreach my $file(@merge_branch_last_commit){
		my $filetmp = $file;
		$filetmp =~ s/.*\///;
		if((compare("$index/$filetmp","$file") == 0) and (compare("$file", "$repository/$branch/commit$count/$filetmp") == 0)){
			next;
		}
		if((! -e "$index/$filetmp") and ((compare("$file", "$repository/$branch/commit$count/$filetmp") == 0)) or (! -e "$repository/$branch/commit$count/$filetmp")){
			open($rf, '<', "$file");
			@array_of_lines = <$rf>;
			close $rf;
			open ($rf, '>', "$index/$filetmp");
			foreach my $line(@array_of_lines){
				print $rf "$line";
			}
			close $rf;
			next;
		}
		if((compare("$file", "$repository/$branch/commit$count/$filetmp") == 1)){
			open($rf, '<', "$file");
			@array_of_lines = <$rf>;
			close $rf;
			open($rf, '<', "$repository/$branch_name/commit$count2/$filetmp");
			my @array_of_lines2 = <$rf>;
			close $rf;
			open($rf, '<', "$repository/$branch/commit$previous_commit2/$filetmp");
			my @previous_array_of_lines = <$rf>;
			close $rf;
			open($rf, '<', "$repository/$branch_name/commit$previous_commit/$filetmp");
			my @previous_array_of_lines2 = <$rf>;
			close $rf;
			open($rf, '>>', "$index/$filetmp");

			for(my $i = @array_of_lines2; $i < @array_of_lines; $i++){
				print $rf "$array_of_lines[$i]";
			}
			close $rf;
		}
	}
}


sub no_repository{
	print "legit.pl: error: no .legit directory containing legit repository exists\n";
	exit 1;
}

=sub debug{

			print "<============= FILES ===========>\n";
		print "$file -> $index/$file\n";
		print "$file -> $repository/$branch/commit$count/$file\n";
		print "$file -> $repository/$branch_name/commit$count2/$file\n";
		print "$file -> $repository/\.$branch_name/$file\n";
		print "$file -> $repository/\.$branch/$file\n";
		print "<============= FILES ===========>\n";
		my $flag = compare("$file","$index/$file");
		print "file with index = $flag\n";
		$flag = compare("$file","$repository/$branch/commit$count/$file");
		print "file with current branch last commit = $flag\n";
		$flag = compare("$file","$repository/$branch_name/commit$count2/$file");
		print "file with checkout branch last commit = $flag\n";
		$flag = compare("$file","$repository/\.$branch/$file");
		print "file with backup branch last commit = $flag\n";
		$flag = compare("$file","$repository/\.$branch_name/$file");
		print "file with merge backup branch last commit = $flag\n";
		
}
