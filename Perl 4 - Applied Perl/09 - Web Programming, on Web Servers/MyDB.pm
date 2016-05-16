package MyDB;
use strict;
use warnings;

use lib qw(/users/cgaspar/mylib/lib/perl5);
use DBI;
use Cwd;

my ($USER) = (cwd() =~ m!/.*?/(.*?)/!);

#------------------------------------------------------------------------------------------------------------			<----- Modified part 1
# Lab 9, Objective 1 

# Our goal is to modify atm_choose.tmpl and MyDB.pm so that the transactions are displayed in their own table 
# after the other account information. The table should have the following columns: Date, Type, Amount, 
# Ending Balance. Each transaction should be displayed with those items broken out separately instead of 
# concatenated together into a single line.

# Please insert your MySQL password here... 

my $PASS   = 'loreley2000';

#------------------------------------------------------------------------------------------------------------	

my $SERVER = 'sql';
my $DB     = $USER;

my $dbh = DBI->connect( "dbi:mysql:database=$DB;host=$SERVER", $USER, $PASS );

sub get_accounts
{
  my $ar = $dbh->selectall_arrayref( 'SELECT * FROM account', { Slice => {} } );
  return @$ar;
}


#------------------------------------------------------------------------------------------------------------			<----- Modified part 2
# Lab 9, Objective 1 

# Since the transaction information of the account status report needs to be structured (to consist of distinct 
# record elements, which we can display in separate HTML cells) we need to alter the get_transaction
# method and then accordingly re-assemble the "transactions" parameter being passed in to param() to comply with 
# the template tool requirements.

sub get_account
{
  my $acct_num = pop;
  
  my $ar = $dbh->selectall_arrayref( 'SELECT * FROM account WHERE account_number = ?', { Slice => {} }, $acct_num );
  my ($account) = @$ar;
  my $transactions = get_transactions( $account->{transactions_id} );
  
  # To satisfy the template tool to be able to separately take the transaction elements, our "transactions"
  # parameter must get an array reference of hash references, where a hash reference represents a single
  # transaction record and its hash keys, which have to be explicitely constructed in map, must correspond 
  # to the template tool parameter elements respectively. 
  
  # The naming convention of the keys and template tool parameters is not necessarily consistent (they come from
  # different systems), hence the associated values may be referred under completely different names in the 
  # database and the template tool. 
  
  $account->{transactions} = [ map { { date 		=> $_->{ transaction_date }, 
                                       type 		=> $_->{ name }, 
                                       amount		=> $_->{ amount }, 
                                       ending_balance 	=> $_->{ new_balance } } } @$transactions  ];
                                        
  $account->{owners} = get_owners( $account->{customers_id} );
  return $account;
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


#------------------------------------------------------------------------------------------------------------			<----- Modified part 3
# Lab 9, Objective 1 


sub get_transactions
{
  my $transactions_id = shift;
  
  my $sql = <<'EOSQL';
    SELECT s.transaction_date, type.name, s.amount amount, s.new_balance
      FROM transactions t
      JOIN single_transaction s ON t.single_transaction_id = s.id
      JOIN transaction_type type ON s.transaction_type_id = type.id
     WHERE t.id = ?
EOSQL

  # When doing the DBI query to get the transaction records, using the Slice trick we instruct the selectall_arrayref 
  # DBI utility method to return each record as a hashref instead of an arrayref. The keys in each hash will 
  # be the names of the columns of each record returned by the query, this way we can display these distinct values
  # separately.
  
  my $ar = $dbh->selectall_arrayref( $sql, { Slice => {} }, $transactions_id );
  
  # We don't need any additional trick here to flatten these queried values into a single string, we can return the
  # parent element of our multi level data structure, the array reference itself.

  return $ar;
}

#------------------------------------------------------------------------------------------------------------	

1;
