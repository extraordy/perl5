#!/usr/bin/perl
use strict;
use warnings;

my $cash = 285000;

my $principal = 100000;
my $interest_rate = 7; # %
my $term = 20; # Years

my $total_paid = $principal*(1+$interest_rate/100)**$term;

# The difference calculated between two values in percetage is based on the following formula: 
#     D = ((( C - T ) / T ) * 100 ),
# where
#     D = Difference in percentage,
#     C = Cash,
#     T = Total paid.

my $difference = ((($cash-$total_paid)/$total_paid)*100); # %

print 'The difference between $cash and $total_paid is: ', $difference, "%\n";

if ( $difference  > 10  )
{
    print "Approved\n";	
} 
elsif ( $difference >= 0 && $difference <= 10 )
{
    print "Marginal\n";	
}
else
{
    print "Unacceptable\n";	
}