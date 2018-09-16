#!/usr/bin/perl -w
use strict;
use warnings;
#creating main subroutine
sub main{
	my @args = split//, $ARGV[0];
	#printing the hashbang for perl
	print "#!/usr/bin/perl -w\n";
	#now printing strict and warnings
	print "use strict;\n";
	print "use warnings;\n";

	print "sub main{\n";
	print "    print \@ARGV;\n";
	print "    my \@args;\n"; 
	foreach my $word(@args){
		print "    if($word eq \'\"\' or $word eq \'\'\'){\n";
		print "        push \@args, \\$word;\n";
		print "    }else{\n";
		print "        push \@args, $word;\n";
		print "    }";
	}
	print "\n";
	print "    foreach my \$word(\@args){\n";
	print "        print \"\$word\";\n";
	print "    }\n";
	print "    print \"\\n\";\n";
	print "}\n";
	print "main();\n";

}
#calling main subroutine
main();
