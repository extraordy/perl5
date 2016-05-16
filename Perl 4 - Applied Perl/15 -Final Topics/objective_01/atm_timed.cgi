#!/usr/local/bin/perl
use strict;
use warnings;

use lib qw(/users/cgaspar/mylib/lib/perl5);
use CGI qw(:all);
use CGI::Carp qw(fatalsToBrowser);
use MyTemplate;
use Date::Parse;
use Bank;

my $template = MyTemplate->new;
my %param = map { $_, param( $_ ) } qw(account_number type time amount);

my $time = str2time( $param{time} ) or die "Cannot parse '$param{time}'";
my $to_sleep = $time - time;
die "time is no good\n" if $to_sleep < 0 || $to_sleep > 3600;

$param{time} = localtime $time;
$template->param( %param );
print $template->html_output;

my ($account_number, $type, $amount) = @param{ qw(account_number type amount) };
unless ( fork )   # child
{
  close STDIN;    # This prevents the web server from holding the
  close STDOUT;   # connection open the whole time we're sleeping
  close STDERR;
  sleep $to_sleep;

  my ($account) = Bank::Account->search( account_number => $account_number );
  
#------------------------------------------------------------------------------------------------------------			<----- Modified part 1
# Lab 15, Objective 1 

# This is the method call which replaces the actual code lines of the transaction handling.
  
  $account->add_transaction( $type, $amount );

#------------------------------------------------------------------------------------------------------------	

  exit;
}