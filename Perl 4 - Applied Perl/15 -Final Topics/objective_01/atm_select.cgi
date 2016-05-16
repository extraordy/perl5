#!/usr/local/bin/perl
use strict;
use warnings;

use lib qw(/users/cgaspar/mylib/lib/perl5);
use CGI::Carp qw(fatalsToBrowser);
use MyTemplate;
use Bank;

my $template = MyTemplate->new;
my @acct_nums = map { $_->get( 'account_number' ) } Bank::Account->retrieve_all;
$template->param( account_loop => [ map { { account_number => $_ } } @acct_nums ] );

print $template->html_output;