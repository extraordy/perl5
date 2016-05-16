package MySQL_Common;
use strict;
use warnings;

BEGIN { our @ISA = 'Exporter' }
our @EXPORT_OK = qw( $USER $PASS $SERVER $DB );

our $USER   = $ENV{USER};
our $PASS   = ask_pass();
our $SERVER = 'sql';
our $DB     = $USER;

sub ask_pass
{
  system "stty -echo";
  print "Password: ";
  chomp(my $word = <STDIN>);
  print "\n";
  system "stty echo";
  return $word;
}

1;