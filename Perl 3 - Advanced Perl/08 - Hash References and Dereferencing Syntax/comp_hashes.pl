#!/usr/bin/perl
use strict;
use warnings;

# The comparison of hashes follows the same logic we used in case of arrays, although hash 
# key-value pairs are not stored in a specific order. If the element (key-value pair) numbers 
# are equal, then we can proceed checking the existence of the hash1 keys in hash2, then the 
# the values associated with the keys can also be compared using regex.
 
# Test options - not the most elegant way to offer them, but easy enough to avoid too much typing.
   
# my %first = ( Wallace => 1, Gromit => 2 );
# my %second = ( Gromit => 2, Wallace => 1 );

# my %first = ( Kirk => 'Captain', Spock => 'First Officer', McCoy => 'Doctor' );
# my %second = ( Spock => 'First Officer', McCoy => 'Doctor' );

# my %first = ();
# my %second = ();

my %first = (Wallace => 1, Gromit => 2);
my %second = (Wallace => 2, Gromit => 1);

# my %first = (Wallace => 1, Gromit => 2);
# my %second = (Wallace => 1, Gromit => 2, Shawn => 3);

# Here goes some initial feedback for the user - we list the content of the two hashes sorted. 
# Using map we can generate a key-value pair list, there's no need to use explicit loop.

print "First:   ", join( ", ", map { "$_ => $first{$_}" } sort keys %first ),"\n";
print "Second:  ", join( ", ", map { "$_ => $second{$_}" } sort keys %second ),"\n";

# Then, we just call the subroutine, which compares the two hashes and - depending on the return value -
# we also print the result, as well. The subroutine takes the two hash references as its arguments. 

print "The result is: ", cmp_hshs( \%first, \%second ) ? "True\n" : "False\n";

sub cmp_hshs
{

	# We parse the parameters here with a list assignment.
	
	my ( $hash1_ref, $hash2_ref ) = @_;
	
	# If the two hashes have a different element (key-value pair) count, then we return to the main 
	# program with a zero indicating that the hashes are not identical.
	
	return 0 if keys %$hash1_ref != keys %$hash2_ref;
	
	# If the hashes have the same element number, then we can detect if hash1 keys exist in hash2 
	# using a foreach loop, which iterates through the keys of any of our hashes. This method comes 
	# with the advantage of not being dependent on the element order in any way.
	
    	for ( sort keys %$hash1_ref )
    	{
    		# Regex offers a simple way to match the hash value elements irrespectively 
    		# of their nature (whether they are numbers or strings). If a particular key doesn't 
    		# exist in both hashes, or it does but the values associated with it are different in  
    		# them, then we return zero to the main program.
    		
		return 0 if !exists $$hash2_ref{ $_ } or  $$hash1_ref{ $_ } !~ /$$hash2_ref{ $_ }/;	    	
	}
	
# The following code block is not executed, the entire section is commented out by being placed 
# between Pod directives.

# I just wanted to demonstrate, that the comparison method borrowed from the array solution
# can also be used here if we rely on the list context: we can flush the hash key-value pairs
# of the two hashes into two separate arrays repectively (strictly sorted),then each element position 
# becomes similarly ordered, that is, sequentially comparable.
 	
=pod
{	
	my $arr1_ref = [sort %$hash1_ref];
	my $arr2_ref = [sort %$hash2_ref];
		
	for( my $i = 0; $i < $#$arr1_ref; $i++ )
    	{
		return 0 if $$arr1_ref[$i] !~ /$$arr2_ref[$i]/;	    	
	}
}
=cut

	# If we are done with the loop and got so far, then the hashes are identical, so we can  
	# return 1 to indicate it. 

	return 1;
} 