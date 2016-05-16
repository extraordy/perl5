package BankAccount;

use Moose;

has account_number => ( isa => 'Int', is => 'ro',
		       default => \&next_acctno );
has transactions   => ( isa => 'ArrayRef[Str]', is => 'rw',
			default => sub { [] } );
has balance        => ( isa => 'Num', is => 'rw' );

use POSIX qw(strftime);

{
  my $NEXT_ACCTNO = 10001;

  sub next_acctno
  {
    return $NEXT_ACCTNO++;
  }
}


sub transact
{
  my ($self, $type, $amount) = @_;

  my $balance = $self->balance( $self->balance + $amount );
  my %transaction = ( date => time, type => $type, amount => $amount,
		      balance => $balance );
  push @{ $self->transactions }, \%transaction;
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

  my $str = "Statement for account " . $self->account_number . ":\n";
  for my $trans ( @{ $self->transactions } )
  {
    my ($time, $type, $amount, $balance)
       = @{$trans}{qw(date type amount balance)};
    $_ = sprintf '%.2f', $_ for ($amount, $balance);
    $str .= strftime( "%d-%b-%Y", localtime $time )
         . "\t$type\t$amount\t$balance\n";
  }
  $self->transactions( [] );
  return $str;
}

1;
