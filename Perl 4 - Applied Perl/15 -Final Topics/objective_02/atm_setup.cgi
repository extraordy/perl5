#!/usr/local/bin/perl
use strict;
use warnings;


# atm_setup.cgi is the setup component of an Automated Teller Machine application
# (First Bank of O'Reilly) created as a final project in the O'Reilly School of 
# Technology Applied Perl course.

# This script doesn't need authentication to be run. It creates an account and stores 
# all kinds of related information (initial balance, primary and secondary owner 
# credentials).


use lib qw(/users/cgaspar/mylib/lib/perl5);
use CGI qw(:all);
use CGI::Carp qw(fatalsToBrowser);
use MyTemplate;
use Bank;

my $query          = CGI->new;

# These are the referer pages, HTTP requests coming only from these pages can run the 
# script, requests coming from elsewhere will be redirected to the main page.

my $main_page      = "atm_main.cgi";
my $setup_page     = "atm_setup.cgi";

# We can assign different functionality to each button on the form, this way we can
# use the same template for different tasks.

my $btn_submit     = "Submit";
my $btn_quit       = "Quit";

# The HTTP_REFERER standard environmental variable carries the path and name of the
# page from where the HTTP request came.

my $referer = $ENV{'HTTP_REFERER'};

# If the request came from the main page, we'll generate the data entry form for the 
# primary account holder.

if ( $referer =~ /$main_page/ )
{

	# We choose a random approach to generate account numbers contrary to the 
	# incremental way we used in the course to spice it up a little bit. First
	# we need to know what account numbers have already been allocated.
	
	my @acct_nums = map { $_->get( 'account_number' ) } Bank::Account->retrieve_all;
	
	# Then we can generate one using a custom subroutine here.
	
	my $new_acct_num = make_acct_num( \@acct_nums );
	
	# When we are done, we can create the template for the data entry indicating the
	# assigned account number.
	
	my $template = MyTemplate->new;
	$template->param( account_number => $new_acct_num );	
	print $template->html_output;	
}

# If the HTTP request comes from the setup page, it can only be a form submit or a quit 
# request, anything other request will be redirected to the main page. Here we'll handle 
# the submit part first.

elsif (( $referer =~ /$setup_page/ ) and ( $query->param('submit') =~ /$btn_submit/ ))
{
	my $add_customer_result = 0;
	
	# The setup provides two kinds of data entry in regards to a single account 
	# number. The first call creates a form for the primary account holder, each
	# following forms generate a data entry for the potential secondary account 
	# holders - if there's any - as long as the user doesn't quit. 
	
	# If this was the first attempt to call the setup script, this form submit means 
	# primary account holder data, but there's a hidden CGI query parameter 
	# (primary), as well, in the template to confirm it.  
	
        if ( $query->param('owner') eq "primary" )
	{
		# All fields are required on the form, so we need to check if the user 
		# submitted any blank one.
		
		if ( !grep { not defined CGI::param($_) or CGI::param($_) eq ''} CGI::param() )
		{
                        # If the form was properly submitted, we assign the submitted 
                        # field name keys and values to a parameter hash to avoid 
                        # using the query parameters directly in subroutine calls as 
                        # subroutine parameters.  
                        			
			my  %call_params = map { $_, $query->param( $_ ) } qw( account_number init_balance first_name last_name password email );
			
			# Using the add_customer method of the Bank::Customer class 
			# we can store now the information we've collected with only
			# a hash reference passed to the method, which points to our 
			# %call_params hash.
			
			
			$add_customer_result = Bank::Customer->add_customer( \%call_params );
			
			# If the new account was successfully created and the primary 
			# cutomer added to the system, we prepare the template for the
			# secondary account holders.
			
			if ( $add_customer_result )
			{			
				my $template = MyTemplate->new();
				my %param = map { $_, $query->param( $_ ) } qw( account_number add_secondary );			
				$param{ account_number } = $query->param('account_number');
				$param{ add_secondary } = 1;
				$template->param( %param );
				print $template->html_output;
			}
			
			# If the account couldn't be created or the primary customer 
			# wasn't added, we prepare the template with a feedback.
			
			else
			{
				my $template = MyTemplate->new();
				my %param = map { $_, $query->param( $_ ) } qw( account_number init_balance first_name last_name password email );
				$param{ primary_failed } = 1;
				$template->param( %param );
				print $template->html_output;
			}
		}
		
		# If some fields were submitted blank, we regenerate the original form with 
		# all the information the user has submitted so far.
		
		else
		{
			my $template = MyTemplate->new();
			my %param = map { $_, $query->param( $_ ) } qw( account_number init_balance first_name last_name password email );
			$template->param( %param );
			print $template->html_output;
		}
			
	}
	else
	
	# When the submit comes from the secondary account holder form, we need to follow 
	# the same root as above with some little differences. This code actually 
	# repetative, it could have been placed into a subroutine, but so many parameters
	# would be involved, I just didn't see the effort as a huge benefit. The code
	# would be cleaner, though.
	
	{

		if ( !grep { not defined CGI::param($_) or CGI::param($_) eq ''} CGI::param() )
		{
			my %call_params = map { $_, $query->param( $_ ) } qw( account_number first_name last_name password email );
			
			$add_customer_result = Bank::Customer->add_customer( \%call_params );
			
			# If the secondary owner added to the system, we prepare the 
			# template for the next potential secondary account owner.
			
			if ( $add_customer_result )
			{			
				my $template = MyTemplate->new();
				my %param = map { $_, $query->param( $_ ) } qw( account_number add_secondary );
				$param{ account_number } = $query->param('account_number');
				$param{ add_secondary } = 1;
				$template->param( %param );
				print $template->html_output;							
			}
			
			# If the secondary account owner could not be added, we prepare 
			# the template with a feedback.
			
			else
			{
				my $template = MyTemplate->new();
				my %param = map { $_, $query->param( $_ ) } qw( account_number first_name last_name password email add_secondary );
				$param{ secondary_failed } = 1;
				$param{ add_secondary } = 1;
				$template->param( %param );
				print $template->html_output;							
			}				
		}
		else
		{
			my $template = MyTemplate->new();
			my %param = map { $_, $query->param( $_ ) } qw( account_number first_name last_name password email add_secondary );
			$param{ add_secondary } = 1;
			$template->param( %param );
			print $template->html_output;
		}
	}
	

}

# when the user is done with setting up the ownership for the new account,
# submitting the form using the quit button redirects the control flow
# to the main page.

elsif (( $referer =~ /$setup_page/ ) and ( $query->param('submit') =~ /$btn_quit/ ))
{
	print $query->redirect($main_page);
}

# In case we didn't take any other possible scenario into consideration, the
# control flow will be redirected to the main page in any circumstances unless
# the submit button was pressed.

else
{
	print $query->redirect($main_page);
}

# The make_acct_num subroutine takes care of generating the new account
# number, which will be a five digit number.

sub make_acct_num
{
	my ( $acct_aref ) = @_;

	my $min = 10001;
	my $max = 99999;
	
	my $num =  $min + int( rand( $max - $min ) );
	
	return $num if not grep( { $_ eq $num } @$acct_aref );
	
	redo; 		
}


__END__

=head1 NAME

atm_setup.cgi - The setup component of an Automated Teller Machine application (First Bank of O'Reilly)
created as a final project in the O'Reilly School of Technology Applied Perl course.

=head1 USAGE

Start the main component from a web browser using the following URL:
  C<http://cgaspar.oreillystudent.com/project4/hand_in_15/atm_main.cgi>
  
Use the initial account setup link C<Setup a new account> to create an account and user credentials first.

=head1 DESCRIPTION

This script doesn't need authentication to be run. It creates an account and stores all kinds of related 
information (initial balance, primary and secondary owner credentials).

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

L<atm_main.cgi>, L<atm_statement.cgi>, L<Bank.pm>, L<MyTemplate.pm>,

=cut
