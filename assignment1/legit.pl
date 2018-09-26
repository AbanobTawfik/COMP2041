#!/usr/bin/perl -w
use strict;
use warnings;
use File::Compare;
use File::Copy::Recursive qw(dircopy);
use List::MoreUtils qw(uniq);
use File::Path 'rmtree';
use File::Copy;
#global variable for .legit directory
my $repository = ".legit";
#global variable for default branch will be master
my $branch = "master";
#global variable for commit
my $commits = "commit";
#global file name is .legit/index is a top level directory to be same index accross all branches
my $index = "$repository/index";
#global variables to avoid my'ing them accross subroutines
my $rf;
my @array_of_lines;
#this is a flag to check whether the commit was made with merge, and to update current working directory if so 
#0 = no merge, 1 = merged commit
my $merge_allowed = 0;
sub main{
    #if there exists a current_branch.txt file in the .legit folder
    #(made after init is called), we want to set the current branch equal to the value in the text file
    if(-e "$repository/current_branch.txt"){
        #open the current_branch file in read mode
        open($rf, '<', "$repository/current_branch.txt");
        #store the file contents into array
        @array_of_lines = <$rf>;
        #close file handler
        close $rf;
        #update the branch to be the content of the file
        $branch = $array_of_lines[0];   
    }
    #if only 1 arguement is passed in
    if(@ARGV == 1){
        #if the arguement is init
        if($ARGV[0] eq "init"){
            #call subroutine init
            init();
            #exit success if returns successfully
            exit 0;
        }
        #if the arguement is log
        if($ARGV[0] eq "log"){
            #we want to call the log subroutine
            logg();
            #exit success if returns successfully
            exit 0;
        }
        #if the arguement is status
        if($ARGV[0] eq "status"){
            #we want to call the status subroutine
            status();
            #exit success if returns successfully
            exit 0;
        }
    }
    #if our first arguement is add (along with a list of files)
    if($ARGV[0] eq "add"){
        #we want to shift our arguements accross by 1 to remove the "Add" and only have the list of files
        shift @ARGV;
        #want to call the add subrotuine passing in our array as a subroutine arguement
        add(\@ARGV);
        exit 0;
    }
    #if our first arguement is comit (along with the flags and message)
    if($ARGV[0] eq "commit"){
        #we want to shift our arguements accross by 1 to remove the "commit"
        shift @ARGV;
        #call the sucroutine passing in our array as subroutine arguement
        commit(\@ARGV);
        exit 0;
    }
    #if our first arguement is show (along with the <no|"">:<file>)
    if($ARGV[0] eq "show"){
        #shift to remove the "show"
        shift @ARGV;
        #call the subrotuine passing in our array as subroutine arguement
        show(\@ARGV);
        exit 0;
    }
    #if our first arguement is rm (remove) along with a list of files and flags
    if($ARGV[0] eq "rm"){
        #we want to shift accross our program arguements to remove the rm
        shift @ARGV;
        #call the subroutine remove in our array as subroutine arguement
        rm(\@ARGV);
        exit 0;
    }
    #if our first arguement is branch along with the flags/branch name or just branch
    if($ARGV[0] eq "branch"){
        #shift accross our program arguement to remove the branch
        shift @ARGV;
        #call the subroutine branch with the array as program arguement
        branch(\@ARGV);
        exit 0;
    }
    #if our first arguement is "checkout" along with the branch name
    if($ARGV[0] eq "checkout"){
        #shift our program arguement to remove the checkout
        shift @ARGV;
        #call the subroutine checkout with the array as program arguement
        checkout(\@ARGV);
        exit 0;
    }
    #if our first arguement is merge along with the flags/message/branch
    if($ARGV[0] eq "merge"){
        #shift our program arguements to remove merge
        shift @ARGV;
        #call the merge subroutine with the array as program arguements
        merge(\@ARGV);
        exit 0;
    }
    #otherwise print usage which also exits with error code
    usage();
}
#calling main subroutine
main(); 
#this subroutine will print the monstrous usage for legit.pl properly formatted and exit with status 1
sub usage{
    print "legit.pl: error: unknown command $ARGV[0]\n";
    print "Usage: legit.pl <command> [<args>]\n\n";
    print "These are the legit commands:\n";
    print "   init       Create an empty legit repository\n";   
    print "   add        Add file contents to the index\n";
    print "   commit     Record changes to the repository\n";
    print "   log        Show commit log\n";
    print "   show       Show file at particular state\n";
    print "   rm         Remove files from the current directory and from the index\n";
    print "   status     Show the status of files in the current directory, index, and repository\n";
    print "   branch     list, create or delete a branch\n";
    print "   checkout   Switch branches or restore current directory files\n";
    print "   merge      Join two development histories together\n\n";
    exit 1;
}
#===================================================================================================================
#the init subroutine will create an initialised .legit folder that contains
#master branch as default when first called
#the current_branch.txt file which contains "master" that can be further updated
#the hidden master directory for checkout
#it will return if this has been previously called
sub init{
    #if the repository already exists
    if(-e "$repository"){
        #we print our error message 
        print "legit.pl: error: .legit already exists\n";
        #return from the subroutine
        return;
    }else{
        #otherwise
        #make the directory for ./legit and ./legit/master
        mkdir "$repository";
        mkdir "$repository/$branch";
        #open a blank text file in the top level directory called "current_branch,txt"
        open($rf, '>', "$repository/current_branch.txt");
        #print master initially as it will be our default branch on creation
        print $rf "master";
        #close the file handle
        close $rf;
        #we also want to make our hidden backup directory for master when checkout is called in future
        mkdir "$repository/\.$branch";
        #print the success message 
        print "Initialized empty legit repository in .legit\n";
        #return from the subroutine
        return;
    }
}   
#===================================================================================================================
#the add subroutine will first check if the .legit directory exists
#it will then if found .legit exist check if the index directory exists in the top level
#if the index directory is not existant, ti will create the new index directory 
#it will then add each file requested into the index
#it will also remove files that have been ./legit.pl rm'd <--cached> 
sub add{
    #if the repository does not exist we want to call the error subroutine no repository which prints an error message
    no_repository();
    #set the array of arguements to be that passed in to the subroutine
    my @arguements = @{$_[0]};
    #if the index does not exist
    if(! -e "$index"){
        #create the directory index which is .legit/index
        mkdir "$index";
    }
    #for each file passed into program arguement
    #create an array of files that are being added not deleted 
    foreach my $file(@arguements){
    	#if the file exists in the index
        if(-e "$index/$file"){
        	#and the file does not exist in directory (been removed with rm)
            if(!-e "$file"){
            	#this is an indication to remove the file from the index
                unlink "$index/$file";
                #remove the file from the array of arguements, using grep not matching all that equal the file in array
                @arguements = grep {$_ ne "$file"} @arguements;
                #go to next to avoid file error handle
                next;
            }      
        }
        #this also implies the file is not in the index/neither directory
        if(! -e "$file"){
            #so print the error message
            print "legit.pl: error: can not open '$file'\n";
            #exit with error status 1
            exit 1;
        }
    }
    #now we want to go through the updated arguements and add all files
    foreach my $file(@arguements){
        #if the file is ".legit" which occurs when ./legit.pl add * is called
        if("$file" eq ".legit"){
            next;
        }
        #otherwise open the file in read mode or exit status 1 with error message if can't be opened
        open($rf, '<', "$file") or die "./legit.pl: could not open $file\n";
        #store file contents into array
        @array_of_lines = <$rf>;
        #close file handle
        close $rf;
        #open the file creating in index in write mode or exit status 1 with error message if can't be opened
        open($rf, '>', "$index/$file") or die "./legit.pl: could not open $index/$file\n";
        #for each line in the array file contents
        foreach my $line(@array_of_lines){
            #print the line to the file
            print $rf "$line";
        }
        #close the file handler
        close $rf;
    }
}
#===================================================================================================================
#the commit subroutine will add all files currently in the index, into the next commit number directory
#it will check if there has been changes from the most recent commit and current index, if there are no changes
#we have nothing to commit
#if the commit is caused from a merge we will also update the current directory state
sub commit{
    #call the subroutine for checking if the repository exists
    no_repository();
    #retrieve the array passed into the subroutine
    my @arguements = @{$_[0]};
    my $commit_message;
    my $a_flag_on = 0;
    my $commit_changed_flag = 0;
    my $change_flag = 0;
    #if the arguements is more than 3 or less than 2, we want to print our usage error
    #we only allow 2-3 arguements [-a] [-m] [message]
    if(@arguements < 2 || @arguements > 3){
        commit_error();
    }
    #if the arguements is equal to three that means we can potentially have an -a flag
    if(@arguements == 3){
        #if neither arugement 1 or 2 is not the message flag that means not correct input, print usage
        if($arguements[0] ne "-m" and $arguements[1] ne "-m"){
            commit_error();
        }
        #if either arguement 1 or 2 is not the add flag that means extra incorrect input, print usage
        if($arguements[0] ne "-a" and $arguements[1] ne "-a"){
            commit_error();
        }
        #otherwise we imply -a flag is on
        $a_flag_on = 1;
        #set the message to be third arguement, we have format ./legit.pl commit [-m|-a] [-a|-m] <message>
        $commit_message = "$arguements[2]";
    }
    #if the arguements is 2 that means simple commit-message no add
    if(@arguements == 2){
        #if the -m message flag is not present, print usage message
        if($arguements[0] ne "-m"){
            commit_error();
        }
        #otherwise set the message to be what is passed in
        $commit_message = "$arguements[1]";
    }
    #if the a_flag was set
    if($a_flag_on == 1){
        #update all current files in index from the directory
        add_all_files_to_index();
    }
    #set the count for the current commit to be return result from the find_last_commit_number subroutine
    my $count = find_last_commit_number();
    #to find the last commit before the current commit we take 1 off the count since count will return commit numebr for the NEXT commit
    my $previous_commit_count = $count - 1;
    #get the array of files from the index using glob
    my @index_directory = glob("$index/*");
    #if there was a previous commit which only occurs if the count >= 0
    if($previous_commit_count >= 0){
        #get the array of files from the previous commit using glob
        my @previous_commit = glob("$repository/$branch/commit$previous_commit_count/*");
        #now we want to compare both directories
        foreach my $file(@previous_commit){
            #now we want to create a temporary file string 
            my $filetmp = $file;
            #trim all characters from path besides file name
            $filetmp =~ s/.*\///;
            #if the file is message.txt we want to skip
            if($filetmp eq "message.txt"){ 
                next;
            }
            #if the file does not exist in the index
            if(!-e "$index/$filetmp"){
                #set the change flag as on, and exit from the loop
                $change_flag = 1;
                last;
            }
            #if the two files in the commit and the index are not equal
            if(compare("$index/$filetmp","$repository/$branch/commit$previous_commit_count/$filetmp") != 0){
                #set change flag as on, and exit from the loop
                $change_flag = 1;
                last;
            }
        }
        #now we want to perform the same on the index 
        foreach my $file(@index_directory){
            my $filetmp = $file;
            $filetmp =~ s/.*\///;
            #if the files are not identical in the index and repository
            if(compare("$index/$filetmp","$repository/$branch/commit$previous_commit_count/$filetmp") != 0){
                #set change flag as on and exit the loop
                $change_flag = 1;
                last;
            }
            #if the file exists in the index, and does not exist in the previous commit
            if(! -e "$repository/$branch/commit$previous_commit_count/$filetmp"){
                #set the change flag as on and exit the loop
                $change_flag = 1;
                last;
            }
        }
    }else{
        #this else is because the if was that previous_commit >= 0, if there was no previous commit
        #that means there is a change in state
        $change_flag = 1;
    }
    #if the change flag was not changed (identical states)
    if($change_flag == 0){
        #print nothing to commit and return from the subroutine
        print "nothing to commit\n";
        return;
    }
    #if the previous check has gone through, we want to create a new directory for our commit with the next commit number
    mkdir "$repository/$branch/commit$count";
    #now we want to copy all files in the index to the commit directory
    #for each file in my index
    foreach my $file(@index_directory){
        #open the file in read mode (or exit with status 1 and print error message if that cannot be done)
        open($rf, '<', "$file") or die "./legit.pl: could not open $file\n";
        #store the file contents into an array
        @array_of_lines = <$rf>;
        #close the file handle
        close $rf;
        #now i want to remove all path specific text from the file name to extract just the file name itself
        $file =~ s/.*\///;
        #create the file inside the commit directory (or exit with status 1 and print error message if that cannot be done)
        open($rf, '>', "$repository/$branch/commit$count/$file") or die "./legit.pl: could not open $repository/$branch/commit$count/$file\n";
        #for each line in the array of contents
        foreach my $line (@array_of_lines){
            #print the line to the file 
            print $rf "$line";
        }
        #close the file handle afterwards
        close $rf;
    }
    #after all the files have been added to the commit
    #now i want to place a text file called commit_message.txt (consistent accross all commits)
    open($rf, '>', "$repository/$branch/commit$count/message.txt") or die "./legit.pl: could not open $repository/$branch/commit$count/message\n";
    #print the commit message to the file
    print $rf "$commit_message\n";
    #close the file
    close $rf;
    #save the current state of the directory with respect to the current branch
    save($branch);
    #print successfull commit with the commit number
    print "Committed as commit $count\n";
    #if this commit was a result of a merge
    if($merge_allowed == 1){
        #we want to update our current working directory from the index
        update_working_directory_from_index();
    }
}
#===================================================================================================================
#this subroutine will update all files in the current working directory
#to contain the same state as what is inside the index
#this subroutine is a result of a merge commit
sub update_working_directory_from_index{
    #get an array of index files using the glob command
    my @files = glob("$index/*");
    #for each file in the index files
    foreach my $file(@files){
        #we want to trim the path specific character into a temporary file name variable
        my $filetmp = $file;
        $filetmp =~ s/.*\///;
        #if the file is any of the unique no copy override files we want to ignore and go to the next file
        if("$filetmp" eq ".." or "$filetmp" eq "." or "$filetmp" eq "legit.pl" or "$filetmp" eq "message.txt"){
            next;
        }
        #if the file does not exist or it is different to the one in the index
        if(! -e "$filetmp" or compare("$file", "$filetmp") == 1){
            #we want to override the file from the index's version
            #open the file in read mode
            open($rf, '<', "$file");
            #store the file contents into an array
            @array_of_lines = <$rf>;
            #close the file handle
            close $rf;
            #now we want to open the directory version file in write mode (which will clear it initially or create)
            open($rf, '>', "$filetmp");
            #for each line in the file contents
            foreach my $line(@array_of_lines){
                #print the line to the file handler
                print $rf "$line";
            }
            #close the file handler
            close $rf;
        }
        #if the file is already identical to the one in the index we want to go to the next file
        if(compare("$file","$filetmp") == 0){
            next;
        }
    }
}
#===================================================================================================================
#this subroutine will update the files in the index to match the state of the current directory
#this subroutine will be called only if the -a flag is specified in the commit
sub add_all_files_to_index{
    #get the list of files from the current directory using <*>
    my @arguements = <*>;
    #if the index does not exist for some unbenknownst reason create the index directory to store the files in
    if(! -e "$index"){
        mkdir "$index";
    }
    #for each file in the current directory
    foreach my $file(@arguements){
        #if the file is a special file, we want to skip to the next file
        if("$file" eq ".." or "$file" eq "." or "$file" eq "legit.pl"){
            next;
        }
        #if the file is not present in the index, go to next (we aren't adding the entire directory)
        if(! -e "$index/$file"){
            next;
        }
        #open the file from the directory in read mode
        open($rf, '<', "$file") or die "./legit.pl: could not open $file\n";
        #store the file content into an array
        @array_of_lines = <$rf>;
        #close the file handler
        close $rf;
        #now open the file in the index in write mode which will clear the index's version
        open($rf, '>', "$index/$file") or die "./legit.pl: could not open $index/$file\n";
        #for each line in the file contents
        foreach my $line(@array_of_lines){
            #print the line to the file handle
            print $rf "$line";
        }
        #close the file handle
        close $rf;
    }
}
#===================================================================================================================
#this subroutine will print the usage message for commit if incorrect program arguements are passed through
#this will only be called if the arguements passed to commit are invalid
#the subroutine will also exit the program with error status
sub commit_error{
    print "usage: legit.pl commit [-a] -m commit-message\n";
    exit 1;
}
#===================================================================================================================
#this subroutine will find the most recent commit number accross all branches when creating a new commit
#it will return the next commit number to add
sub find_last_commit_number{
    #start the count at 0, as first commit should be 0 if no other exists
    my $count = 0;
    #create an array that contains all commit numbers accross all branches
    my @commit_numbers;
    #create an array of branches to scan through from the repository
    my @branches = glob("$repository/*");
    #scan through all branches one by one (all directories/files in the top level of .legit)
    foreach my $branch(@branches){
        #if the "branch" is the index, we want to skip
        if("$branch" eq "$repository/index"){
            next;
        }
        #otherwise we want to trim the path specific characters
        $branch =~ s/.*\///;
        #if the "branch" or file is called "current_branch.txt" we want to skip over
        if($branch eq "current_branch.txt"){
            next;
        }else{
            #otherwise we want to extract all directories within the branch
            my @commits = glob("$repository/$branch/*");
            #foreach commit directory in the branch
            foreach my $commit(@commits){
                #we want to trim the path specific names
                $commit =~ s/.*\///;
                #if the directory/file is called "index" we want to skip over to the next
                if("$commit" eq "index"){
                    next;
                }else{
                    #otherwise trim all characters from the commit leaving just the number
                    $commit =~ s/commit//;
                    #push that number into the array
                    push @commit_numbers, $commit;
                }
            }
        }
    }
    #now we want to sort the array in descending order
    @commit_numbers = sort{$b <=> $a} @commit_numbers;
    #if the size of the array is 0 that implies there are no commits we we jsut return 0 as first commit number
    if(@commit_numbers == 0){
        return 0;
    }else{
        #otherwise return the highest commit numebr + 1
        return $commit_numbers[0] + 1;
    }
}
#===================================================================================================================
#this subroutine will display all the commits with the message for the current branch in descending order
sub logg{
    #check if .legit directory exists
    no_repository();
    #now want to create an array that stores the commit number followed by the message 
    my @log_messages;
    #we want to get all the commits inside the current branch and store it into an array 
    my @commits = glob("$repository/$branch/commit*");
    #for each commit inside our commit array
    foreach my $commit(@commits){
        #open the message.txt file inside the commit
        open($rf, '<', "$commit/message.txt");
        #store the message content into an array
        @array_of_lines = <$rf>;
        #close the file handler
        close $rf;
        #we want to now get just the commit number
        $commit =~ s/.*commit//;
        #push the commit number + message to the array
        push @log_messages, "$commit @array_of_lines";
    }
    #now we want to sort (even though its alphabetically will sort it numerically since numbers are 0-9)
    @log_messages = sort {$b cmp $a} @log_messages;
    #for each line in the array of log messages (retreived above)
    foreach my $line(@log_messages){
        print "$line";
    }
}
#===================================================================================================================
#this subroutine will display the contents of a file in a certain commit
#or it will display the contents of a file in the index if no commit is specified
sub show{
    #check if the .legit repository exists
    no_repository();
    #gather the arguements from subroutine arguement 0
    my @arguements = @{$_[0]};
    #if the arguements is not equal to 1, we want to perform a show error
    if(@arguements != 1){
        show_error();
    }
    #we want to set the commit number to be the entire show arguement
    my $commit_number = $arguements[0];
    #trim the :* part from the arguement to have only a number
    $commit_number =~ s/:.*//;
    #now we want to set the file to be the entire show arguement
    my $show_file = $arguements[0];
    #trim the part .*: from the arguement to have only the file name
    $show_file =~ s/.*://;
    #if the commit number is not provided this implies we want the file state from the index
    if($commit_number eq ""){
        #if the file does not exist in the index we want to print the error message and exit with status 1
        if(!-e "$index/$show_file"){
            print "legit.pl: error: '$show_file' not found in index\n";
            exit 1;
        }
        #now open the file in read mode from the index
        open($rf, '<', "$index/$show_file") or die "./legit.pl: could not open $index/$show_file\n";
        #store the file contents into an array
        @array_of_lines = <$rf>;
        #close the file handler
        close $rf;
        #for each line in the file contents
        foreach my $line(@array_of_lines){
            #we want to print the line to standard output
            print "$line";
        }
        #return
        return;
    }else{
        #OTHERWISE WE WANT THE FILE FROM A CERTAIN COMMIT
        #if the commit does not exist in the branch
        #we want to print the error message and exit with error status
        if(! -e "$repository/$branch/commit$commit_number"){
            print "legit.pl: error: unknown commit '$commit_number'\n";
            exit 1;
        }
        #if the file does not exist within the commit specified
        #we want to print the error message and exit with error status
        if(!-e "$repository/$branch/commit$commit_number/$show_file"){
            print "legit.pl: error: '$show_file' not found in commit $commit_number\n";
            exit 1;
        }
        #open the file in read mode
        open($rf, '<', "$repository/$branch/commit$commit_number/$show_file") or die "./legit.pl: could not open $repository/$branch/commit$commit_number/$show_file\n";
        #store the file contents into an array
        @array_of_lines = <$rf>;
        #close the file handle
        close $rf;
        #now for each line in the file contents, we want to print the line
        foreach my $line(@array_of_lines){
            print "$line";
        }
    }
}
#===================================================================================================================
#this subroutine will print an error message for incorrect usage of show
#it will exit the program with error status
sub show_error{
    print "./legit.pl: usage: ./legit.pl [n]:'file'\n";
    exit 1;
}
#===================================================================================================================
#this subroutine will remove files from either, only the index or the index and directory
#to avoid accidently deleting unsaved work, there are checks in place to prevent unsafe deletion
#this can be overwritten using the --force flag
#rm alone will remove it from both the index and directory, if it has committed the work
#rm --cached will only remove the content from the index if the file is commited/saved in current directory
sub rm{
    #check if .legit repository exists
    no_repository();
    #retrieve our arguements from our subroutine arguements
    my @arguements = @{$_[0]};
    #we want to create flags and a counter for how many times we will shift our arguements
    my $cached_remove_flag = 0;
    my $force_remove_flag = 0;
    my $shift_counter = 0;
    #if the number of arguements is more than or equal to 2, and 
    #--cached is the first arguement
    if(@arguements >= 2 and $arguements[0] eq "--cached"){
        #increment the shift counter and turn the cached remove flag on
        $shift_counter++;
        $cached_remove_flag = 1;
    }
    #if the number of arguements is more than or equal to 2, and 
    #--force is the first arguement
    if(@arguements >= 2 and $arguements[0] eq "--force"){
        #increment the shift counter and turn the force remove flag on
        $shift_counter++;
        $force_remove_flag = 1;
    }
    #if the number of arguements is more than or equal to 2, and 
    #--cached is the second arguement
    if(@arguements >= 2 and $arguements[1] eq "--cached"){
        #increment the shift counter and turn the cached remove flag on
        $shift_counter++;
        $cached_remove_flag = 1;
    }
    #if the number of arguements is more than or equal to 2, and 
    #--force is the second arguement
    if(@arguements >= 2 and $arguements[1] eq "--force"){
        #increment the shift counter and turn the force remove flag on
        $shift_counter++;
        $force_remove_flag = 1;
    }
    #now we want to shift our arguements $shift_counter amount of times
    for(my $i = 0; $i < $shift_counter; $i++){
        shift @arguements;
    }
    #now we want to check the last commit made before we remove
    my $count = find_last_commit_number();
    #take 1 off that commit number to find the last commit made
    my $previous_commit_count = $count - 1;
    #if --cache remove is specified first
    if($cached_remove_flag == 1){
        #now we want to check for the existence of all files in the index
        foreach my $file(@arguements){
            #upon descovering a file doesn't exist in the index
            if(!-e "$index/$file"){
                #print the error message and exit with status 0
                print "legit.pl: error: '$file' is not in the legit repository\n";
                exit 1;
            }
        }
        #if the force remove flag is supplied we perform no checks
        if($force_remove_flag == 1){
            #for each file supplied remove it from the index and return
            foreach my $file(@arguements){
                unlink "$index/$file";
            }
            return;
        }
        #otherwise we want to check if the file has been committed
        #as a saftey measure
        foreach my $file(@arguements){
            #if the file has been committed or the file still exists in the directory
            #remove the file from the index and go to next
            if((compare("$index/$file","$repository/$branch/commit$previous_commit_count/$file") == 0)  or (compare("$file","$index/$file") == 0)){
                unlink "$index/$file";
                next;
            }
            #otherwise we want to print our reason for failure
            rm_errors($file,$previous_commit_count);
        }
    }else{
        #THIS IS THE CASE FOR REGULAR RM
        #first as above we want to check if the files exist in both the index and the current working directory
        #if not we print an error message and exit with error status
        foreach my $file(@arguements){
            if(!-e "$file"){
                print "./legit.pl: '$file' was not found in the index\n";
                exit 1;
            }
            if(! -e "$index/$file"){
                print "legit.pl: error: '$file' is not in the legit repository\n";
                exit 1;
            }
        }
        #if the force remove flag is on
        if($force_remove_flag == 1){
            #for each file supplied
            foreach my $file(@arguements){
                #remove the file from both the index and current working directory
                unlink "$index/$file";
                unlink "$file";
            }
            #return from the subrotuine
            return;
        }
        #otherwise for each file supplied
        foreach my $file(@arguements){
            #we want to compare both the file with the current commit and the current index 
            #if they are equivalent it means there is a commit of that work
            if(compare("$file","$repository/$branch/commit$previous_commit_count/$file") == 0 and compare("$file","$index/$file") == 0){
                #remove the files and go to the next
                unlink "$file";
                unlink "$index/$file";
                next;
            }
            #otherwise we want to print out reason of errors
            rm_errors($file,$previous_commit_count);
        }
    }
}
#===================================================================================================================
#this subroutine will take a file and then print the reason for why the file could not be removed
#this will be called when the file was not removed due to unsaved work not being committed
sub rm_errors{
    #get the file name from the subroutines first program arguement
    my $file = $_[0];
    #then get the previous commit number from the subroutines second arguement
    my $previous_commit_count = $_[1];
    #if the file is different to both index and the last commit version
    #print error message and go next;
    if(compare("$file","$repository/$branch/commit$previous_commit_count/$file") == 1 and compare("$file","$index/$file") == 1 and compare("$index/$file","$repository/$branch/commit$previous_commit_count/$file") == 1){
        print "legit.pl: error: '$file' in index is different to both working file and repository\n";
        return;
    }
    #if the file is different to the index
    #print error message and go next;
    if(compare("$file","$index/$file") == 1){
        print "legit.pl: error: '$file' in repository is different to working file\n";
        return;
    }
    #if the file is has not been committed and is in the index
    #print error message and go next;
    if(!-e "$repository/commit$previous_commit_count/$file" and -e "$index/$file"){
        print "legit.pl: error: '$file' has changes staged in the index\n";
        return;
    }
    #if the file is different to the last commit
    #print error message and go next;
    if(compare("$file","$repository/commit$previous_commit_count/$file") == 1){
        print "legit.pl: error: '$file' has changes staged in the index\n";
        return;
    }
}
#===================================================================================================================
#this subroutine will check the working directory, the last commit and the index and check the state
#of each file in the following
sub status{
    #check if the .legit repository exists
    no_repository();
    #now we want to create a hash of all files 
    my %file_hash;
    #we want to get the last commit number in the current branch to check the status in respect to the branch
    my $previous_commit_count = get_last_commit_number_in_branch($branch,0);
    #if the previous_commit_count has not been defined from our return
    #we want to print that no commits have been made and exit with error status
    if(!defined $previous_commit_count){
        print "legit.pl: error: your repository does not have any commits yet\n";
        exit 1;
    }
    #we want to now get all the files in the directory in the index using glob
    my @index_files = glob("$index/*");
    #we also want to get all the files in the commit directory using glob
    my @commit_files = glob("$repository/$branch/commit$previous_commit_count/*");
    #we finally want to get all the files in the current working directory
    my @directory_files = glob("*");
    #now we want to create an array of all unique files
    my @all_files;
    #for all the files in the commit/index/directory
    foreach my $file(@index_files, @commit_files, @directory_files){
        #we want to trim path specific characters and only get the file name
        $file =~ s/.*\///;;
        #store the file into the hash
        $file_hash{$file}++;
        #if the file has been not been seen before we want to add it to the all files array
        #and increment the counter by 1, this is to remove duplicates
        if($file_hash{$file} <= 1){
            push @all_files, $file;
            $file_hash{$file}++;
        }
    }
    #now we want to sort the array alphabetically
    @all_files = sort {$a cmp $b} @all_files;
    #for each file in the array of all files
    foreach my $file(@all_files){
        #we want to print the status message of each file
        status_message($file, $previous_commit_count);
    }
}
#===================================================================================================================
#this subroutine will take in a file as an arguement, and will compare the file to the current state
#index state and commit state to give the status of file as a return
sub status_message{
    #the file that is being processed is arguement 0
    my $file = $_[0];
    #the last commit number is arguement 1
    my $previous_commit_count = $_[1];
    #if the file is a . file or message.txt or any config files, we dont want to print the status of those files
    if("$file" eq ".." or "$file" eq "." or "$file" eq "message.txt" or "$file" eq "current_branch.txt"){
        #return from subroutine
        return;
    }
    #if the file is the exact same as what is inside the last commit, then it is the same as repository
    if(compare("$file","$repository/$branch/commit$previous_commit_count/$file") == 0){
        print "$file - same as repo\n";
    }
    #if the file is different to the index, and the index has the same content as the last commit, then we want to say that
    #the file is different changes staged for commit
    elsif(compare("$file", "$index/$file") == 1 and compare("$index/$file","$repository/$branch/commit$previous_commit_count/$file") == 1){
        print "$file - file changed, different changes staged for commit\n";
    }
    #if the file is the same as index, and the index is different to the last commit, then the file is changed, and is staged for commit
    elsif(compare("$file", "$index/$file") == 0 and compare("$index/$file","$repository/$branch/commit$previous_commit_count/$file") == 1){
        print "$file - file changed, changes staged for commit\n";
    }
    #if the file and index are different, and the index and last commit are the same that means the file is changed and the changes are
    #not staged for commit (need to be added)
    elsif(compare("$file","$index/$file") == 1 and compare("$index/$file","$repository/$branch/commit$previous_commit_count/$file") == 0){
        print "$file - file changed, changes not staged for commit\n";
    }
    #if the file doesnt exist however it is in the index and last commit with the same file content, then the file has just been removed
    elsif(!-e "$file" and compare("$index/$file", "$repository/$branch/commit$previous_commit_count/$file") == 0){
        print "$file - file deleted\n";
    }
    #if the file doesnt exists only in the last commit however not in the directory/index then print deleted
    elsif((! -e "$file") and (! -e "$index/file") and (-e "$repository/$branch/commit$previous_commit_count/$file")){
        print "$file - deleted\n";
    }
    #if the file is the same as the index and has not been commited, print added to index
    elsif(compare("$file", "$index/$file") == 0 and (! -e "$repository/$branch/commit$previous_commit_count/$file")){
        print "$file - added to index\n";
    }
    #otherwise if its not in the index, or last commit due to previous cases, and just exists, it is untracked
    elsif((-e "$file") and (! -e "$index/$file")){
        print "$file - untracked\n";
    }
}
#===================================================================================================================
#this subroutine will either create/delete a branch, or print all branches dependant on the input parsed in
#if no arguements are passed in, it will simply print all branches in the .legit repository
#if a branch name is specified that is non numeric only, it will create a branch by taking the current directory 
#state of the current branch and making a copy in the new branch
#if the -d flag is supplied that indicates to delete a branch assuming there is no unmerged work
sub branch{
    #first check if the .legit repository exists
    no_repository();
    #get the arguements from the subroutine 
    my @arguements = @{$_[0]};
    #these values below will vary depending on input
    my $delete_flag = 0;
    my $branch_name;
    #if mor ethan 2 arguements remain after branch is removed
    #print the usage message and exit with error status
    if(@arguements > 2){
        print "legit.pl: error: usage ./legit.pl -d [branch name]\n";
        exit 1;
    }
    if(@arguements == 1 and $arguements[0] eq "-d"){
        print "legit.pl: error: usage ./legit.pl -d [branch name]\n";
        exit 1;
    }
    #if the arguements is equal to 2 and the delete flag is the first arguement
    if(@arguements == 2 and $arguements[0] eq "-d"){
        #set the delete flag as on
        $delete_flag = 1;
        #set the branch name to delete as arguement 1
        $branch_name = $arguements[1];
    }
    #if there is only 1 arguement
    if(@arguements == 1){
        #set the branch name as that arguement (create branch)
        $branch_name = $arguements[0];
    }
    #if the delete flag is not on AND there are no commits in the current state
    #print the error message and exit with error status
    if(($delete_flag == 0) and (find_last_commit_number() == 0)){
        print "legit.pl: error: your repository does not have any commits yet\n";
        exit 1;
    }
    #if the arguements is equal to 1 (create branch) and there already is a branch with that name
    #print error message and exit
    if((@arguements == 1) and (-e "$repository/$branch_name")){
        print "legit.pl: error: branch '$branch_name' already exists\n";
        exit 1;
    }
    #if no arguements are supplied that means print all branches in the current repostiory
    if(@arguements == 0){
        #get all files in repository using glob
        my @branches = glob("$repository/*");
        #for each file in the repository
        foreach my $branch(@branches){
            #we want to trim the path file characters, keeping just branch name
            $branch =~ s/.*\///;
            #if the file is index or current_branch.txt we want to skip (config files)
            if($branch eq "current_branch.txt" or $branch eq "index"){
                next;
            }else{
                #otherwise print the branch name
                print "$branch\n";
            }
        }
        #return from subroutine
        return;
    }
    #if the delete flag is supplied
    if($delete_flag == 1){
        #if there is no branch with that name
        #print error message and exit with error status
        if(!-e "$repository/$branch_name"){
            print "legit.pl: error: branch \'$branch_name\' does not exist\n";
            exit 1;
        }
        #now we want the last commit in the current branch and the predecessor commit to that commit
        my $count = get_last_commit_number_in_branch($branch, 0);
        my $previous_commit = get_last_commit_number_in_branch($branch, 1);
        #we also want the last commit in the branch we are deleting, and its predecessor commit
        my $count2 = get_last_commit_number_in_branch($branch_name, 0);
        my $previous_commit2 = get_last_commit_number_in_branch($branch_name, 1);
        #now we now want to get both last commit directories in order to check if a merge CAN occur, to prevent
        #deleting a branch with unmerged changes
        my @current_branch_last_commit = glob("$repository/$branch/commit$count/*");
        my @merge_branch_last_commit = glob("$repository/$branch_name/commit$count2/*");
        #now we want to set the reutn of the check_if_merge_is_possible and store the return into variable check
        my $check = check_if_merge_is_possible(\@current_branch_last_commit, \@merge_branch_last_commit,$count,$count2,$branch_name,$previous_commit, $previous_commit2);
        #if check == 1 (merge can occur) we want to print an error message and exit with error status
        #to avoid deleting unmerged work
        if($check != 1){
            print "legit.pl: error: branch \'$branch_name\' has unmerged changes\n";
            exit 1;
        }
        #if the branch attempting to be deleted is the current branch
        #we want to print the error message and exit with error status
        if("$branch_name" eq "$branch"){
            print "legit.pl: error: can not delete branch \'$branch_name\'\n";
            exit 1;
        }
        #if the branch attempting to be deleted does not exist
        #we want to print the error message and exit with error status
        if(!-e "$repository/$branch_name"){
            print "legit.pl: error: branch \'$branch_name\' does not exist\n";
            exit 1;
        }else{
            #otherwise we want to remove the entire directory
            #and the backup directory associated with the branch, print the message and return
            rmtree(["$repository/$branch_name"]);
            rmtree(["$repository/\.$branch_name"]);
            print "Deleted branch \'$branch_name\'\n";
            return;
        }
    }else{
        #otherwise we are creating a branch
        #if the branch name supplied is not defined (dont think possible since just branch)
        #or if the branch is simply just numeric
        #print the error message and exit with error status
        if((!defined "$branch_name") or ("$branch_name" =~ /^[\d]+$/)){
            print "legit.pl: error: invalid branch name '$branch_name'";
            exit 1;
        }
        #otherwise we want to copy the current branch's state into the new branch's directory state
        #and we want to save into the backup branch directory the current state (important for checkout)
        dircopy("$repository/$branch", "$repository/$branch_name");
        mkdir "$repository/$branch_name";
        mkdir "$repository/\.$branch_name";
        save($branch_name);
        return;
    }
}
#===================================================================================================================
#this subroutine will save a given branch's current directory state into a hidden directory, in order to allow loading
#different directory states when checkout is called
sub save{
    #we want to get our banch name for the state we are saving from subroutine arguement 1
    my $branch_name = $_[0];
    #we want to now store current directory state into the backup file
    my @directory = <*>;
    #for each file in the directory
    foreach my $file(@directory){
        #if the file name is legit.pl we want to skip
        if("$file" eq "legit.pl"){
            next;
        }
        #otherwise
        #open the file in read mode
        open($rf, '<', "$file");
        #store the file content into an array
        @array_of_lines = <$rf>;
        #close the file handle
        close $rf;
        #now we want to open our file in our hidden directory in write mode
        open($rf, '>', "$repository/\.$branch_name/$file");
        #for each line in the file contents, we want to print the contents to the file handler 
        foreach my $line(@array_of_lines){
            print $rf "$line";
        }
        #close the file handle
        close $rf;
    }
}
#===================================================================================================================
#this subroutine will switch from the current branch to specified branch
#this will also update the current working directory to represent the state of the merge.
#if a checkout is made with no commit, the directory will maintain the original state
#only until there is a commit made in the branch will the states be different.
sub checkout{
    #check if the .legit repository exists
    no_repository();
    #get the arguements from the subroutine
    my @arguements = @{$_[0]};
    #if the arguements is not equal to 1 that means incorrect usage
    #print incorrect usage message and exit with error status
    if(@arguements != 1){
        print "legit.pl: usage: ./legit.pl checkout [branch_name]\n";
        exit 1;
    }
    #get the branch name as the arguement passed in
    my $branch_name = $arguements[0];
    #if the branch does not exist we want to print error message and exit with error status
    if(! -e "$repository/$branch_name"){
        print "legit.pl: error: unknown branch '$branch_name'\n";
        exit 1;
    }
    #if the branch requested is the current branch already we want to print the error message and exit with error status
    if("$branch" eq "$branch_name"){
        print "legit.pl: error: already on branch '$branch_name'\n";
    }else{
        #otherwise we want to get the last commit of the branches
        my $count = get_last_commit_number_in_branch($branch, 0);
        my $count2 = get_last_commit_number_in_branch($branch_name, 0);
        #and we want to check if we have files that will be over-ridden from the checkout
        check_override($branch_name, $count, $count2);
        #now we want to add all new files from the current branch into the backup branch folder
        add_new_files();
        #if the two branches have different commit numbers (differing commits)
        if($count != $count2){
            #we want to update the working directory to reflect
            #the state of the maintained branch backup directory
            update_working_directory($branch_name);
        }
        #finally we want to open the current_branch.txt file
        open($rf, '>', "$repository/current_branch.txt");
        #print the new brnach we are checking out to the file
        print $rf "$branch_name";
        #close the file handle
        close $rf;
        #print success message that we switch to the branch
        print "Switched to branch '$branch_name'\n";
    }
}
#===================================================================================================================
#this subroutine will check if the attempted checkout will over-ride and lose unsaved work within the directory
#it will make sure that the version of the file in the directory exists within the repository if over-riding
#else it will exit with error status and print all conflict files
sub check_override{
    #set the branch name to be the first arguement
    my $branch_name = $_[0];
    #set the branch commit count to be the next two arguements
    my $count = $_[1];
    my $count2 = $_[2];
    #now we want to store our current directory files into an array
    my @directory = <*>;
    #and create a blank array for storing unsaved work
    my @unsaved_work;
    #if the two commits are the same number, implies that the state is the same, and just return
    if($count == $count2){
        return;
    }
    #for each file in the working directory
    foreach my $file(@directory){
        #if the file is legit.pl or the diary or is a special file we want to ignore and go next
        if("$file" eq ".." or "$file" eq "." or "$file" eq "legit.pl" or "$file" eq "diary.txt"){
            next;
        }
        #now we want to compare the file with the index, and the contents of the commits for both branch
        #if this file is not found anywhere, we want to push it as unsaved work
        if((compare("$file","$index/$file") != 0) and (compare("$file","repository/$branch/commit$count/$file")!= 0) and (compare("$file","$repository/$branch_name/commit$count2/$file") != 0)
            and (compare("$file", "$repository/\.$branch/$file") != 0) and (compare("$file", "$repository/\.$branch_name/$file") != 0)){
            push @unsaved_work, $file;
        }
    }
    #if there are any files in the unsaved work array
    if(@unsaved_work >= 1){
        #print the error message, along with all files that match the error and exit with error status
        print "legit.pl: error: Your changes to the following files would be overwritten by checkout:\n";
        foreach my $file(@unsaved_work){
            print "$file\n";
        }
        exit 1;
    }
}
#===================================================================================================================
#this subroutine will add new files created in the branch before checking out to the new branch
#into the backup directory to maintain state
sub add_new_files{
    #first we want to get all files in the current directory into an array
    my @directory = <*>;
    #for every file in the directory
    foreach my $file(@directory){
        #we check if its a file that contains "," or its legit.pl
        if("$file" eq ".." or "$file" eq "." or "$file" eq "legit.pl"){
            next;
        }
        #if the file does not exist in our backup directory
        if(! -e "$repository/\.$branch/$file"){
            #we want to open the file in read mode
            open($rf, '<', "$file");
            #store the file contents into an array
            @array_of_lines = <$rf>;
            #close the file handle
            close $rf;
            #now we want to create the file in our backup directory
            open($rf, '>', "$repository/\.$branch/$file");
            #for each line in the file contents
            foreach my $line(@array_of_lines){
                #print the line to the file handle
                print $rf "$line";
            }
            #close the file handle
            close $rf;          
        }
    }
}
#===================================================================================================================
#this subroutine will update the current working directory from the backup directory in the specified branch
#this will be used to maintain directory states when we checkout to different branches
sub update_working_directory{
    #we want to set our branch name to be the subroutine arguement
    my $branch_name = $_[0];
    #we want to now store all the files in the directory into an array
    my @directory = <*>;
    #we also want to get all the files inside our backup directory into an array using glob
    my @branch_save = glob("$repository/\.$branch_name/*");
    #now we want to clear the current directory except for legit.pl
    foreach my $file(@directory){
        #if file is legit.pl we dont want to remove
        if($file eq "legit.pl"){
            next;
        }else{
            #othweise remove the file from the current working directory
            unlink "$file";
        }
    }
    #now for each file in the branch's backup directory
    foreach my $file(@branch_save){
        #we want to open the file in read mode
        open($rf, '<', "$file");
        #store the file contents into an array
        @array_of_lines = <$rf>;
        #now we want to close the file handle
        close $rf;
        #we also want to remove all path specific characters to open it in the current directory
        $file =~ s/.*\///;
        #now we open the file in write mode 
        open($rf, '>', "$file");
        #for each line in the file contents
        foreach my $line(@array_of_lines){
            #we want to print the line to the file 
            print $rf "$line";
        }
        #close file handle
        close $rf;
    }
}
#===================================================================================================================
#this subroutine will attempt (working mostly some minor bugs) to merge the most recent commits of 2 branches into a new
#commit created in the current branch. it will first check if the commit is possible by comparing through a hash
#the two commits with a common ancestor commit between the two
#if there are conflicting changes we print our error message and say the merge could not occur
#otherwise we will ATTEMPT to merge the files together by taking the changes and appending added/ removing removed data
#after we create a new commit from the merge we also want to update the current directory state to reflect the merge
#based off index
#if the attempted merge branch has a high commit number than the current branch this is a case of fast-forward
#where we will include the changes however we will not create a commit, we will simply just takes all the changes and add them
#to the current branch
#all extra commits created will also be added to the current branch if they do not exist 
sub merge{
    #check if the .legit repository exists
    no_repository();
    #now we want our merge arguements to be the array passed into the subroutine
    my @arguements = @{$_[0]};
    #if the number of arguements are not 3, and  the commit is at the end of the arguements or the commit message is empty
    #we want to output empty commit error exit with error status;
    if(@arguements != 3 and ($arguements[0] ne "-m" or $arguements[1] ne "-m")){
        print "legit.pl: error: empty commit message\n";
        exit 1;
    }
    #if the -m message flag is at the end, we want to print our usage error and exit with error status
    if($arguements[2] eq "-m"){
        print "usage: legit.pl merge <branch|commit> -m message\n";
        exit 1;
    }
    #now we want to declare our branch name we are merging with and the message we are adding to the new commit
    my $commit_message;
    my $branch_name;
    #if the first arguement is -m that means the message is infront so second arguement and the target branch is third arguement
    if($arguements[0] eq "-m"){
        $commit_message = $arguements[1];
        $branch_name = $arguements[2];
    }
    #if the second arguement is -m that means the message is infront so third arguement and the target branch is the first arguement
    if($arguements[1] eq "-m"){
        $branch_name = $arguements[0];
        $commit_message = $arguements[2];
    }
    #if our commit message is not defined we want to print error message of "empty commit" and exit with error status
    if(! defined $commit_message){
        print "legit.pl: error: empty commit message\n";
        exit 1;
    }
    #if the branch we are attempting to merge with does not exist, we want to print error message and exit with error status
    if(! -e "$repository/$branch_name"){
        print "legit.pl: error: unknown branch '$branch_name'\n";
        exit 1;
    }
    #now we want the commit number for the last and 2nd last commit in both branches
    my $count = get_last_commit_number_in_branch($branch, 0);
    my $previous_commit = get_last_commit_number_in_branch($branch, 1);
    my $count2 = get_last_commit_number_in_branch($branch_name, 0);
    my $previous_commit2 = get_last_commit_number_in_branch($branch_name,1);
    #if the commit number in the merge branch is HIGHER than the commit number in current branch
    #we want to perform a fast forward and not create a commit
    if((!defined $count2) or ($count2 > $count)){
        fast_forward($branch_name, $count2);
        print "Fast-forward: no commit created\n";
        exit 1;
    }
    #if the two commits are equivalent or we are merging with current branch
    #we want to print our message that it is up to date and exit with error status
    if(($count2 == $count) or ("$branch_name" eq "$branch")){
        print "Already up to date\n";
        exit 1;
    }
    #now we want to get all the files in both the current branch's last commit and the target merge branch's last commit
    #using the glob command
    my @current_branch_last_commit = glob("$repository/$branch/commit$count/*");
    my @merge_branch_last_commit = glob("$repository/$branch_name/commit$count2/*");
    #before we merge first we check if the merge is possible by checking conflicts
    my $check = check_if_merge_is_possible(\@current_branch_last_commit, \@merge_branch_last_commit,$count,$count2,$branch_name,$previous_commit, $previous_commit2);
    #if the merge is not possible we want to exit with error status
    if($check == 1){
        exit 1;
    }
    #otherwise we want to perform the merge
    perform_merge(\@current_branch_last_commit, \@merge_branch_last_commit, $branch_name,$count,$count2,$previous_commit, $previous_commit2);
    #create our arguements for our new commit
    my @commit_arguements;
    $commit_arguements[0] = "-m";
    $commit_arguements[1] = "$commit_message";
    #set the flag merge allowed to notify we update our current directory afterwards
    $merge_allowed = 1;
    #and we call commit to create our new commit
    commit(\@commit_arguements);
    #we also want to add all extra commits created in the branch into our current branch
    add_all_extra_commits($branch_name);

}
#===================================================================================================================
#this subroutine will add all the non-existant commits from a target branch into the current branch 
#it will check for existance and if the commit doens''t exist it will add it to the current branch
sub add_all_extra_commits{
    #get the target branch name from subroutine arguements
    my $branch_name = $_[0];
    #now we want all the commit directories within that merge
    my @merge_branch_directory = glob("$repository/$branch_name/*");
    #for each commit in the target branch
    foreach my $commit(@merge_branch_directory){
        #we want to trim the extra path specific characters
        $commit =~ s/.*\///;
        #if the commit doesn't exist within our current brnach
        if(!-e "$repository/$branch/$commit"){
            #we want to copy the commit directory into our current branch
            dircopy("$repository/$branch_name/$commit", "$repository/$branch/$commit");
        }
    }
}
#===================================================================================================================
#this subroutine will perform a fast forward, by adding the files from the most recent commit in the target branch
#into the current branchs most recent commit
sub fast_forward{
    #first we get our banch name and recent commit for the branch name from subroutine arguements
    my $branch_name = $_[0];
    my $count = $_[1];
    #now we want to get all the files inside the target branch's last commit
    my @files = glob("$repository/$branch_name/commit$count/*");
    #for each file in the branch's last commit
    #we make the commit inside our current branch
    mkdir "$repository/$branch/commit$count";
    foreach my $file(@files){
        #we want to open the file
        open($rf, '<', "$file") or die "could not open '$file'\n";
        #store the file contents into an array
        @array_of_lines = <$rf>;
        #close the file handle
        close $rf;
        #then we want to trim the extra path specific characters from the file
        $file =~ s/.*\///;
        #now we want to open the file in our newly made directory in the current branch
        open($rf, '>', "$repository/$branch/commit$count/$file") or die "could not open '$repository/$branch/commit$count/$file'\n";
        #for each line in the files content
        foreach my $line(@array_of_lines){
            #we want to print the line to the fille
            print $rf "$line";
        }
        #close file handler
        close $rf;
    }
    #we also at the end of fast-forward want to update our current working directory to be that of the target merge branch
    update_working_directory($branch_name);
}
#===================================================================================================================
#this subroutine will check if a merge is possible by comparing the two current commits with a common ancestor
#it will use a hash that will compare the differences in the files line by line and will make sure there is still 
#resemblance to the common ancestor i.e there is still 1 side of file that holds no change so no conflicting changes!
sub check_if_merge_is_possible{
    #we want to retrieve all our paramaters passed in from our subroutine arguements including
    #the current branch's commit, the target merge branch's commit and the commit numbers and the branch names
    my @current_branch_last_commit = @{$_[0]};
    my @merge_branch_last_commit = @{$_[1]};
    my $count2 = $_[2];
    my $count = $_[3];
    my $branch_name = $_[4];
    my $previous_commit2 = $_[5];
    my $previous_commit = $_[6];
    my $check_flag = 0;
    my @failed_merge_files;
    #we want to create a hash for each file see below why but it will let us check if the file maintains
    #one side changes
    my %hash;
    #if the two branches have the same last commit, we want to return 1 (1 meaning failure here)
    if($count == $count2){
        return 1;
    }
    #if any of the counts have not been defined (or created)
    #we want to set them to initial first commit value 0
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
    #now for each file in the current branch's last commit
    foreach my $file(@current_branch_last_commit){
        #we want to trim all path specific characters
        $file =~ s/.*\///;
        #if the files are requivalent across both commits, we want to just go to next
        if((compare("$repository/$branch/commit$count2/$file", "$repository/$branch_name/commit$count/$file") == 0)){
            next;
        }
        #if the file is different between both commits and the file does not exist in both ancestor's ancestor commit
        #we want to push the file into the failed merges, and go to next
        if((compare("$repository/$branch/commit$count2/$file", "$repository/$branch_name/commit$count/$file") == 1) and 
            ((!-e "$repository/$branch/commit$previous_commit2/$file") or (!-e "$repository/$branch_name/commit$previous_commit/$file"))){
            push @failed_merge_files, $file;
            next;
        }
        #if the file is message.txt we want to go to next file we do not handle commit messages
        if("$file" eq "message.txt"){
            next;
        }
        #if the file does not exist in the other commit, we want to go next, since we just push new files in anyways
        if(! -e "$repository/$branch_name/commit$count/$file"){
            next;
        }
        #if the file exists in the other branch (and not equivalent implied from above)
        if(-e "$repository/$branch_name/commit$count/$file"){
            #we want to open each file in each different commit in read mode and store their values in array
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
            #now we want to create our hash which will check file states and create hash based on the state
            %hash = file_hash_for_merge(\@array_of_lines, \@array_of_lines2, \@previous_array_of_lines);
        }
        #for each key in the has, if any of the value is 0, it means that
        #there are two different changes, (no resemblance to original ancestor in both)
        #then we push to the failed merge files
        foreach my $key(sort keys %hash){
            if($hash{$key} == 0){
                push @failed_merge_files, $file;
            }
        }
    }
    #now we want to remove duplicate files from the array using the uniq command
    @failed_merge_files = uniq(@failed_merge_files);
    #if there are any failed merges
    if(@failed_merge_files > 0){
        #we want to set our return to be 1
        $check_flag = 1;
        #we want to now print our error message 
        print "legit.pl: error: These files can not be merged:\n";
        #sort the files alphabetically
        @failed_merge_files = sort {$a cmp $b} @failed_merge_files;
        #print all files in the array of failed_merge files
        foreach my $failed_merge_file(@failed_merge_files){
            print "$failed_merge_file\n";
        }
    }
    #return the check flag (1 = failure, 0 = success)
    return $check_flag;
}
#===================================================================================================================
#this subroutine will perform the merge of files between two commits
#it will add new files that are not common between
#or it will auto-merge files that have conflicts that can be automerged
#automerge will push the changes from the changed file, or append new lines, or remove lines from the changes
#this works in most cases however it will not work as i could not figure out how to make diff work, and diff is the
#optimal way to implement changes
sub perform_merge{
    #we want to retrieve all our paramaters passed in from our subroutine arguements including
    #the current branch's commit, the target merge branch's commit and the commit numbers and the branch names
    my @current_branch_last_commit = @{$_[0]};
    my @merge_branch_last_commit = @{$_[1]};
    my $branch_name = $_[2];
    my $count = $_[3];
    my $count2 = $_[4];
    my $previous_commit2 = $_[5];
    my $previous_commit = $_[6];
    my %merged_files;

    foreach my $file(@current_branch_last_commit, @merge_branch_last_commit){
        my $filetmp = $file;
        $filetmp =~ s/.*\///;
        $merged_files{$filetmp} = 1;
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
            open($rf, '<', "$file");
            @array_of_lines = <$rf>;
            close $rf;
            open($rf, '<', "$repository/$branch_name/commit$count2/$filetmp");
            my @array_of_lines2 = <$rf>;
            close $rf;
            open($rf, '<', "$repository/$branch/commit$previous_commit2/$filetmp");
            my @previous_array_of_lines = <$rf>;
            close $rf;
            open($rf, '>', "$index/$filetmp");
            my @number_of_lines;
            my $ancestor_lines = @previous_array_of_lines;
            my $current_lines = @array_of_lines;
            my $merge_lines = @array_of_lines2;
            push @number_of_lines, $ancestor_lines,$current_lines,$merge_lines;
            @number_of_lines = sort{$b <=> $a} @number_of_lines;
            my $max_lines = $number_of_lines[0];
            my %hash = file_hash_for_merge(\@array_of_lines, \@array_of_lines2, \@previous_array_of_lines);
            for(my $i = 0; $i < $max_lines; $i++){
                #print "$i --> $previous_array_of_lines[$i] + $array_of_lines[$i] + $array_of_lines2[$i]\n";
                if($i > @array_of_lines and $i > @array_of_lines2){
                    last;
                }

                if((!defined $previous_array_of_lines[$i]) and ($hash{$array_of_lines[$i]} == 2) and ($hash{$array_of_lines2[$i]}) == 1){
                    print $rf "$array_of_lines[$i]";
                    print $rf "$array_of_lines2[$i]";
                    next;
                }
                if((!defined $previous_array_of_lines[$i]) and ($hash{$array_of_lines[$i]} == 1) and ($hash{$array_of_lines2[$i]}) == 2){
                    print $rf "$array_of_lines2[$i]";
                    print $rf "$array_of_lines[$i]";
                    next;
                }
                if((!defined $previous_array_of_lines[$i]) and $i > @array_of_lines2){
                    print $rf "$array_of_lines[$i]";
                    next;
                }
                if((!defined $previous_array_of_lines[$i]) and $i > @array_of_lines){
                    print $rf "$array_of_lines2[$i]";
                    next;
                }
                if((!defined $previous_array_of_lines[$i]) and ("$array_of_lines[$i]" eq "$array_of_lines2[$i]")){
                    print $rf "$array_of_lines[$i]";
                    next;
                }
                if(!defined $array_of_lines2[$i] and defined $array_of_lines[$i]){
                    print $rf "$array_of_lines[$i]";
                }
                if(defined $array_of_lines2[$i] and !defined $array_of_lines[$i]){
                    print $rf "$array_of_lines2[$i]";
                }
                if(!defined $array_of_lines[$i] or !defined $array_of_lines2[$i] or !defined $previous_array_of_lines[$i]){
                    last;
                }
                if(("$previous_array_of_lines[$i]" eq "$array_of_lines[$i]") and ("$array_of_lines[$i]" eq "$array_of_lines2[$i]")){
                    print $rf "$array_of_lines[$i]";
                    next;
                }
                if(("$previous_array_of_lines[$i]" eq "$array_of_lines[$i]") and ("$array_of_lines[$i]" ne "$array_of_lines2[$i]")){
                    print $rf "$array_of_lines2[$i]";
                    next;
                }
                if(("$previous_array_of_lines[$i]" eq "$array_of_lines2[$i]") and ("$array_of_lines[$i]" ne "$array_of_lines2[$i]")){
                    print $rf "$array_of_lines[$i]";
                    next;
                }
            }
            close $rf;
        }
    }
}

sub file_hash_for_merge{
    my %hash;
    my @array_of_lines = @{$_[0]};
    my @array_of_lines2 = @{$_[1]};
    my @previous_array_of_lines = @{$_[2]};
    if(@array_of_lines > @previous_array_of_lines and @array_of_lines2 > @previous_array_of_lines){
        for(my $i = @previous_array_of_lines; $i < @array_of_lines; $i++){
            if($i > @array_of_lines2){
                last;
            }
            if($array_of_lines[$i] eq $array_of_lines2[$i]){
                $hash{$array_of_lines[$i]} = 2;
            }
            if($array_of_lines[$i] ne $array_of_lines2[$i]){
                $hash{$array_of_lines[$i]} = 0;
            }
        }
    }

    if(@array_of_lines > @previous_array_of_lines and @array_of_lines2 > @previous_array_of_lines){
        for(my $i = @previous_array_of_lines; $i < @array_of_lines2; $i++){
            if($i > @array_of_lines){
                last;
            }
            if($array_of_lines[$i] eq $array_of_lines2[$i]){
                $hash{$array_of_lines[$i]} = 2;
            }
            if($array_of_lines[$i] ne $array_of_lines2[$i]){
                $hash{$array_of_lines[$i]} = 0;
            }
        }
    }

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
    return %hash;
}
#===================================================================================================================
#this subroutine will get the latest commit number inside the current branch
#this will be done by adding the number of the commit into an array
#sorting the array, and taking the largest value
#if there is no commit we will get undefined
sub get_last_commit_number_in_branch{
    #we want the target branch in which we want the commit number from and the 
    #position aka (position'dth highest) number in the array from the subroutine arguements
    my $target_branch = $_[0];
    my $position = $_[1];
    #now we want to get all the commit directories using glob command
    my @commits = glob("$repository/$target_branch/commit*");
    #and we want to create a new array of commit numbers to add to
    my @commit_numbers_current_branch;
    #for each commit in the current branch
    foreach my $commit(@commits){
        #we want to remove the path specific characters and the commit
        $commit =~ s/.*commit//;
        #push the commit number into the array of commit_numbers
        push @commit_numbers_current_branch, "$commit";
    }
    #sort the array of commit numebrs
    @commit_numbers_current_branch = sort {$b cmp $a} @commit_numbers_current_branch;
    #now we return the infex specified from input of the sorted array
    return $commit_numbers_current_branch[$position];
}
#this subroutine will be used as an error check to see if the .legit directory exists before calling
#commands other than ./legit.pl init
#if it doesnt it wille exit the program with error status and print an error message
#else it will simply return
sub no_repository{
    #if the .legit repository does not exist and a command is caleld other than init
    if(! -e  "$repository"){
        #print error message and exit with status 1 
        print "legit.pl: error: no .legit directory containing legit repository exists\n";
        exit 1;
    }else{
        #otherwise return from subroutine
        return;
    }
}
