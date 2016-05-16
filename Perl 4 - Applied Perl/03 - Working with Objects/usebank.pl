#!/usr/local/bin/perl
use strict;
use warnings;

use BankAccount;

my $personal_account = BankAccount->new( owner => 'me',
 balance => 1000,
 overdraft_limit => 500 );
$personal_account->credit( 300 );
$personal_account->debit( 100 );
my $slush_fund = BankAccount->new( owner => 'you',
 balance => 10000 );
$slush_fund->transfer( 5000, $personal_account );
print "New balance on my account = \$", $personal_account->balance, "\n";
print $personal_account->statement;
print $slush_fund->statement;