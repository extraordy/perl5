#!/usr/bin/perl
use strict;
use warnings;

my $apples = 5;
my $got = 'apples';

# We have only one grammatical exception, so there's only one specific condition to check...
if ( $apples == 1 )
{
    # Since this is a single, exceptional case, we don't need to depend on the actual state of our variables, thus we don't need (grammatically correct) interpolation here		
    print "I have 1 apple\n";
}
# all other options can be covered by one block of code   
else
{
   # Now we can substitute the values of our variables without any lingual concerns  
   print "I have $apples $got\n";
}
