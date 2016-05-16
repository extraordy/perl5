package Bank;
use strict;
use warnings;

use base 'Class::DBI';

use Cwd;

#------------------------------------------------------------------------------------------------------------			<----- Modified part 1
# Lab 15, Objective 1 

# Our objective is to move the code between the "sleep" and the "exit" calls from atm_timed.cgi to a method 
# "add_transaction" in Bank::Account such that the code in atm_timed.cgi can be replaced with the following 
# and still work:

# Code Fragment

# sleep $to_sleep;
# my ($account) = Bank::Account->search( account_number => $account_number );
# $account->add_transaction( $type, $amount );
# exit;

# Next, we need to insert code in the "add_transaction" method that will email us if the balance on an account
# drops below zero. We can hard-code our email address in.

# These are the modules for sending simple emails

use Email::Sender::Simple;
use Email::Simple;
use Email::Simple::Creator;

# This is the email address hard-wired in where the overdraft alert goes out. 
# Please change it for testing purposes.

my $recipient = "cgaspar\@telus\.net";

#------------------------------------------------------------------------------------------------------------

my $SERVER   = 'sql';
my ($USER) = (cwd() =~ m!/.*?/(.*?)/!);

# Please insert your MySQL password here...

my $PASSWORD = ''; 


__PACKAGE__->connection( "dbi:mysql:database=$USER;host=$SERVER", $USER, $PASSWORD );

package Bank::Account;

use base 'Bank';

__PACKAGE__->table( 'account' );
__PACKAGE__->columns( All => qw(id account_number balance) );
__PACKAGE__->has_many( owners => [ 'Bank::Customer' => 'person' ] );
__PACKAGE__->has_many( transactions => [ 'Bank::Transactions' => 'single_transaction' ] );
__PACKAGE__->autoupdate( 1 );

#------------------------------------------------------------------------------------------------------------			<----- Modified part 2
# Lab 15, Objective 1 

# The add_transaction method must be created under the Bank::Account package. The code between the "sleep" and 
# the "exit" calls from atm_timed.cgi can be cut and paste here, only the "account" object references need to be 
# updated to $self everywhere.

sub add_transaction
{
	  my ( $self, $type, $amount ) = @_;
	
	  my $balance = $self->get( 'balance' );
	  my ($trans_type) = Bank::Transaction::Type->search( name => $type );
	  my $new_balance = $balance + ($type eq 'credit' ? 1 : -1) * $amount;
	  
	  my $single_trans = Bank::Transaction::Single->insert( { amount => $amount,
	                                     transaction_type => $trans_type,
	                                     previous_balance => $balance,
	                                     new_balance => $new_balance,
	                                     } );
	  Bank::Transactions->insert( { single_transaction => $single_trans,
	                                account => $self } );
	  $self->set( balance => $new_balance );
	  
	  # The overdraft alert will be another method of the Bank::Account package, ensuring this we can easily
	  # refer to the current bank account and its balance in the email. The recipient's email address is
	  # passed to the method as a parameter.	  
	  
	  $self->overdraft_alert( $recipient ) if $new_balance < 0;  
}

# Our overdraft alerter method below makes the email sending possible to become a distinct task from the  
# transaction code, which results in a cleaner and better code structure.

sub overdraft_alert
{
  	my ( $self, $to ) = @_;
  	 	
        my $msg = "Dear Customer,\n\nThe balance on your \"".$self->get( 'account_number' )."\" account fell into the negative.\n";
           $msg .= "The current balance is ".$self->get( 'balance' )."\.\n\nSincerely,\n\nFirst Bank of O\'Reilly"; 
	my $from  = "alert\@oreillybank\.com";
	my $email = Email::Simple->create( 
			header => [
		           To      => $to,
		           From    => $from,
		           Subject => "Overdraft Alert",
		    ],
		    body => $msg,
	);

	Email::Sender::Simple->send( $email ); 
}

#------------------------------------------------------------------------------------------------------------


package Bank::Customer;

use base 'Bank';

__PACKAGE__->table( 'customer' );
__PACKAGE__->columns( Primary => qw(account person) );
__PACKAGE__->has_a( person => 'Bank::Person' );
__PACKAGE__->has_a( account => 'Bank::Account' );


package Bank::Person;

use base 'Bank';

__PACKAGE__->table( 'person' );
__PACKAGE__->columns( All => qw(id first_name last_name) );
__PACKAGE__->has_many( accounts => [ 'Bank::Customer' => 'account' ] );


package Bank::Transactions;

use base 'Bank';

__PACKAGE__->table( 'transactions' );
__PACKAGE__->columns( Primary => qw(account single_transaction) );
__PACKAGE__->has_a( single_transaction => 'Bank::Transaction::Single' );
__PACKAGE__->has_a( account => 'Bank::Account' );


package Bank::Transaction::Single;

use base 'Bank';

__PACKAGE__->table( 'single_transaction' );
__PACKAGE__->columns( All => qw(id amount transaction_type previous_balance new_balance transaction_date) );
__PACKAGE__->has_a( transaction_type => 'Bank::Transaction::Type' );
__PACKAGE__->has_many( accounts => [ 'Bank::Transactions' => 'account' ] );

sub type
{
  return shift->get( 'transaction_type' )->name;
}


package Bank::Transaction::Type;

use base 'Bank';

__PACKAGE__->table( 'transaction_type' );
__PACKAGE__->columns( All => qw(id name) );


1;