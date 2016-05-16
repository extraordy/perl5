package MyTemplate;
use strict;
use warnings;

# MyTemplate.pm is a custom template tool module of the Automated Teller Machine 
# application (First Bank of O'Reilly) created as a final project in the O'Reilly 
# School of Technology Applied Perl course.

# Loading HTML::Template module and inheriting from it

use base 'HTML::Template';

# Using features from CGI and File modules

use CGI qw(header);
use File::Basename;


# new
# ---
# Params:  N/A
# Returns:  HTML::Template object 

# Returns a new HTML::Template object with the same name as the caller script.


sub new
{
  my ($basename) = fileparse( $0, '.cgi' );
  return shift->SUPER::new( filename          => "$basename.tmpl",
                            die_on_bad_params => 0 );
}


# html_output
# -----------
# Params:  N/A
# Returns:  HTML::Template object 

# Calls the output method of the actual HTML::Template object.


sub html_output
{
  return header() . (shift->SUPER::output);
}
	
1;

__END__

=head1 NAME

MyTemplate.pm - The custom template tool module of the Automated Teller Machine application (First Bank of O'Reilly)
created as a final project in the O'Reilly School of Technology Applied Perl course.

=head1 USAGE

Use this module in interactive CGI files to provide dynamic HTML content using a template file named 
after the CGI file.

C<use MyTemplate;>

=head2 Methods

=over 12

=item C<new>

Returns a new HTML::Template object with the same name as the caller script.

=item C<html_output>

Calls the output method of the actual HTML::Template object.

=back

=head1 AUTHOR

Written by Peter Scott, author of the OReilly School of Technology Perl courses.

=head1 DEPENDENCIES

L<CGI>, L<File::Basename>

=head1 SEE ALSO

L<atm_main.cgi>, L<atm_setup.cgi>, L<atm_statement.cgi>, L<Bank.pm>

=cut
