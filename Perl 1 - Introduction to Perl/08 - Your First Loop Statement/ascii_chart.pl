#!/usr/bin/perl
use strict;
use warnings;

my $ordinal = 31;

while ( $ordinal++ < 126 )
{
	print "$ordinal ", chr($ordinal), "\n";
}