#!/usr/local/bin/perl
use strict;
use warnings;

use lib qw(/users/cgaspar/mylib/lib/perl5);

use CheckingAccount;
use SavingsAccount;

my $regular   = CheckingAccount->new( balance => 1000 );
my $piggybank = SavingsAccount->new( balance => 5000 );

$regular->write_check( "Greenpeace" => 250 );
$regular->write_check( "O'Reilly", 395 );
$regular->transfer( 100, $piggybank );
print $regular->statement;
print "\n";
$piggybank->add_interest;
print $piggybank->statement;

#------------------------------------------------------------------------------------------------------------			<----- Modified part
# Lab 6, Objective 1 
#

# In order to test the setter (writer) method of the Interest_Rate Moose attribute from the SavingsAccount
# class, I extended the usebank.pl to change the interest rate value in the current object instance.

print "\nTesting \"set_interest_rate\" writer method: \n";
print "\n";
$piggybank->set_interest_rate(0.025);
$piggybank->add_interest;
print $piggybank->statement;
print "\n";

#------------------------------------------------------------------------------------------------------------