#!/usr/bin/perl
use strict;
use warnings;

# The return value of the localtime() function is
# a string in SCALAR context

my $local_time = substr( localtime(), 0, 16 );	

# Since we generated the result into a scalar,
# we don't really need any fancy formatted print here

print "\nCurrent date and time: ", $local_time, "\n\n"; 

foreach my $ord ( 32..126 )
{
	printf "%03d %02x %04o %08b %1c\n", $ord, $ord, $ord, $ord, $ord;
}