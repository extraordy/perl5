#!/usr/bin/perl
use strict;
use warnings;

foreach my $ord ( 32..126 )
{
	printf "%03d %02x %04o %08b %1c\n", $ord, $ord, $ord, $ord, $ord;
}