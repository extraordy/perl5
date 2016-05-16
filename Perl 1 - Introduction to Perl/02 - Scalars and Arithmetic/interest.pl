#!/usr/bin/perl
use strict;
use warnings;

my $principal = 100000;
my $interest_rate = 7; # %
my $term = 20; # Years

# Interest calculation
# Formula used: C = P * (1 + R/100) ** T
#	C = total cost of loan (principal + interest)
#	P = principal
#	R = interest in percent
#	T = term in years

my $total_paid = $principal*(1+$interest_rate/100)**$term;

print "Value of principal + interest after ", $term, " years = ", $total_paid, "\n";