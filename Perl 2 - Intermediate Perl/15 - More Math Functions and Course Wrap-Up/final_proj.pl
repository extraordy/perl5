#!/usr/bin/perl
use strict;
use warnings;

# Global variable declarations 

my $order;
my @allow;
my @deny;

# Global constant declarations

my $IP_ADDRESS  = 1;
my $DOMAIN_NAME = 2;

my $ALLOW = 1;
my $DENY  = 2;

# The parse_params subroutine processes the data entry from files passed as command line
# arguments or from the Standard Input. Since we avoid passing multiple arrays as 
# subroutine arguments, the subroutine works on global array variables.

parse_params();

# The evaluate_params subroutine takes addresses from the user and evaluates them 
# depending on the current access rules.  

evaluate_params();

# Subroutine declarations 

sub parse_params
{
	my $allow_index = 0;
	my $deny_index  = 0;

	# The files containing access rules are passed as command line arguments
	# or they come from STDIN, so there's no need to use explicite file 
	# handle.
	
	while ( <> )
	{
		chomp;
		
		# We are looking for the ORDER directive
		
		if ( /\Aorder / )
		{		
			# If we have one, we need to interpret it, but only two regular
			# options exist.
			
			if ( /\Aorder ((?:allow,deny)|(?:deny,allow))/i )
			{
				# If we find more than one ORDER directives, we need to warn
				# the user and use the latest one.
				
				warn "Multiple ORDER directives in input\n" if defined $order; 
				$order = $1;

			}
			else
			{
				# I we can't interpret the ORDER directive, we warn the user 
				# and ignore the value.
				
				warn "Irregular ORDER directive in input\n" ;
			}
		}
		
		# Beside the ORDER directive, we can have ALLOW and DENY directives. They are 
		# followed by either IP addresses or domain names, and those must match certain 
		# format to be acceptable.
		
		elsif ( /\Aallow from / )
		{
			/\Aallow from ((?:\b(?:\d{1,3}\.){1,3}\d{1,3}\b)|(?:\b(?:\w{1,}\.){1,}\w{1,}\b))/ ? $allow[$allow_index] = $1 : warn "Irregular 'allow' parameter: $1"; 
			$allow_index++;
		} 
		elsif ( /\Adeny from / )
		{
			/\Adeny from ((?:\b(?:\d{1,3}\.){1,3}\d{1,3}\b)|(?:\b(?:\w{1,}\.){1,}\w{1,}\b))/i ? $deny[$deny_index] = $1 : warn "Irregular 'deny' parameter: $1"; 
			$deny_index++;
		}	
	}
	
	die "No ORDER directive in input\n" if !defined $order;
}

sub evaluate_params
{
	# The evaluation is based on a looping menu
	# where we accept only a single 'Quit' command
	# and IP addresses or domain names.
	
	for ( menu(); my $entry = <STDIN>; menu() )
	{
		chomp $entry;
		
		# We catch the quit command here if the
		# user decides to leave the loop.
		
		exit if $entry =~ /quit/i;
		
		# If the entry was an empty string, we ignore it,
		# otherwise attempt to find any matches among the 
		# access rules.
		
		matching( $entry ) if $entry ne "";
	}
}

sub menu
{
	print "Input address to test: ";  
}

sub matching
{
	my $address = shift;
	
	# The entry is split up to its building blocks to be able to check
	# matching with IP address prefixes or domain name suffixes as well.
		
	my @address_blocks = split( /\./, $address );
	
	# We need to know if we are dealing with an IP address or a domain name here,
	# as the most significant parts in IP prefixes are on the left side and they are on
	# the right side in the domain name suffixes. Significant prefixes and suffixes can
	# match fully qualified domain names and full IP addresses. 
	
	my $address_type = ( $address_blocks[0] =~ /\A\d{1,3}\z/ ? $IP_ADDRESS : $DOMAIN_NAME );	
	
	my $allow_match = 0;
	my $deny_match  = 0;
	
	# Depending on the address type and the rule directives we call the match_address 
	# subroutine, which returns 1 if there's a match for the specific directive and 0
	# if there's no match. 
	
	if ( $address_type == $IP_ADDRESS )
	{		 
		$allow_match = match_address( $IP_ADDRESS, $ALLOW, @address_blocks );
		$deny_match  = match_address( $IP_ADDRESS, $DENY,  @address_blocks );	 
	}
	else
	{		
		$allow_match = match_address( $DOMAIN_NAME, $ALLOW, reverse @address_blocks );
		$deny_match  = match_address( $DOMAIN_NAME, $DENY,  reverse @address_blocks );	 	
	}
	
	# Depending on the ORDER directive, logical combinations of our 'allow' and 'deny' 
	# rules determine whether a resource is allowed to be accessed from a particular 
	# address or not.      
	
	# Match 			Allow,Deny result 			Deny,Allow result
	# ----------------------------------------------------------------------------------------------------------
	# Match Allow only 		Request allowed 			Request allowed
	# Match Deny only 		Request denied 				Request denied
	# No match 			Default to second directive: Denied 	Default to second directive: Allowed
	# Match both Allow & Deny 	Final match controls: Denied 		Final match controls: Allowed
	
	if ( $order =~ /allow,deny/i )
	{			
		(( !$allow_match && !$deny_match ) || ( $allow_match && $deny_match ) || ( !$allow_match && $deny_match )) ? print "REJECTED\n" : print "ALLOWED\n";
	}
	else
	{
		(( !$allow_match && !$deny_match ) || ( $allow_match && $deny_match ) || ( $allow_match && !$deny_match )) ? print "ALLOWED\n" : print "REJECTED\n";
	}	
}

sub match_address
{
	# We have to be careful with passing the array,
	# it must be the last argument, otherwise it eats 
	# up the scalars, as well.

	my ($type, $target, @blocks) = @_;	
	my $result = 0;

	# target tells if we are matching allow rules or deny rules
	
	my @rules = ( $target == $ALLOW ) ? @allow : @deny;
	my $chunks;
	
	# We need to use nested loops, the label makes it possible
	# to terminate both loops when we have a match deep inside
	
	OUTER:
	for my $index ( 0 .. $#blocks )
	{
		# Based on the value of the type variable, we can easily
		# permutate the building blocks of our address, segment by 
		# segment: IP addresses are built from left to right,
		# domain names are built from right to left as they have 
		# their most significant parts on different sides.
		
		( $type == $IP_ADDRESS ) ? 
			( $chunks .= ( $index == 0 ) ? "$blocks[$index]" : ".$blocks[$index]" ) : 
			( $chunks = ( $index == 0 ) ? "$blocks[$index]" : "$blocks[$index].".$chunks ); 
		
		# We loop through the given rules to find matching expressions
		
		for my $address ( @rules ) 
		{
			if ( $address =~ /\A$chunks\z/ )
			{
				# If we find a match, we return 1
				# and terminate the loops.
				
			 	$result = 1;
			 	last OUTER;
			}
		}		
	}	
	
	return $ result;
}