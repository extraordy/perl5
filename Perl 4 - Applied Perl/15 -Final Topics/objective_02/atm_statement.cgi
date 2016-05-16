#!/usr/local/bin/perl
use strict;
use warnings;


# atm_statement.cgi is he statement component of an Automated Teller Machine application 
# (First Bank of O'Reilly) created as a final project in the O'Reilly School of Technology 
# Applied Perl course.

# The script cannot be called directly from a URL, as it checks its referer page and if it's
# not the main page, then it just redirects the user to the login screen. It needs a GET type 
# query string parameter as it is integrated into the application template file through an 
# IFRAME and not a FORM. The only parameter it gets is an account number (no authentication 
# is necessary), because the only way to call it is from the already authenticated main page. 

# The statement is a simple list of the basic account information (account number, primary and 
# secondary owners name, current account balance) and a list of detailed transactions and 
# transfers. The application generally expects the currency information as plain numeric data 
# without currency formatting, but it attempts to display currency formatting in the statement. 
# Also, it's supposed to inform the user in regards to the direction of money transfers 
# indicating the target and source account with the direction of the money flow.


use lib qw(/users/cgaspar/mylib/lib/perl5);
use CGI qw(param);
use CGI::Carp qw(fatalsToBrowser);
use MyTemplate;
use Bank;

my $query          = CGI->new;
my $main_page      = "atm_main.cgi";

# HTTP_REFERER carries the web page path and name where atm_statement.cgi was called.
# QUERY_STRING containes the GET type parameter list atm_statement.cgi was called with.  

my $referer = $ENV{'HTTP_REFERER'};
my $query_string = $ENV{'QUERY_STRING'};

# If the call came from the main page exclusively...

if ( $referer =~ /$main_page/ )
{
	# ...and there's a required parameter, which is not an empty value 
	
	 if ( defined $query_string and $query_string ne '' )
	 {
	 
	 	# We create a template object and take over the account number from the 
	 	# query string and create an account object. We start to build the 
	 	# statement header.
	 	
		my $template = MyTemplate->new;
		my $account_number = $query_string;
		my ($account) = Bank::Account->search( account_number => $account_number );
		
		# We need to find the account owners' names
		$template->param( owners => join ', ', map { $_->first_name . " " . $_->last_name } $account->owners );
		
		# The balance is also need to be found, we'll provide it in a proper 
		# currency format.
		 
		my $balance = Bank::Account->apply_currency_format( $account->get( 'balance' ));
		$template->param( account_number => $account_number, balance => $balance );
		
		# Now, we need to work on the transaction list, which we map into an array 
		# of dynamic hashes in a single step. This complex data structure will act 
		# like an iterator in the template and will list the content of the hashes
		# one by one. The complexity of this list comes from the fact, that the money
		# transfer information in the single transaction class is represented only by
		# the transaction id of the counter transaction, while the list expects the 
		# related account number and money flow direction. To collect these information, 
		# an accessor method had to be implemented under the single transaction class 
		# to be incorporated into the transaction list. The final value is called 
		# "transfer" and it is now the last attribute in the mapping. 
		
		my @ATTRS = qw(transaction_date type amount new_balance transfer);
		my @transactions = map { my $t = $_; +{ map { $_, $t->$_ } @ATTRS }} $account->transactions;
		
		# Before we dwploy the list content, we do the currency formatting magic.
		
		for my $transaction ( @transactions )
  		{
	  		my $amount      = $transaction->{'amount'};
	  		my $new_balance = $transaction->{'new_balance'};
	  		
	  		$transaction->{'amount'}      = Bank::Account->apply_currency_format( $amount );
	  		$transaction->{'new_balance'} = Bank::Account->apply_currency_format( $new_balance );
	  	}
		     
		# Here comes the iterator declaration for the template.
		            
		$template->param( transaction_loop => \@transactions );
		
		# We don't have to re-authenticate the user when returning to the main page if we 
		# set the "logged_on" value to true
		
		$template->param( logged_on => 1 );
		print $template->html_output;	
	}
	else
	{
		# There was no valid quey string at the call,
		# we don't have the account number.
		
		my $template = MyTemplate->new;
		print $template->html_output;	
	}
}
else
{
	# The script was called as a stand-alone script outside 
	# of the main page, wich we don't want to allow to save
	# additional authentications.
	
	my $template = MyTemplate->new;
	print $template->html_output;	

}



__END__

=head1 NAME

atm_statement.cgi - The statement component of an Automated Teller Machine application (First Bank of O'Reilly)
created as a final project in the O'Reilly School of Technology Applied Perl course.

=head1 USAGE

Start the main component from a web browser using the following URL:
  C<http://cgaspar.oreillystudent.com/project4/hand_in_15/atm_main.cgi>
  
The script cannot be called directly from a URL, as it checks its referer page and if it's not the main page,
then it just redirects the user to the login screen. It needs a GET type query string parameter as it is  
integrated into the application template file through an IFRAME and not a FORM. The only parameter it gets is 
an account number (no authentication is necessary), because the only way to call it is from the already 
authenticated main page. 

=head1 DESCRIPTION

The statement is a simple list of the basic account information (account number, primary and secondary owners 
name, current account balance) and a list of detailed transactions and transfers. The application generally 
expects the currency information as plain numeric data without currency formatting, but it attempts to display 
currency formatting in the statement. Also, it's supposed to inform the user in regards to the direction of money 
transfers indicating the targeted and source account with the direction of the money flow.

Because it is supposed to demonstrate Perl related knowledge set, it doesn't try to imitate functionality
usually associated with and implemented by client side technologies, so it doesn't provide any feedback 
during user interaction, but its usage is designed to be intuitive.
  
For further technical details please consult the comments in the source code.  

=head1 AUTHOR

Written by Csaba Gaspar.

=head1 DEPENDENCIES

L<CGI>,
L<HTML::Template>,
L<Class::DBI>,
L<MyTemplate.pm>,
L<Bank.pm>.

B<MyTemplate> and  B<Bank> are two custom packages.

=head1 LICENSE AND COPYRIGHT

You are permitted to use, modify, incorporate this code for educational purposes.  

=head1 SEE ALSO

L<atm_main.cgi>, L<atm_setup.cgi>, L<Bank.pm>, L<MyTemplate.pm>,

=cut
