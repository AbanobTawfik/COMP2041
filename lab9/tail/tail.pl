#!/usr/bin/perl -w

my $max_lines = 10;

# See if the number of lines are specified
if (@ARGV > 0 && $ARGV[0] =~ /^-{1}[0-9]*$/) {
    $max_lines = $ARGV[0];
    $max_lines =~ s/-//g;
    shift @ARGV;
}

# If there are no files to print, just print standard input
if (@ARGV == 0) {
    my @lines = <>;
    my $first = @lines - $max_lines;
    $first = 0 if $first < 0;
    print @lines[$first..(@lines-1)];
} else {
    my $show_file_names = @ARGV > 1;
    foreach my $file (@ARGV) {
        open(my $f, '<', $file) or die "$file: can't open $file\n";
        print "==> $file <==\n" if $show_file_names;
        my @lines = <$f>;
        my $first = @lines - $max_lines;
        $first = 0 if $first < 0;
        print @lines[$first..(@lines-1)];
        close $f;
    }
}
