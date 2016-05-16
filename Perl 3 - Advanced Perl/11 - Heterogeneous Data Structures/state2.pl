#!/usr/bin/perl
use strict;
use warnings;

# We'll use the Dumper()function of the Data::Dumper module to display the content of 
# the "state" hash.

use Data::Dumper;

my %state;
my @names;

# We have a required command line parameter, the path of the data file:
# /software/Perl3/state_full.data

die "Usage: $0 <data_file>\n" unless @ARGV;

while ( <> )
{
	chomp;
	my ($abbreviation, @fields) = split /\s*\|\s*/;
	@names = @fields and next if $abbreviation eq 'key';
	@{ $state{$abbreviation} }{@names} = @fields;	
}

# After we initialized the "state" hash, we add an interactive loop to input additional
# largest cities, options for the user to dump out the entry for a given state, and to exit. 

for ( prompt(); <STDIN>; prompt() )
{
	chomp; 
	
	# The input line needs to be parsed to eliminate invalid commands and parameters.
	# The single line is split up into maximum three pieces (the first two words will 
	# represent the command and state abbreviation). We stop splitting the line after 
	# the second space, because the third parameter represents the city, which name 
	# can contain spaces. If the input line is empty, we just ignore it.
	
  	parse_cmd( split( " ", $_, 3 )) if $_ ne "";
}

# This subroutine mimics a menu prompt

sub prompt { print "(Q)uit, (D)ump <abbr>, (I)nput <abbr> <city>: " }

# This subroutine is the command line parser

sub parse_cmd
{
	my ( $cmd, $abbr, $city ) = @_;
	
	# The user wants to quit, "Q" was entered.
	
	exit if	$cmd =~ /^q$/i;
	
	# We have two additional valid commands: "D" AND "I" (dump and input).
	
	die "Invalid command\n" if ! ( defined $cmd and length $cmd ) or $cmd !~ /^[di]$/i;
	
	# If the command is "D", we can expect a valid state abbreviation following the command.
	
	die "Invalid command\n" if $cmd =~ /^d$/i and ! ( defined $abbr and length $abbr );
	
	# If the command is "I", we can expect a city name, too, following the valid state abbreviation.
	
	die "Invalid command\n" if $cmd =~ /^i$/i and ( ! ( defined $abbr and length $abbr ) or ! ( defined $city and length $city ) );
	
	# Here come the two subroutines to handle the data dump and the extension of the "largest city"
	# attribute from s single scalar to an anonymous array reference.
	
	dump_state( \%state, uc $abbr ) if $cmd =~ /^d$/i;
	input_state( \%state, uc $abbr, $city ) if $cmd =~ /^i$/i; 
}

sub dump_state
{
	my ( $state_ref, $abbr ) = @_;	
	print Dumper $state_ref->{$abbr};
} 

sub input_state
{
	my ( $state_ref, $abbr, $city ) = @_;
	
	# The dereferencing is shorter if we create a constant for the key we intend to change
	
	my $ATTR = "largest_city";
	
	# If our key is associated with a scalar, the ref() function will return an empty string.
	# This way we can easily detect, whether we need to replace the scalar with the array 
	# reference first or just add the new elelemt to the previously assigned array.
	
	if ( ! ref $state_ref->{$abbr}{$ATTR} )
	{
		# If the array reference has not already been created for this state, we save the 
		# existing "largest city" value, and assign an anonymous array reference to it.
		
		my $tmp_city = $state_ref->{$abbr}{$ATTR};
		
		# Now we can move back the original large city into the array, with the new one.
		$state_ref->{$abbr}{$ATTR} = [$tmp_city, $city];
	}
	else
	{
		# If the array reference exists, we can push the newest values to the end of the 
		# array.
		
		push @{$state_ref->{$abbr}{$ATTR}}, $city;		
	}	
}