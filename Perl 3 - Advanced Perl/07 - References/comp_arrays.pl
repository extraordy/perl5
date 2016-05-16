#!/usr/bin/perl
use strict;
use warnings;
 
# Test options - not the most elegant way to offer
# them, but easy enough to avoid too much typing.
   
# my @first  = map $_** 2, 1..10;
# my @second = map $_** 2, 1..10;

my @first = ('Wallace', 'Gromit');
my @second = ('Wallace', 'Gromit', 'Shawn');

# my @first = (3, 4, 5);
# my @second = (5, 4, 3);

# my @first = ();
# my @second = ();

# my @first = ('Kirk', 'Spock', 'McCoy');
# my @second = ('Kirk', 'Spock');

# my @first = (1, 2, 3);
# my @second = ('1', '2', '3');

# Here goes some initial feedback for the user - we 
# list the content of the two arrays.

print "First:  ", join( ", ", @first ),"\n";
print "Second: ", join( ", ", @second ),"\n";  	

# Then, we just call the subroutine, which compares 
# the two array and - depending on the return value -
# we also print the result, as well. The subroutine
# takes the two array references as its arguments. 

print "The result is: ", cmp_arrs( \@first, \@second ) ? "True\n" : "False\n";

sub cmp_arrs
{

	# We parse the parameters here with a 
	# list assignment.
	
	my ( $arr1_ref, $arr2_ref ) = @_;
	
	# If the two arrays have a different element
	# count, then we return to the main 
	# program with a zero indicating that 
	# the arrays are not identical.
	
	return 0 if @$arr1_ref != @$arr2_ref;
	
	# If the arrays have the same element number,
	# then we can compare their elements one by 
	# one in a for loop, which gives us a nice 
	# iterator running from the firs element 
	# index (0) to the last one ($#$arr1_ref) of
	# any of our arrays.  
	
    	for( my $i = 0; $i < $#$arr1_ref; $i++ )
    	{
    		# Regex offers a simple way to match 
    		# the array elements irrespectively 
    		# of their nature (whether they are 
    		# numbers or strings). 
    		
    		# If the values don't match, we return
    		# zero to the main program.     		
    		
		return 0 if $$arr1_ref[$i] !~ /$$arr2_ref[$i]/;	    	
	}
	
	# If we are done with the loop and got so far, then
	# the arrays are identical, so we can return 1 to 
	# indicate it. 
	
	return 1;
} 