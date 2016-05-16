#!/usr/local/bin/perl
use strict;
use warnings;


# atm_main.cgi is the main component of an Automated Teller Machine application
# (First Bank of O'Reilly) created as a final project in the O'Reilly School of 
# Technology Applied Perl course.

# This script is a simple but multifunctional interface and the entry point of 
# the ATM application. It provides the user with information, interaction and 
# navigation. The functionalities it provides are:
#  - authenticate users,
#  - gives feedback regarding basic account information,
#  - serves as an automated teller providing transactions (credit or debit) and 
#    money transfer between accounts,
#  - provides account statement on display and in email,
#  - implements an overdraft email alerting.

# Because it is supposed to demonstrate Perl related knowledge set, it doesn't try 
# to imitate functionality usually associated with and implemented by client side 
# technologies, so it doesn't provide any feedback during user interaction, but 
# its usage is designed to be intuitive enough.

use lib qw(/users/cgaspar/mylib/lib/perl5);
use CGI::Carp qw(fatalsToBrowser);
use CGI qw(:all);
use MyTemplate;
use Bank;

my $query          = CGI->new;

# These are the referer pages, HTTP requests coming only from these pages can run the 
# script, requests coming from elsewhere will be redirected to the main page.

my $setup_page     = "atm_setup.cgi";
my $main_page      = "atm_main.cgi";
my $create_page    = "atm_create.cgi";

# We can assign different functionality to each button on the form, this way we can
# use the same template for different tasks.

my $btn_sbmt_logon 	= "Log on";
my $btn_sbmt_change     = "Change";
my $btn_sbmt_send_dw    = "Send";
my $btn_sbmt_send_tr    = "Send";
my $btn_sbmt_print      = "Print";
my $btn_sbmt_logout     = "Log out";
my $btn_sbmt_email     = "Email";

# The HTTP_REFERER standard environmental variable carries the path and name of the
# page from where the HTTP request came.

my $referer = $ENV{'HTTP_REFERER'};

# If the request came from the main page, then we have submitted information. At first,
# these are the user credentials (email address and password), but later on this is 
# the entry point each form in the main template.

if ( $referer =~ /$main_page/ )
{
	# Each form has its own submit button, based on what was pressed we can direct
	# the control flow to the appropriate code and use the relevant part from the
	# template. If we are comming from the log on screen, and and we have submitted
	# information, then we can carry on. Also, coming from other forms will
	# pass this first condition.
	
	if (( defined $query->param('sbmt_logon') and $query->param('sbmt_logon') ne '' ) and ( !grep { not defined CGI::param($_) or CGI::param($_) eq ''} CGI::param() ) or
	    ( defined $query->param('sbmt_change') and $query->param('sbmt_change') ne '') or
	    ( defined $query->param('sbmt_send_dw') and $query->param('sbmt_send_dw') ne '') or
	    ( defined $query->param('sbmt_send_tr') and $query->param('sbmt_send_tr') ne '') or
	    ( defined $query->param('sbmt_email') and $query->param('sbmt_email') ne ''))
	{
		# Now, if the appropriate submit button was actually pressed, we will have
		# its value, which tells us what form was used. If we used any of the following
		# forms, than we may proceed.
		
		if (( $query->param('sbmt_logon') eq $btn_sbmt_logon ) or 
		    ( $query->param('sbmt_change') eq $btn_sbmt_change ) or 
		    ( $query->param('sbmt_send_dw') eq $btn_sbmt_send_dw ) or
		    ( $query->param('sbmt_send_tr') eq $btn_sbmt_send_tr ) or
		    ( $query->param('sbmt_email') eq $btn_sbmt_email ))
		{
			# At this point we have to possess the email address and the password
			# of our current user, so we can create a person object.
			
			my %param = map { $_, $query->param( $_ ) } qw( email from_account_number );
			my $account_holder = Bank::Person->retrieve( email => $param{ email } );
			
			# If the person object is defined, that means we are dealing with a 
			# registered user, an actual account holder. 
			
			if ( $account_holder )
			{
				# Now we successfully identified the user, but we still need to
				# authenticate their password.
				
				my $ID_legit;
				
				# When the user is arriving here from the log on screen,
				# we have his password in among the query parameters. For the 
				# authentication we need to use the password and compare its 
				# crypted version with the user's digest stored in the database.
				 
				if ( $query->param('sbmt_logon') eq $btn_sbmt_logon )
				{
					$param{ password } = $query->param('password');
					$ID_legit = $account_holder->check_password( $param{ password } );
				}
				
				# If the authentication has happened earlier (the HTTP request was
				# sent from the same main page, but from a different form), we don't
				# want the user to repeat the log on process, so we just pass the digest 
				# along the other query parameters. This is not the safest way to 
				# implement an implicit authentication (as the digest becomes visible 
				# in the HTML code), but because we keep an eye on the page from where 
				# a valid request can come, there's not much chance to use the digest 
				# outside of the main page.
				
				elsif (( $query->param('sbmt_change') eq $btn_sbmt_change ) or 
				       ( $query->param('sbmt_send_dw') eq $btn_sbmt_send_dw ) or
				       ( $query->param('sbmt_send_tr') eq $btn_sbmt_send_tr ) or
				       ( $query->param('sbmt_email') eq $btn_sbmt_email ))
				{
					$param{ digest } = $query->param('digest');
					$ID_legit = $account_holder->check_digest( $param{ digest } );
				}
				
				# Now we identified and authenticated the user, it's safe to find out 
				# if there is any spefific request we need to handle.
				
				if ( $ID_legit )
				{
					my $template = MyTemplate->new;
					
					# The main screen content is account dependent, each available
					# functionality is associated with a particular account. The actual
					# account is shown in the account summary section is a drop-down 
					# element, from where the user can select another account if there
					# is any other. For this account selection option we need to create
					# a list of available (own) accounts to display them in the drop-down
					# element in of the template. 
					
					# The FROM account numbers
					
					my @from_acct_nums = map { $_->get( 'account_number' ) } $account_holder->accounts();
					my $from_account_number = ( defined $param{ from_account_number } and $param{ from_account_number } ne '') ? $param{ from_account_number } : $from_acct_nums[0];
					$param{ from_account_loop } = ( [ map { { from_account_number => $_, checked => ( $_ eq $from_account_number ? ' selected' : '' ) }} @from_acct_nums ] );
					 
					 
					# The account transfer functionality relies on two account numbers. The 
					# user can choose from any available (not just own) accounts, so we
					# need to create another extended list of target accounts, where the 
					# user can transfer fund.  
					 
					# The TO account numbers
					
					my @to_acct_nums = map { $_->get( 'account_number' ) } grep { $_->get( 'account_number' ) ne $from_account_number } Bank::Account->retrieve_all;
					my $to_account_number   = ( defined $param{ to_account_number } and $param{ to_account_number } ne '') ? $param{ to_account_number } : $to_acct_nums[0];					                                                            
	                                $param{ to_account_loop } = ( [ map { { to_account_number => $_, checked => ( $_ eq $to_account_number ? ' selected' : '' ) } } @to_acct_nums ] );
					
					# Now, it's time to create an account object for the actual account 
					# to get information for the account summary.
					
					my $account = Bank::Account->retrieve( account_number => $from_account_number );
					$param{ owners } = ( join ', ', map { $_->first_name . " " . $_->last_name } $account->owners );
					
					# Here starts the deposit/withdrawal section. If the HTTP request came 
					# from the deposit/withdrawal section, the user submitted the form by 
					# pressing the sbmt_send_dw button. We have all necessary information 
					# (transaction type and amount)to add the requested transaction to 
					# the database.
					
					if ( $query->param('sbmt_send_dw') eq $btn_sbmt_send_dw )
					{				
						$account->add_transaction( $query->param('type'), $query->param('dw_amount') ) 
						if ( defined $query->param('type') and $query->param('type') ne '' ) and 
						   ( defined $query->param('dw_amount') and $query->param('dw_amount') ne '' );	
					}
					
					# This is the transfer section, the user submitted the transfer form 
					# pressing the sbmt_send_tr button. We can initiate the transfer using the 
					# passed form field values (amount and target account number). 
					 
					if ( $query->param('sbmt_send_tr') eq $btn_sbmt_send_tr )
					{	
						$account->add_transfer( $query->param('tr_amount'), $query->param('to_account_number'))
						if ( defined $query->param('tr_amount') and $query->param('tr_amount') ne '' ) and 
						   ( defined $query->param('to_account_number') and $query->param('to_account_number') ne '' );
					}
					
					# Here starts the statement sending section. If the user pressed the 
					# sbmt_email button, we send the statement to all owners of the
					# current account.
					
					if ( $query->param('sbmt_email') eq $btn_sbmt_email )
					{	
						$account->send_statement;
					}
	
					my $balance = Bank::Account->apply_currency_format( $account->get( 'balance' ));
					
					# The template parameter values need to be dynamically populated, so 
					# we need to prepare the parameter list before the content is sent to
					# the output. Some of the parameters carry information for the following
					# potential request or the background authentication.  
					
					$param{ balance } = $balance;					
					$param{ from_account_number } = $from_account_number;
					$param{ to_account_number } = $to_account_number;
					$param{ digest } = $account_holder->get( 'digest' );
					$param{ create } = $create_page;				
					$param{ logged_on } = 1;
									
					$template->param( %param );				
					print $template->html_output;
				}
				else # The password is wrong, we redirect the user back to the log on page
				{
					my $template = MyTemplate->new;
					my %param = map { $_, $query->param( $_ ) } qw( email );
					$param{ setup } = $setup_page;
		        		$param{ create } = $create_page;
		        		$template->param( %param );
					print $template->html_output;
				}	
			}
			else # The email address is wrong, so we redirect the user again back to the log on page
			{
				my $template = MyTemplate->new;
				my %param = map { $_, $query->param( $_ ) } qw( email );
				$param{ setup } = $setup_page;
				$param{ create } = $create_page;
	        		$template->param( %param );
				print $template->html_output;

			}
		}
		
		# The user pressed the smbt_logout button to quit
		
		elsif ( $query->param('sbmt_logout') eq $btn_sbmt_logout )
		{
			my $template = MyTemplate->new;
			$template->param( setup => $setup_page );
			$template->param( create => $create_page );
			print $template->html_output;			
		}
		
		# In case we didn't take any other possible scenario into consideration, the
		# control flow will be redirected to the main page here in any circumstances 
		# the one of the declared button was pressed.
		
		else
		{
			my $template = MyTemplate->new;
			$template->param( setup => $setup_page );
			$template->param( create => $create_page );			
		
			print $template->html_output;			
		}
	}
	else # From wherever the HTTP request came, there were no query parameters
	{
		my $template = MyTemplate->new;
		my %param = map { $_, $query->param( $_ ) } qw( email );
		$param{ setup } = $setup_page;
		$param{ create } = $create_page;
	        $template->param( %param );
		print $template->html_output;	
	}
}
else # Page was started directly from the URL field, or referred from an unknown page
{
	my $template = MyTemplate->new;
	$template->param( setup => $setup_page );
	$template->param( create => $create_page );	
	print $template->html_output;			

}

__END__

=head1 NAME

atm_main.cgi - The main component of an Automated Teller Machine application (First Bank of O'Reilly)
created as a final project in the O'Reilly School of Technology Applied Perl course.

=head1 USAGE

Start from a web browser using the following URL:
  C<http://cgaspar.oreillystudent.com/project4/hand_in_15/atm_main.cgi>
  
Use the initial account setup link C<Setup a new account> to create an account and user credentials first.

=head1 DESCRIPTION

This script is a simple but multifunctional interface and the entry point of the ATM application. 
It provides the user with information, interaction and navigation.
The functionalities it provides are:
  - authenticate users,
  - gives feedback regarding basic account information,
  - serves as an automated teller providing transactions (credit or debit) and money transfer between accounts,
  - provides account statement on display and in email,
  - implements an overdraft email alerting.

Because it is supposed to demonstrate Perl related knowledge set, it doesn't try to imitate functionality
usually associated with and implemented by client side technologies, so it doesn't provide any feedback 
during user interaction, but its usage is designed to be intuitive enough.
  
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

L<atm_setup.cgi>, L<atm_statement.cgi>, L<Bank.pm>, L<MyTemplate.pm>,

=cut
