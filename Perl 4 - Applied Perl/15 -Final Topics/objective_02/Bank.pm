package Bank;
use strict;
use warnings;

#------------------------------------------------------------------------------------------------------------	
# Lab 15, Objective 2 

# Our objective is to write a web-based ATM that provides functionality for credit, debit, statement 
# generation, and transfer to another account listed from a pull-down menu. Also, we need to create 
# another interface for setting up an initial account to enter owner(s) name(s), initial balance, 
# and a password which will be used to log in to the ATM; we have to use the crypt() function to 
# store the password and authenticate logins.
# We must use POD to document our application.

#------------------------------------------------------------------------------------------------------------	

# Loading Class::DBI module and inheriting from it

use base 'Class::DBI';

# Getting pathname of current working directory
use Cwd;

# Email features for alerting and sending statement

use Email::Sender::Simple;
use Email::Simple;
use Email::Simple::Creator;

# MySQL credentials

my $SERVER   = 'sql';
my ($USER) = (cwd() =~ m!/.*?/(.*?)/!);
my $PASSWORD = 'loreley2000'; 

# MySQL DBI connection 

__PACKAGE__->connection( "dbi:mysql:database=$USER;host=$SERVER", $USER, $PASSWORD );

# Class and method definitions


# ACCOUNT CLASS
#------------------------------------------------------------------------------------------------------------
# This class represents the account table in the database. It has 3 columns: id, account_number and balance.
# The class has a many to many relationship with the Bank::Transactions::Single class implemented through the 
# Bank::Transactions class.

package Bank::Account;

use base 'Bank';

__PACKAGE__->table( 'account' );
__PACKAGE__->columns( All => qw(id account_number balance) );
__PACKAGE__->has_many( owners => [ 'Bank::Customer' => 'person' ] );
__PACKAGE__->has_many( transactions => [ 'Bank::Transactions' => 'single_transaction' ] );
__PACKAGE__->autoupdate( 1 );


# add_transaction
# ---------------
# Params:  type, amount
# Returns: (single transaction) id

# Changes the balance of the related account according to type and amount of the transaction.


sub add_transaction
{
	my ( $self, $type, $amount ) = @_;
	
	my $balance = $self->get( 'balance' );
	my ($trans_type) = Bank::Transaction::Type->search( name => $type );
	my $new_balance = $balance + ($type eq 'credit' ? 1 : -1) * $amount;
	  
	my $single_trans = Bank::Transaction::Single->insert({ 
	  				amount			=> $amount,
	                        	transaction_type	=> $trans_type,
	                        	previous_balance	=> $balance,
	                        	new_balance		=> $new_balance,
	                     });
	  		     
	  		     Bank::Transactions->insert({ 
	  				single_transaction	=> $single_trans,
	                        	account			=> $self, 
	                     });
	                        
	$self->set( balance => $new_balance );
	
	$self->overdraft_alert() if $new_balance < 0;
	
	return $single_trans->get( 'id' );
}


# account_statement
# -----------------
# Params:  N/A
# Returns: a single string scalar

# Creates a plain text account statement - similar to that the atm_statement.cgi generates.


sub account_statement
{

  	my $self = shift;
  	
  	my $account = $self->account_number;
  	my $owners  = join ', ', map { $_->first_name . " " . $_->last_name } $self->owners;	
  	my $balance = $self->apply_currency_format( $self->balance );
  	
  	my $statement_header =   <<"END_MESSAGE";
		
First Bank of O.Reilly
		
Account Statement
		
Account number      $account
Owner(s)                   $owners
Balance                     $balance
END_MESSAGE
		
  	my $list_header1 = sprintf ("%116s","Ending");
  	my $list_header2 = sprintf ( "%38s %15s %19s %23s %25s", "Date","What","Amount","Balance","Transfer" );
  	my @ATTRS = qw(transaction_date type amount new_balance transfer);
	my @transactions = map { my $t = $_; +{ map { $_, $t->$_ } @ATTRS }} $self->transactions;
  	
   	my ( $statement_body, $body_line ) = '';
	
  	
   	for my $transaction ( @transactions )
  	{
  		my $transfer = $transaction->{'transfer'};
  		$transfer =~ s/\Q&#9658;/>/;
  		
  		my $amount      = $transaction->{'amount'};
	  	my $new_balance = $transaction->{'new_balance'};
	  		
	  	$transaction->{'amount'}      = $self->apply_currency_format( $amount );
	  	$transaction->{'new_balance'} = $self->apply_currency_format( $new_balance );
  		
  		$body_line = sprintf ("%25s %15s %19s %22s %20s\n", 
  					  $transaction->{'transaction_date'},
  					  $transaction->{'type'},
					  $transaction->{'amount'},
					  $transaction->{'new_balance'},
					  $transfer );
					  	
  		$statement_body .= $body_line;			
  	}
  	
  	return $statement_header."\n".$list_header1."\n".$list_header2."\n\n".$statement_body."\n\n";
}


# apply_currency_format
# ---------------------
# Params:  amount
# Returns: a single formatted string scalar

# Applies currency symbol and decimal place indication to a given amount.


sub apply_currency_format {

	my $class = shift;
	my $number = sprintf "%.2f", shift @_;

	1 while $number =~ s/^(-?\d+)(\d\d\d)/$1,$2/;
	$number =~ s/^(-?)/$1\$/;

	return $number;

}


# overdraft_alert
# ---------------
# Params:  N/A
# Returns: N/A

# Sends an email to the account owners when the account balance drops to negative.


sub overdraft_alert
{
  	my $self = shift;
  	
  	my $recipients = join '; ', map { $_->email } $self->owners; 	 
	my $sender  = "alert\@oreillybank\.com";
	my $subject = "Overdraft Alert";
	my $message = "Dear Customer,\n\nThe balance on your \"".$self->get( 'account_number' )."\" account fell into the negative.\n";
           $message .= "The current balance is ".$self->get( 'balance' )."\.\n\nSincerely,\n\nFirst Bank of O\'Reilly"; 

	send_email( $recipients, $sender, $subject, $message );
}


# send_statement
# --------------
# Params:  N/A
# Returns: N/A

# Sends the statement as an email to the account owners.


sub send_statement
{
  	my $self = shift;
  	
  	my $recipients = join '; ', map { $_->email } $self->owners;  
	my $sender  = "statement\@oreillybank\.com";
	my $subject = "Account Statement";
	my $message = $self->account_statement;

	send_email( $recipients, $sender, $subject, $message );
}


# send_statement
# --------------
# Params:  recipient, sender, subject, message
# Returns: N/A

# Implements the generic email sender.


sub send_email
{

  	my ( $to, $from, $subj, $msg ) = @_;
  	
	my $email = Email::Simple->create( 
			header => [
		           To      => $to,
		           From    => $from,
		           Subject => $subj,
		    ],
		    body => $msg,
	);

	Email::Sender::Simple->send( $email ); 
}


# add_transfer
# ------------
# Params:  amount, (the target) account_number
# Returns: N/A

# Runs two transactions one after the other against two accounts, where one 
# represents the sender and the other the recipient. It changes the balance 
# of the two related accounts according to their role in the transactions, 
# and makes a note of each others' transfer_id record.


sub add_transfer
{
	my ( $self, $amount, $to_account_number ) = @_;
	  
	my $type = 'debit';
	my $sender_single_transaction_id = $self->add_transaction( $type, $amount );
	  
	$type = 'credit';
	my $recipient = Bank::Account->retrieve( account_number => $to_account_number );
	my $recipient_single_transaction_id = $recipient->add_transaction( $type, $amount );
	
	my $sender_single_transaction = Bank::Transaction::Single->retrieve( id => $sender_single_transaction_id );
	my $recipient_single_transaction = Bank::Transaction::Single->retrieve( id => $recipient_single_transaction_id );
		
	$sender_single_transaction->transfer_id( $recipient_single_transaction_id ); $sender_single_transaction->update;
	$recipient_single_transaction->transfer_id( $sender_single_transaction_id );$recipient_single_transaction->update;
	
}


# CUSTOMER CLASS
#------------------------------------------------------------------------------------------------------------
# This class represents the customer table in the database. It has 2 columns: account, person. The class 
# implements a many to many relationship between the Bank::Account and the Bank::Person classes. By its 
# multi-column primary key, it has a direct relationship with both classes.

package Bank::Customer;

use base 'Bank';

__PACKAGE__->table( 'customer' );
__PACKAGE__->columns( Primary => qw(account person) );
__PACKAGE__->has_a( person => 'Bank::Person' );
__PACKAGE__->has_a( account => 'Bank::Account' );


# add_customer
# ------------
# Params:  params, account_number, init_balance, first_name, last_name, password
# Returns: 1 for fulfilled requests from registered and authenticated users who 
#          are not yet owners or unregistered users, 0 for authenticated registered 
#          users who are already owners or unauthenticated registered users.

# Creates an account and a related ownership. It checks if the user has already been
# registered. If the password is also on record, it creates the account under the 
# registered owner name, otherwise it won't create the account. If the user is not
# registered in the system, it creates both the account and the person and their
# relationship.


sub add_customer
{                   
	my ( $class, $params ) = @_;
			
	my $registered_customer = Bank::Person->retrieve( email => $params->{ email } );
	my $registered_account  = Bank::Account->search( account_number => $params->{ account_number } );
	my $ID_legit; 	
	
	my $PRIMARY_ACCOUNT_HOLDER  = ( defined $params->{ init_balance } and $params->{ init_balance } ne '' ) ? 1 : 0;
	
	if ( $PRIMARY_ACCOUNT_HOLDER )
	{
		if ( !$registered_account )
		{
			if ( $registered_customer )
			{
				$ID_legit = $registered_customer->check_password( $params->{ password } );

				if ( $ID_legit )
				{
				
					my $new_account = Bank::Account->insert({ 
								account_number 	=> $params->{ account_number }, 
								balance	=> $params->{ init_balance }, 
		  				          });
		  				          
		  			$new_account->add_to_owners({ person => $registered_customer }); 
		  			
		  			return 1;
				
				}
				else
				{
					return 0;
				}	
			}
			else
			{			
				my $new_account = Bank::Account->insert({ 
						        account_number => $params->{ account_number }, 
						        balance	=> $params->{ init_balance }, 
				       	          });
				       	  
				my $new_person = Bank::Person->insert({
						         first_name => $params->{ first_name }, 
						         last_name => $params->{ last_name },
						         email => $params->{ email }, 
				          });
				 
				$new_person->add_digest( $params->{ password } );
			
				$new_account->add_to_owners({ person => $new_person }); 
				
				return 1;
			}
		}
		else
		{
			return 0;
		}
		
	}
	else
	{
		my $existing_account = Bank::Account->retrieve( account_number => $params->{ account_number } );

		if ( $existing_account )
		{				
			if ( $registered_customer )
			{
				my $account_holder = grep { $_->email eq $params->{ email } } $existing_account->owners;
				
				if ( !$account_holder )
				{
					$ID_legit = $registered_customer->check_password( $params->{ password } );
		
					if ( $ID_legit )
					{					  				          
				  		$existing_account->add_to_owners({ person => $registered_customer }); 
				  			
				  		return 1;
						
					}
					else
					{
						return 0;
					}	
				}
				else
				{
					return 0;
				}
			}
			else
			{		
				my $new_person = Bank::Person->insert({
							first_name => $params->{ first_name }, 
							last_name => $params->{ last_name },
							email => $params->{ email }, 
					 	 });	
					 	 
				$new_person->add_digest( $params->{ password } );
					
				$existing_account->add_to_owners({ person => $new_person });
				
				return 1;
			}
		}
		else
		{
			return 0;
		}			
	}
}


# PERSON CLASS
#------------------------------------------------------------------------------------------------------------
# This class represents the person table in the database. It has 5 columns: id, first_name, last_name, digest, 
# email. The class has a many to many relationship with the Bank::Account class implemented through the 
# Bank::Customer class. This declaration feels incorrect, though, as a single transaction may belong to only 
# a single account in this solution, the relationship provides access to the bank account information directly 
# from the Bank::Transactions::Single objects.


package Bank::Person;

use base 'Bank';

__PACKAGE__->table( 'person' );
__PACKAGE__->columns( All => qw(id first_name last_name digest email) );
__PACKAGE__->has_many( accounts => [ 'Bank::Customer' => 'account' ] );


# add_digest
# ----------
# Params:  password
# Returns: N/A

# Creates a cryptographic hash (digest) - using the Perl crypt function - 
# from a given password and stores it in the database.


sub add_digest
{
	my ( $self, $password ) = @_;
	  
	my $digest = crypt $password, create_salt();
	
	# $self->set( digest => $digest );
	$self->digest($digest);
	$self->update;
}


# check_password
# --------------
# Params:  password
# Returns: 1 for match, 0 for no match

# Checks if a generated digest is identical with the one stored in the "person" table.


sub check_password
{
	my ( $self, $password ) = @_;
	  
	return ( crypt( $password, $self->digest ) eq $self->digest ) ? 1 : 0;	
}


# check_digest
# --------------
# Params:  digest
# Returns: 1 for match, 0 for no match

# Almost the same as above, it just matches given digest with a stored one.


sub check_digest
{
	my ( $self, $digest ) = @_;
	  
	return ( $digest eq $self->digest ) ? 1 : 0;	
}


# create_salt
# --------------
# Params:  N/A
# Returns: a random two character string

#  Creates and returns the visible part of the digest, a random two character string.


sub create_salt
{
	my @chars = ('.', '/', 0..9, 'A'..'Z', 'a'..'z');
	return join '', $chars[rand @chars], $chars[rand @chars];
}


# TRANSACTIONS CLASS
#------------------------------------------------------------------------------------------------------------
# This class represents the transactions table in the database. It has 2 columns: account, and single_transaction.
# The class implements a many to many relationship between the Bank::Account and the Bank::Transactions::Single
# classes. By its multi-column primary key, it has a direct relationship with both classes.


package Bank::Transactions;

use base 'Bank';

__PACKAGE__->table( 'transactions' );
__PACKAGE__->columns( Primary => qw(account single_transaction) );
__PACKAGE__->has_a( single_transaction => 'Bank::Transaction::Single' );
__PACKAGE__->has_a( account => 'Bank::Account' );


# TARNSACTION::SINGLE CLASS
#------------------------------------------------------------------------------------------------------------
# This class represents the single_transaction table in the database. It has 7 columns: id, amount, transaction_time, 
# previous_balance, new_balance, transaction_date and transfer_id. The class has a many to many relationship with 
# the Bank::Account class implemented through the Bank::Transactions class. This declaration feels incorrect 
# as a transaction may belong to a single account in this solution, but the relationship provides access to the 
# bank account information directly from the C<Bank::Transactions::Single> objects. It also has a one to one 
# relationship with the Bank::Transactions::Type class.

package Bank::Transaction::Single;

use base 'Bank';

__PACKAGE__->table( 'single_transaction' );
__PACKAGE__->columns( All => qw(id amount transaction_type previous_balance new_balance transaction_date transfer_id) );
__PACKAGE__->has_a( transaction_type => 'Bank::Transaction::Type' );
__PACKAGE__->has_many( accounts => [ 'Bank::Transactions' => 'account' ] );


# type
# ----
# Params:  N/A
# Returns: the name value of the transaction type

#  An accessor method example of how to bridge the different naming conventions
# of the type value in the HTML template and the database in order to populate 
# statement rows in a single loop..


sub type
{
	return shift->get( 'transaction_type' )->name;
}


# transfer
# --------
# Params:  N/A
# Returns: a string scalar with the target account number concatenated with the 
# direction symbol.

# Another accessor method to the statement loop to extract, convert and incorporate 
# transfer data (target account number and transfer direction) into the statement lines.


sub transfer
{
	my $self = shift;
	my $nada = "";

	if ( $self->type eq 'credit' )
	{	
		if ( defined $self->transfer_id )
		{
			my ($sender) = Bank::Transactions->search( single_transaction => $self->transfer_id );
			my $account = Bank::Account->retrieve( id => $sender->account );
			my $account_number = $account->account_number;
			my $direction = ' &#9658;';
			
			return  $account_number.$direction;
		}
		else
		{
			return  $nada;
		}
	}
	else
	{
		if ( defined $self->transfer_id )
		{
			my ($recipient) = Bank::Transactions->search( single_transaction => $self->transfer_id );
			my $account = Bank::Account->retrieve( id => $recipient->account );
			my $account_number = $account->account_number;
			my $direction = '&#9658; ';
			
			return  $direction.$account_number;
		}
		else
		{
			return  $nada;
		}
	}	
}


# TRANSACTION::TYPE CLASS
#------------------------------------------------------------------------------------------------------------
# This class represents the transaction_type table in the database. It has 2 columns: id and name.
# The class implements a one to one relationship with the Bank::Transactions::Single class. 
# The name values are given: 'credit' and 'debit'.

package Bank::Transaction::Type;

use base 'Bank';

__PACKAGE__->table( 'transaction_type' );
__PACKAGE__->columns( All => qw(id name) );
	

1;

__END__

=head1 NAME

B<Bank.pm> - The business logic module of the Automated Teller Machine application (First Bank of O'Reilly)
created as a final project in the O'Reilly School of Technology Applied Perl course.

=head1 USAGE

Use this module in interactive CGI files to provide automated teller functionality  

C<use Bank;>

=head2 DBI class definitions

=over 12

=item C<Bank::Account>


This class represents the C<account> table in the database. It has 3 columns: C<id>, C<account_number> and C<balance>.
The class has a many to many relationship with the C<Bank::Transactions::Single> class implemented through the C<Bank::Transactions> class.


=item C<Bank::Customer>


This class represents the C<customer> table in the database. It has 2 columns: C<account>, C<person>.
The class implements a many to many relationship between the C<Bank::Account> and the C<Bank::Person> classes. By its multi-column primary key,
it has a direct relationship with both classes.


=item C<Bank::Person>


This class represents the C<person> table in the database. It has 5 columns: C<id>, C<first_name>, C<last_name>, C<digest>, C<email>.
The class has a many to many relationship with the C<Bank::Account> class implemented through the C<Bank::Customer> class.
This declaration feels incorrect, though, as a single transaction may belong to only a single account in this solution, the relationship 
provides access to the bank account information directly from the C<Bank::Transactions::Single> objects.


=item C<Bank::Transactions>


This class represents the C<transactions> table in the database. It has 2 columns: C<account>, and C<single_transaction>.
The class implements a many to many relationship between the C<Bank::Account> and the C<Bank::Transactions::Single> classes. By its multi-column 
primary key, it has a direct relationship with both classes.


=item C<Bank::Transactions::Single>


This class represents the C<single_transaction> table in the database. It has 7 columns: C<id>, C<amount>, C<transaction_time>, C<previous_balance>, 
C<new_balance>, C<transaction_date> and C<transfer_id>. The class has a many to many relationship with the C<Bank::Account> class implemented through 
the C<Bank::Transactions> class. This declaration feels incorrect as a transaction may belong to a single account in this solution, but the relationship 
provides access to the bank account information directly from the C<Bank::Transactions::Single> objects. It also has a one to one relationship with the 
C<Bank::Transactions::Type> class.


=item C<Bank::Transactions::Type>


This class represents the C<transaction_type> table in the database. It has 2 columns: C<id> and C<name>.
The class implements a one to one relationship with the C<Bank::Transactions::Single> class. 
The name values are given: 'credit' and 'debit'.

=back

=head2 Methods

=over 12

=item C<Bank::Account>

C<add_transaction> - it changes the balance of the related account according to type and amount of the transaction. Parameters are C<type> and C<amount>.

C<account_statement> - it creates a plain text account statement - similar to that the C<atm_statement.cgi> generates - and returns it as a single string scalar. 
	
C<apply_currency_format> - it applies currency symbol and decimal place indication to a given amount. It has an C<amount> parameter and returns a formatted string scalar.

C<overdraft_alert> - it sends an email to the account owners when the account balance drops to negative.
   
C<send_statement> - it sends the statement as an email to the account owners.
   
C<send_email> - this is a method, that implements the email sending. Its parameters are C<recipient>, C<sender>, C<subject> and C<message>.
   
C<add_transfer> - this method runs two transactions one after the other against two accounts, where one represents the sender and the other the recipient. It changes the 
balance of the two related accounts according to their role in the transactions, and makes a note of their id in the C<transfer_id> column of each others C<single_transaction> record. It takes two parameters, C<amount> and the targeted C<account_number>.
   
=item C<Bank::Customer>

C<add_customer> - this method creates and account and related ownership. Its parameters are: C<params>, C<account_number>, C<init_balance>, C<first_name>, C<last_name> and C<password>. It returns 1 for fulfilled requests from registered and authenticated users who 
are not yet owners or unregistered users, 0 for authenticated registered users who are already owners or unauthenticated registered users.

=item C<Bank::Person>

C<add_digest> - this method creates a cryptographic hash (digest) - using the Perl crypt function - form a given password and returnes it. Its parameter is C<password>.

C<check_password> - it checks if a generated digest is identical with the one stored in the C<person> table. It has a C<digest> parameter and returns boolean result (1 for identical values, zero for different ones).

C<check_digest> - almost the same as above, it just matches a given digest with a stored one. It has a C<digest> parameter and returns boolean result (1 for identical values, zero for different ones).

C<create_salt> - this method creates and returns the visible part of the digest, a random two character string.

=item C<Bank::Transactions::Single>

C<type> - this is an accessor method example of how to bridge the different naming conventions of the type value in the HTML template and the database in order to populate statement rows in a single loop..

C<transfer> - this is an addition to the statement loop to extract, convert and incorporate transfer data (targeted account number and transfer direction) into the statement lines.

=back

=head1 AUTHOR

Written by Peter Scott, author of the OReilly School of Technology Perl courses and modified by Csaba Gaspar.

=head1 DEPENDENCIES

L<Class::DBI>, L<Cwd>, L<Email::Sender::Simple>, L<Email::Simple>, L<Email::Simple::Creator>, .

=head1 SEE ALSO

L<atm_main.cgi>, L<atm_setup.cgi>, L<atm_statement.cgi>, L<MyTemplate.pm>

=cut
