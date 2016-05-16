#!/usr/local/bin/perl
use strict;
use warnings;

{
 our @array = qw(Max Headroom);
}

sub first
{
 print "I am in first()\n";
}

package old;

{
 package new;

 our $scalar = "Fred";
}

sub second
{
 print "I am in second()\n";
}

# Replace the following comments with one or more statements that perform what each comment says.
# The requirement here is to demonstrate that you can use multiple
# ways of accessing the package variables and subroutines wherever they exist.
# Do not alter any code above this line.

{
	print "1. "; 
	
	# Print @array by using 'package' and 'our'
	
	package main;
	print join(', ', our @array), "\n\t\@array was printed by using 'package' and 'our'.\n\n";
}

{
	print "2. "; 
	
	# Print @array by using an explicit package in the variable
	
	print join(', ', @main::array), "\n\t\@array was printed by using an explicit package.\n\n";
}

{
	print "3. ";
	
	# Call first() by using 'package'
	
	package main;
	first(); 
	print "\n\tfirst() was called by using 'package'.\n\n";
}

{
	print "4. "; 	
	
	# Call first() by using an explicit package in its name
	
	main::first();
	print "\n\tfirst() was called by using an explicit package.\n\n";
}
	
{
	print "5. "; 
	# Print $scalar by using 'package' and 'our'
	
	package new;
	print our $scalar, "\n\t\$scalar was printed by using 'package' and 'our'.\n\n";
}
	
{
	print "6. "; 
	
	# Print $scalar by using an explicit package in the variable
	
	print $new::scalar, "\n\t\$scalar was printed by using an explicit package.\n\n";
}

{
	print "7. ";
	
	# Call second() by using 'package'
	
	package old;
	second();
	print "\n\tsecond() was called by using 'package'.\n\n";
}
	
{

	print "8. ";
	
	# Call second() by using an explicit package in its name
	old::second();
	print "\n\tsecond() was called by using an explicit package.\n\n";
}	