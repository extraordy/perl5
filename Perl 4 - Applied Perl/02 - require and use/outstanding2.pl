#!/usr/local/bin/perl
use strict;
use warnings;

use Report;

my %account = read_report( \*DATA );

print "Done reading report, computing total outstanding:\n";
my $total;
for my $num ( keys %account )
{
 $total += $account{$num}{balance};
}
printf "\$%.2f\n", $total;

__END__
FIELDS: owner, account_number, balance, credit_limit
# This data file syntax permits comments starting with a # sign
Count Moneybags
897454835
3268956.00
100000000
Widow Bessie
783231622
21.50
100