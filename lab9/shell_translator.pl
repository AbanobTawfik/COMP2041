#!/usr/bin/perl -w
use strict;
use warnings;
#creating main subroutine
sub main{
	foreach my $file(@ARGV){
		&convert("$file");
	}
}

sub convert{
	my $file = $_[0];
	open(my $rf,'<',"$file") or die "cannot open $file\n";
	my @array_of_lines = <$rf>;
	close "$rf";
	my $perl_file = "$file";
	$perl_file =~ s/\..*//;
	$perl_file = "$perl_file.pl";
	open($rf, '>', "$perl_file") or die "cannot open $perl_file\n";
	my %hash;

	foreach my $line(@array_of_lines){
		if("$line" eq "do\n" or "$line" eq "do" or $line =~ /\s*do\n*$/){
			next;
		}
		if("$line" eq "done\n" or "$line" eq "done" or $line =~ /\s*done\n*$/){
			$line =~ s/(\s*)done\n*/$1/;
			print $rf "$line}\n";
			next;
		}
		if("$line" eq "fi\n" or "$line" eq "fi" or $line =~ /\s*fi\n*$/){
			$line =~ s/(\s*)fi\n*/$1/;
			print $rf "$line}\n";
			next;
		}
		if("$line" eq "then\n" or "$line" eq "then" or $line =~ /\s*then\n*$/){
			next;
		}
		if("$line" eq "else\n" or "$line" eq "else" or $line =~ /\s*else\n*$/){
			my $tmp = $line;
			$tmp =~ s/(\s*)else\n*/$1/;
			$line =~ s/\n//;
			print $rf "$tmp}\n$line\{\n";
			next;
		}
		#if line just a new line character replace
		if($line eq "\n"){
			print $rf "$line";
		}
		#case for hashbang replace with perl hashbang
		elsif($line eq "#!/bin/bash\n"){
			$line = "#!/bin/usr/perl -w\n";
			print $rf "$line";
		}
		#case for comment just print out comment
		elsif($line =~ /^#.*$/){
			print $rf "$line";
		}
		elsif($line =~ /\s*echo.*/){
			$line =~ s/echo /print "/;
			$line =~ s/$/";\n/;			
			print $rf "$line";
		}
		#case for while loop
		elsif($line =~ /^\s*while \(/ or $line =~ /^\s*if \(/){
			my @array = split/\s/, $line;
			foreach my $value(@array){
				if($value =~ /\w+/ and $value ne "while" and $value ne "if"){
					if($value =~ /^[(][(]\d+/){
						$value =~ s/\(\(/\(/;
						print $rf "$value ";
					}
					elsif($value =~/^\d+$/){
						print $rf "$value ";
					}
					elsif($value =~/\d+\)\)$/){
						$value =~ s/(\d+)\)\)/$1\)/;
						print $rf "$value";
					}
					elsif($value =~ /^[(][(]\w+/){
						$value =~ s/\(\(/\(\$/;
						print $rf "$value ";
					}
					elsif($value =~/\w+\)\)$/){
						$value =~ s/(\w+)\)\)/\$$1\)/;
						print $rf "$value";
					}
					elsif($value =~/\w+\)\)$/){
						$value =~ s/(\w+)\)\)/\$1\)/;
						print $rf "$value";
					}
					else{
						print $rf "\$$value ";
					}
				}else{
					print $rf "$value ";
				}
			}
			print $rf "{\n";
		}
		else{
			$line =~ s/\(//g;
			$line =~ s/\)//g;
			$line =~ s/=/ = /;
			my @array = split/\s/, $line;
			foreach my $value(@array){
				if($value =~/\d+/){
					$value =~ s/\$//;
					print $rf "$value ";
				}
				elsif($value =~ /\$\w+/){
					print $rf "$value ";
				}
				elsif($value =~ /\w+/){
					$value = "\$$value";
					print $rf "$value ";
				}
				else{
					print $rf "$value ";
				}
			}
			print $rf ";\n";
		}
	}
}
#calling main subroutine
main();	
