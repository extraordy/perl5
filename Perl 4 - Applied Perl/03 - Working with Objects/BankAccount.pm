package BankAccount;

use strict;
use warnings;

#------------------------------------------------------------------------------------------------------------			<----- Modified part 1
# Lab 3, Objective 1 

# The objective let us use strftime in the POSIX module. 

use POSIX 'strftime';

#------------------------------------------------------------------------------------------------------------

{
  my $NEXT_ACCTNO = 10001;
  sub next_acctno
  {
    return $NEXT_ACCTNO++;
  }
}

sub new
{
  my ($class, %attr) = @_;
  $attr{account_number} = $class->next_acctno;  
  my $ref = \%attr;
  bless $ref, $class;
  return $ref;
}


sub balance
{
  my $self = shift;

  $self->{balance} = shift if @_;
  return $self->{balance};
}


sub owner
{
  my $self = shift;

  if ( @_ )
  {
    $self->{owner} = @_ > 1 ? [ @_ ] : shift;
  }
  my $current = $self->{owner} or return;
  return ref $current ? @$current : $current;
  
}


sub overdraft_limit
{
  my $self = shift;
  
   if ( @_ )
  {
    my $new_limit = shift;
    warn "Can't have negative overdraft limit!\n" and return if $new_limit < 0;
    $self->{overdraft_limit} = $new_limit;
  }  
  
  return $self->{overdraft_limit};
}


sub account_number
{
  my $self = shift;

  $self->{account_number} = shift if @_;
  return $self->{account_number};
}


sub transact
{
  my ($self, $type, $amount) = @_;
  my %transaction = ( date => time, type => $type, amount => $amount );
  push @{ $self->{transactions} }, \%transaction;
  $self->{balance} += $amount;
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


#------------------------------------------------------------------------------------------------------------			<----- Modified part 2
# Lab 3, Objective 1 

# Our objective is to create the "statement" routine such that running usebank.pl will 
# generate the following output: 

# cold:~/perl4homework/Project03$ ./usebank.pl
# New balance on my account = $6200
# 29-Mar-2011 credit 300
# 29-Mar-2011 debit -100
# 29-Mar-2011 Transfer from 10002 5000
# 29-Mar-2011 Transfer to 10001 -5000

sub statement
{
	# First we need to parse the object name from the method invocation.
	 
	my $self = shift;
	
	# The transaction data is stored in an anonymous array of anonymous hashes,  
	# where each transaction is represented by a hash (reference) of "date",  
	# "type" and "amount" keys and their respective values. The array reference  
	# itself is stored in an instance variable called "transactions". 
	# This variable originally is set by the "transact" method in this class.
	
	# We need to loop through the transaction array first.
	 	
	for ( my $i = 0; $i < @{$self->{transactions}}; ++$i )
        {
        	# Now, all we need to do is parse the array elements one by one 
        	# properly dereferencing the data structure to reach the 
        	# key-value pairs belonging to the actual transaction.
        	
        	# The template for "strftime" has to be set to mimic the correct  
        	# format for complying with the date output. The key is '%b', which  
        	# is the abbreviated month name, the rest is familiar.  
        	
		print strftime( '%d-%b-%Y', localtime @{$self->{transactions}}[$i]->{date} ), "\t@{$self->{transactions}}[$i]->{type}\t@{$self->{transactions}}[$i]->{amount}\n";
	}
}

1;

__END__

=head1 NAME

  BankAccount - class implementing a bank account

=head1 SYNOPSIS

  use BankAccount;
  my $account = BankAccount->new( <attributes> );

=head1 ATTRIBUTES

=head2 balance

The initial balance.

=head2 account_number

The account number.

=head2 owner

The name of the account owner.

=head1 METHODS

Any of the attributes may be accessed via a method of the same name,
and set by passing an argument to that method.  The following
methods are also defined:

=head2 $account->credit( <amount> )

Add I<amount> to the balance.

=head2 $account->debit( <amount> )

Subtract I<amount> from the balance.

=cut
