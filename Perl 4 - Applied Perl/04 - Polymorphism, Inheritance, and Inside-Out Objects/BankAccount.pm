package BankAccount;
use strict;
use warnings;

use POSIX qw(strftime);

{
  my $NEXT_ACCTNO = 10001;

  sub next_acctno
  {
    return $NEXT_ACCTNO++;
  }
}

my %Instance_Data;

sub new
{
  my ($class, %attr) = @_;

  my $ref = \my $dummy;

  bless $ref, $class;
  $ref->account_number( $class->next_acctno );
  $ref->transactions( [] );
  $ref->$_( $attr{$_} ) for keys %attr;
  return $ref;
}

BEGIN
{
  sub create_method
  {
    no strict 'refs';
    my ($class, $method) = @_;
    *$method = sub {
      my $self = shift;

      $Instance_Data{$method}{$self} = shift if @_;

      return $Instance_Data{$method}{$self};
    };
  }
  for my $method ( qw(balance account_number transactions) )
  {
    __PACKAGE__->create_method( $method );
  }
}

sub DESTROY
{
  my $self = shift;
  delete $Instance_Data{$_}{$self} for keys %Instance_Data;
}

sub transact
{
  my ($self, $type, $amount) = @_;

  my %transaction = ( date => time, type => $type, amount => $amount );

  push @{ $self->transactions }, \%transaction;
  $self->balance( $self->balance + $amount );
}

sub debit
{
  my ($self, $amount) = @_;

  $self->transact( debit => -$amount );
}

sub credit
{
  my ($self, $amount) = @_;

  $self->transact( credit => $amount );
}

sub transfer
{
  my ($self, $amount, $target_account) = @_;

  my $message = "Transfer to " . $target_account->account_number;
  $self->transact( $message, -$amount );
  $message = "Transfer from " . $self->account_number;
  $target_account->transact( $message, $amount );
}

sub statement
{
  my $self = shift;

  my $str = '';

  for my $trans ( @{ $self->transactions } )
  {
    my ($time, $type, $amount) = @{$trans}{qw(date type amount)};
    $str .= strftime( "%d-%b-%Y", localtime $time ) . "\t$type\t$amount\n";
  }

  $self->transactions( [] );
  return $str;
}

1;