#!/usr/local/bin/perl
use strict;
use warnings;

use SavingsAccount;

my $piggybank = SavingsAccount->new( balance => 5000 );
SavingsAccount->set_interest_rate( 0.02 );
$piggybank->add_interest;
print $piggybank->balance, "\n";