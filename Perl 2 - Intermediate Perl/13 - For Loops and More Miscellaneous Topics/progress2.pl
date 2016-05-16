#!/usr/bin/perl
use strict;
use warnings;

$| = 1;

for ( 1 .. 100 )
{
	long_operation( $_ );
	
	# Here's the subroutine call to spin the characters.
	 
	spin( $_ );
}

sub long_operation
{
	 my $arg = shift;
	 print "Processing element $arg\n" unless $arg % 15;
	 sleep 1;
}


sub spin
{        

	# spin takes one argument, the iterator value of the
	# for loop passed by $_.  

	my $arg = shift;
	
	# The characters representing the phases of the 
	# spinning are stored in an array, this makes it
	# easy to refere to them by their indicies.
	
	my @spinners = qw( - \ | / );
	
	# Dividing the actual iterator value by the number 
	# of phases and using the cyclically alternating
	# remainder to refer to the array elements creats 
	# the illusion of a simple animation if we rewind 
	# the cursor to the beginning of the line after 
	# each printing cycle.
	
	print "$spinners[$_%4]\r";

}