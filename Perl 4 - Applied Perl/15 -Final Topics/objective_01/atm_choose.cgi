#!/usr/local/bin/perl
use strict;
use warnings;

use lib qw(/users/cgaspar/mylib/lib/perl5);
use CGI qw(param);
use CGI::Carp qw(fatalsToBrowser);
use MyTemplate;
use Bank;

my $template = MyTemplate->new;
my $account_number = param( 'account_number' );

my ($account) = Bank::Account->search( account_number => $account_number );

$template->param( owners => join ', ', map { $_->first_name . " " . $_->last_name } $account->owners );

$template->param( account_number => $account_number,
                  balance => $account->get( 'balance' ) );

my @ATTRS = qw(transaction_date type amount new_balance);
my @transactions = map { my $t = $_; +{ map { $_, $t->$_ } @ATTRS } }
                       $account->transactions;
$template->param( transaction_loop => \@transactions );
print $template->html_output;