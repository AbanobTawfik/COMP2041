#!/usr/bin/perl -w
use strict;
use warnings;
#creating main subroutine
sub main{
	#for all the files passed in we want to conver tthem to perl
	foreach my $file(@ARGV){
		&convert("$file");
	}
}

sub convert{
	#filename is what is passed into function arguement
	my $file = $_[0];
	#open file in read mode
	open(my $rf,'<',"$file") or die "cannot open $file\n";
	#store file into array
	my @array_of_lines = <$rf>;
	#close file
	close "$rf";
	#now we want to create a new file
	my $perl_file = "$file";
	#removing the .sh extension off new file
	$perl_file =~ s/\..*//;
	#now we want to create the new file with the .pl extension as perl file
	$perl_file = "$perl_file.pl";
	#open the perl file in write mode now
	open($rf, '>', "$perl_file") or die "cannot open $perl_file\n";
	foreach my $line(@array_of_lines){
		#if the line contains do (entrance to while loop) we want to skip as it is already handled
		if("$line" eq "do\n" or "$line" eq "do" or $line =~ /\s*do\n*$/){
			next;
		}
		#if the line contains done, we want to replace it with ending brace 
		if("$line" eq "done\n" or "$line" eq "done" or $line =~ /\s*done\n*$/){
			#this is taking spaces for consistent indenting
			$line =~ s/(\s*)done\n*/$1/;
			#print the indented brace with a new line
			print "$line}\n";
			next;
		}
		if("$line" eq "fi\n" or "$line" eq "fi" or $line =~ /\s*fi\n*$/){
			#this is taking spaces for consistent indenting
			$line =~ s/(\s*)fi\n*/$1/;
			#print the indented brace with a new line
			print "$line}\n";
			next;
		}
		#similair to above if the line contains "then" indicating entrance to if, we skip over as it is already handled
		if("$line" eq "then\n" or "$line" eq "then" or $line =~ /\s*then\n*$/){
			next;
		}
		#if the line contains else 
		if("$line" eq "else\n" or "$line" eq "else" or $line =~ /\s*else\n*$/){
			#create a temporary string to hold indentation of the else
			my $tmp = $line;
			#cut all except indenting
			$tmp =~ s/(\s*)else\n*/$1/;
			#now we want to remove the new line character from the else
			$line =~ s/\n//;
			#place the else indented with the brace and a new line at end
			print "$tmp}\n$line\{\n";
			next;
		}
		#if we have a new line character can simply print
		if($line eq "\n"){
			print "$line";
		}
		#case for hashbang replace with perl hashbang
		elsif($line eq "#!/bin/bash\n"){
			#pprint the perl -w hashbang instead
			$line = "#!/bin/usr/perl -w\n";
			print "$line";
		}
		#case for comment just print out comment since same style for perl and bash
		elsif($line =~ /^#.*$/){
			print "$line";
		}
		#if a line contains echo and things to echo
		elsif($line =~ /\s*echo.*/){
			#replace with print " \n";
			$line =~ s/echo /print "/;
			$line =~ s/$/\n";\n/;			
			print "$line";
		}
		#case for while loop and if statement (conditionals)
		elsif($line =~ /^\s*while \(/ or $line =~ /^\s*if \(/){
			#we want to split up the line with the delimiter of spaces
			my @array = split/\s/, $line;
			#for each word in the split line
			foreach my $value(@array){
				#if the word is a variable and not a keyword such as while and if
				if($value =~ /\w+/ and $value ne "while" and $value ne "if"){
					#if there are braces around digit
					if($value =~ /^[(][(]\d+/){
						#remove one of the braces and dont put $ symbol infront
						$value =~ s/\(\(/\(/;
						#print the variable
						print "$value ";
					}
					#if the value is just a digit with no sorrounding we want to just print it out as is
					elsif($value =~/^\d+$/){
						print "$value ";
					}
					#if the value is a digit at the end with sorrounding braces, we want to remove one of the final braces
					elsif($value =~/\d+\)\)$/){
						$value =~ s/(\d+)\)\)/$1\)/;
						#print the variable
						print "$value";
					}
					#if the value is now a variable at the start
					elsif($value =~ /^[(][(]\w+/){
						#remove one of the braces and add a $ to the variable name
						$value =~ s/\(\(/\(\$/;
						#print the new value
						print "$value ";
					}
					#if the value is now a variable at the end of the word 
					elsif($value =~/\w+\)\)$/){
						#want to remove one of the ending braces and still add the $ to variable
						$value =~ s/(\w+)\)\)/\$$1\)/;
						#print the new value
						print "$value";
					}
					#otherwise it is a variable
					else{
						#print the variable with the $ infront
						print "\$$value ";
					}
					#otherwise this is a symbol +/% etc.
				}else{
					#print them out as they are same in perl/bash
					print "$value ";
				}
			}
			#print the brace at the end of the while/if with new line 
			print "{\n";
		}
		#otherwise we are not on a special line (ignore fors) and we now want to deal with general equals/arithmetic
		else{
			#we want to remove braces as they aren't necessary in perl both ( and )
			$line =~ s/\(//g;
			$line =~ s/\)//g;
			#now we want to seperate our equal sign as in perl it is not required to bind the equal to the variable.
			$line =~ s/=/ = /;
			#now we want to split the line as shown above around the equals sign
			my @array = split/\s/, $line;
			#for each word in the now splti up line
			foreach my $value(@array){
				#if the word is a number
				if($value =~/\d+/){
					#we want to make sure to remove any $ from the $(( on some cases
					$value =~ s/\$//;
					#print the digit as is
					print "$value ";
				}
				#otherwise if it is a variable that has already got the $ infront, we want to print it as is
				elsif($value =~ /\$\w+/){
					print "$value ";
				}
				#otherwise if its a variable without the $ infront, we want to
				elsif($value =~ /\w+/){
					#insert the $ infront of the word
					$value = "\$$value";
					#print the new word with the $
					print "$value ";
				}
				#otherwise its a symbol and print it as is since similair in perl and bash
				else{
					print "$value ";
				}
			}
			#put a semi-colon at end of each line with new line character
			print ";\n";
		}
	}
}
#calling main subroutine
main();	
