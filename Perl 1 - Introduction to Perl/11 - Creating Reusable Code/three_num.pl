#!/usr/bin/perl
use strict;
use warnings;

print add_three_numbers( 12, 592, 2928 );
print add_three_numbers( 9, 2, 4, 5, 10 );

sub add_three_numbers
{
 
	 # The argument number is equal to the size of the default array, 
	 # which can be retrieved in scalar context.
	 
	 # IF the argument number is NOT EQUAL to three,
	 # we terminate the program by using die.
	  
	 unless ( @_ == 3 )
	  {
	    # Die outputs its argument to the STDERR output channel without buffering,
	    # so this will change the order of the output when invoked.
	      
	    die "add_three_numbers needs three arguments\n";
	  }
	  
	  my ( $num1, $num2, $num3 ) = @_;
	  
	  # Since we invoke the function from list context only, it doesn't seem so important
	  # to identify the context in which "add_three_numbers" subroutine is being called.
	  
	  return ( $num1 + $num2 + $num3 );
  
}