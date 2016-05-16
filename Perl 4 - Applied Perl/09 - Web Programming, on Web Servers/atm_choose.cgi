#!/usr/local/bin/perl
use strict;
use warnings;

use lib qw(/users/cgaspar/mylib/lib/perl5);
use CGI qw(:all);
use CGI::Carp qw(fatalsToBrowser);
use HTML::Template;
use MyDB;

my $template = HTML::Template->new( filename => 'atm_choose.tmpl', die_on_bad_params => 0 );
my $account_number = param( 'account_number' );
my $account = MyDB->get_account( $account_number );
$template->param( %$account );
print header, $template->output;