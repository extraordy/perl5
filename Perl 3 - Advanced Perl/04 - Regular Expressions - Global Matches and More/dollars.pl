#!/usr/bin/perl
use strict;
use warnings;

# We may accept several files as command line arguments, but one is required  

scalar(@ARGV) or die "Usage: $0 <file> [<file>...]\n";

# We need a global variable for collecting figures from the input

my $total = 0;

# We start to read the lines of the file(s) into the default scalar

while ( <> )
{
   # We need to find and alter the monetary figures (the numbers followed by a 
   # decimal point and exactly two digits) and put a dollar sign in front 
   # of them if there isn't one there already. 
   
   # Since not all monetary figures include a decimal point originally, we can't
   # rely on any feasible capture to collect the figures during the substitution.
   # As we are working on the default scalar and we are not interested in the 
   # number of the global substitutions and their positions (neither in scalar, 
   # nor in list context), the statement remains simple and clear.      
   
   s/\$?(\d+\.\d{2})\b/\$$1/g;
   
   # With the substitution done, all our monetary figures start with the dollar 
   # sign. Some of them are whole numbers (dollar), but we might see figures
   # with fractions (cent) separated by a period. We use global matching in 
   # scalar context in a while loop to iterate through the input line to 
   # find and capture each component of a potential figure.  
   
   while (/\$(\d+)(\.\d+)?\b/g)
   {
   	# Here come the results of the captures after action - we don't really  
   	# need to store the results of the captures in variable, but the 
   	# talkative names can help to understand the role of the captures later.
   	# We use an elegant list assigenment to store the values in a single 
   	# step. 

   	my ( $dollar, $cent ) = ( $1, $2 );
   	
   	# Before we summarize the extracted values, we need to double check if
   	# any cent fraction is captured as we don't want to get warning of 
   	# using udefined values in the code.
   	
   	# Since the easiest way to make a single figure from the dollars and the 
   	# cents is the string concatenation, we want to let Perl know that we
   	# intend to use these string values in an arithmetic operation, so  
   	# adding zero (or multiplying by one) before the accumulation will do 
   	# the casting trick.
   	
   	$total +=  ( defined $cent ) ? ( 0 + ( $dollar.$cent )): ( 0 + $dollar );
   }
   
   # Now we can actually print our altered input line
   
   print;
}

# When we run out of input lines, we can finally print the collected total value.

printf "Total = \$%.2f\n", $total;

