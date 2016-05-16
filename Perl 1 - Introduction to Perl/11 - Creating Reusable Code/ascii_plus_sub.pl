#!/usr/bin/perl
use strict;
use warnings;

init();

sub init
{ 

	print "\nCurrent date and time: ".substr( localtime(), 0, 16 )."\n\n"; 
	foreach my $ordinal ( 32..126 )
	{
		printf "%03d %02x %04o %08b %1c\n", $ordinal, $ordinal, $ordinal, $ordinal, $ordinal;
	}

}