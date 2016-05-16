#!/usr/bin/perl
use strict;
use warnings;

# Grocery store inventory:
my $lines = <<'END_OF_REPORT';
0.95 300 White Peaches
1.45 120 California Avocados
5.50  10 Durien
0.40 700 Spartan Apples
END_OF_REPORT

my ($line1, $line2, $line3, $line4) = split "\n", $lines;

	# line 1
	
my ($cost, $quantity, $item) = split " ", $line1, 3;
if ( index( $item, "es" ) >= 0 )
{
	print "Total value of $item on hand = \$", $cost * $quantity, "\n"; # line 1 -> White Peaches - should be printed
}

	# line 2
	
($cost, $quantity, $item) = split " ", $line2, 3;
if ( index( $item, "es" ) >= 0 )
{
	print "Total value of $item on hand = \$", $cost * $quantity, "\n";
}

	# line 3
	
($cost, $quantity, $item) = split " ", $line3, 3;
if ( index( $item, "es" ) >= 0 )
{
	print "Total value of $item on hand = \$", $cost * $quantity, "\n"; 
}

	# line 4 
	
($cost, $quantity, $item) = split " ", $line4, 3;
if ( index( $item, "es" ) >= 0 )
{
	print "Total value of $item on hand = \$", $cost * $quantity, "\n";  # line 4 -> Spartan Apples - should be printed
}