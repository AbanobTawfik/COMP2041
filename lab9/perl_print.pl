#!/usr/bin/perl -w
use strict;
use warnings;
#creating main subroutine
sub main{
	#want to split program arguements character/character to parse in special characters
	my @args = split//, $ARGV[0];
	#printing the hashbang for perl
	print "#!/usr/bin/perl -w\n";
	#now printing strict and warnings
	print "use strict;\n";
	print "use warnings;\n";
	#print out main sub-routine
	print "sub main{\n";
	#now we want to create our array of characters
	print "    my \@args;\n"; 
	#for all the words in our split program array of characters
	foreach my $word(@args){
		#if the character is a special character
		if($word eq '\'' or $word eq "\"" or $word eq '\\' or $word eq "\(" or $word eq "\)" or $word eq "\{" or $word eq "\}"){
			#we want to push it into the array with escape character
			print "    push \@args, \"\\$word\";\n";
		}else{
			#otherwise we just want to push into array as it is
			print "    push \@args, \"$word\";\n";
		}
	}
	print "\n";
	#now we want to print for each character int he array
	print "    foreach my \$word(\@args){\n";
	#print the character
	print "        print \"\$word\";\n";
	print "    }\n";
	#print a new line character at end
	print "    print \"\\n\";\n";
	print "}\n";
	#call main subroutine
	print "main();\n";

}
#calling main subroutine
main();
