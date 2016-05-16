#!/usr/bin/perl
use strict;
use warnings;

scalar(@ARGV) or die "Usage: $0 <file> [<file>]\n";

# We need a hash for a "month name - month number" dictionary.
# Using a little trick we keep it orderly.

my %months = qw( jan 1 feb 2 mar 3 apr 4 may 5 jun 6 jul 7 aug 8 sep 9 oct 10 nov 11 dec 12 );
 		   
while ( <> )
{
	chomp;
	
	# We are confident, that the input is ordinarily well-behaved,
	# still we'd better take care of potential extra white spaces,
	# it's safer to use character class shortcut, than literal spaces.
	
	# We will capture the month, day and year values with the regex
	#     month      day        year  
	#     -----   ---------    -------   
	#     |   |   |       |    |     |
	
	if ( /(\w+)\s+(\d{1,2}),\s+(\d{4})/i )
	{	    
	
	    # We need to double check the name of the month and convert 
	    # it to the number of the month before we print the result.  
	    
		
	    if ( exists $months{ lc substr( $1, 0, 3 ) } ) 
	    {
	       # All we have to do now is putting the captured values into 
	       # the required format and print them.
	       
	       printf "%4d-%02d-%02d\n", $3, $months{ lc substr( $1, 0, 3 ) }, $2;
	    } 
	}

}