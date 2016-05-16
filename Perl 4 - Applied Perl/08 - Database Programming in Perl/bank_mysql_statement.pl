#!/usr/local/bin/perl
use strict;
use warnings;

#------------------------------------------------------------------------------------------------------------			<----- Modified part 1
# Lab 8, Objective 1 
#
# Our goal is that bank_mysql_statement.pl prints out the statement just for the account number that is 
# entered on the command line.

# We need to adapt our account related query to the new requirements: we may want to choose a different DBI 
# utility method with a different kind of data structure returned. Using Data::Dumper module helps to see 
# what exactly is returned using different DBI methods.

use Data::Dumper;

#------------------------------------------------------------------------------------------------------------	

use lib qw( /users/cgaspar/mylib/lib/perl5 );
use DBI;
use MySQL_Common qw( $USER $PASS $SERVER $DB );

my $dbh = DBI->connect( "dbi:mysql:database=$DB;host=$SERVER", $USER, $PASS );

#------------------------------------------------------------------------------------------------------------			<----- Modified part 2
# Lab 8, Objective 1 

# We take an account number as a command line argument and reminate the program if nothing was provided.

my $account_number = shift or die "Usage: $0 account_number\n";

# The name of the subroutine, wich delivers the result of the account related database query, is altered 
# to singular form indicating that only a single record (or nothing) will be fetched. The account number
# is passed to the subroutine so that the selection is filtered. 

my $account = get_account( $account_number );

# Here we can double check the structure of the returned data if we intend to.

# print "\n", Dumper $account, "\n";

# If the supplied account number doesn't exist in the database, we can catch this checking if the return
# value of the get_account subroutine is defined.


if ( defined $account )
{

  # Since we expect only a single record from the query, we don't need an array of hash references to return, 
  # only a single hash reference. Not in a loop, though, but the same dereferencing will perfectly do here,
  # so we don't need to modify the code of the result list.

  print "Account #: $account->{account_number}\n";
  print "Owner(s): ", get_owners( $account->{customers_id} ), "\n";
  print "Date\tType\tAmount\tBalance\n";
  print "$_\n" for get_transactions( $account->{transactions_id} );
  print "\n";
}
else

# If the account number doesn't exist, we report it to the user.

{
  print "No such account number\n"
}


# The get_account subroutine has to be implemented in a different way to fetch only a single account 
# statement record. If we change the current DBI utility method and filter the SQL statement using
# a WHERE clause, we get a simpler, faster and more reliable query. "selectrow_hashref" is the best 
# choice of method, because it provides only the first record fetched from the database in a form of 
# a hash reference, which ensures that we don't have to change the dereferencing in the code of the 
# result list.

sub get_account
{

  # The value in the where clause is the user supplied account number, which is passed to our 
  # subroutine as an argument, which we need to parse first.
  
  my $acct_id = shift;
  
  # This is the key codeline in this solution: we need to change the DBI method name (from
  # selectall_arrayref to selectrow_hashref to get a single account statement record), alter the 
  # SQL statement (adding a proper WHERE clause to filter the selection and a place holder to 
  # avoid variable interpolation). We also need to extend the method call with an additional 
  # argument, the corresponding value for the SQL statement place holder.
   
  my $hr = $dbh->selectrow_hashref( 'SELECT * FROM account WHERE account_number = ?', undef, $acct_id  );
  
  # Here we return the result of the query in a form of a hash reference.
  
  return $hr;
}

#------------------------------------------------------------------------------------------------------------	

sub get_owners
{
  my $customers_id = shift;
  
  my $sql = <<'EOSQL';
    SELECT CONCAT(p.first_name, ' ', p.last_name)
      FROM person p
      JOIN customers c ON p.id = c.person_id
     WHERE c.id =?
EOSQL
  my $ar = $dbh->selectcol_arrayref( $sql, undef, $customers_id );
  return join ', ' => @$ar;
}


sub get_transactions
{
  my $transactions_id = shift;
  
  my $sql = <<'EOSQL';
    SELECT s.transaction_date, type.name, s.amount, s.new_balance
      FROM transactions t
      JOIN single_transaction s ON t.single_transaction_id = s.id
      JOIN transaction_type type ON s.transaction_type_id = type.id
     WHERE t.id = ?
EOSQL
  my $ar = $dbh->selectall_arrayref( $sql, undef, $transactions_id );
  my @lines;
  for ( @$ar )
  {
    my ($date, $type, $amount, $new_balance) = @$_;
    push @lines, "$date\t$type\t$amount\t$new_balance";
  }
  return @lines;
}