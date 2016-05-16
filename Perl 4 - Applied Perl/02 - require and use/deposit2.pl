#!/usr/local/bin/perl
use strict;
use warnings;

use Report;

my %account = read_report( \*DATA );

print "Done reading report, computing total on deposit:\n";
my $total;
for my $num ( keys %account )
{
 $total += $account{$num}{balance};
}


printf "%.2f\n", $total;


__END__
FIELDS: account_number, owner, balance, last_statement_date
736353423
Lenny Landlord
38670.40
2011-03-02
#
663677908
Marvin Mogul
83910.20
2011-03-05
#