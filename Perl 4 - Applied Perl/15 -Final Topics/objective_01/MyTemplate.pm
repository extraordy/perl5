package MyTemplate;
use strict;
use warnings;

use base 'HTML::Template';

use CGI qw(header);
use File::Basename;

sub new
{
  my ($basename) = fileparse( $0, '.cgi' );
  return shift->SUPER::new( filename          => "$basename.tmpl",
                            die_on_bad_params => 0 );
}

sub html_output
{
  return header() . (shift->SUPER::output);
}


1;