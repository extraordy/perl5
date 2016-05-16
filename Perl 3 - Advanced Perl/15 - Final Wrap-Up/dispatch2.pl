#!/usr/bin/perl
use strict;
use warnings;

# We must remove the static initializations of the hashes of the original solution.

my %inventory;
my %room_contents;
my %location;
my %exit;

# We need to populate our hashes from an external data file. 

my $DATA_FILE = '/software/Perl3/dungeon';

# We have to implement the additional command "go", which takes one argument, and moves 
# us in the direction indicated, provided it is a valid exit from our current location. 

my %verb = ( give => \&give, drop => \&drop,
             take => \&take, kill => \&kill,
             look => \&look, have => \&inventory, 
             slay => \&slay, go => \&go, 
             quit => sub { exit } );

# First, we need to initialize our hashes.

init( \$DATA_FILE, \%inventory, \%room_contents, \%location, \%exit );

for ( prompt(); $_ = <STDIN>; prompt() )
{
  chomp;
  next unless /(\S+)(?:\s+(.+))?/;
  $verb{$1} or warn "\tI don't know how to $1\n" and next;
  $verb{$1}->($2);
}

sub prompt { print "Command: " }

#------------------------------------------------------------------------------------------------------------			<----- Modified part 1
# Lab 15, Objective 1 

# This subroutine populates our hashes, which are passed to the subroutine by reference. 

sub init 
{
	my ( $data_file_ref, $inventory_ref, $room_content_ref, $location_ref, $exit_ref ) = @_;
	
	# Creating local constants for the separate regex patterns associated with the hashes
	# helps to comprehend the code easier.
	
	my $INVENTORY_KEY 	= "has";
	my $ROOM_CONTENTS_KEY 	= "contains";
	my $LOCATION_KEY 	= "is in";
	my $EXIT_KEY 		= "goes to";
	
	# We need to open a filehandle for reading the data file. If the opening fails,
	# we terminate the program.
	
	open( my $fh, '<', $$data_file_ref ) or die "Could not open file '$$data_file_ref ' $!";
	
	# We will read up the whole file into a single scalar.
	
	$_ = join '', <$fh>;	
	
	# This way we can use the multiline regex modifier with its associated anchors and 
	# especially the global matching feature. Here's the core part of the initialization.
	
        # We need to loop through the multiline content of the scalar for each hash with a 
        # different regex pattern, matching it globally. Our regex captures will be used to 
        # create the particular inner hash(es) by initializing them (autovivification).
	
	$inventory_ref->{ $1 }{ $2 }	 = 1  while /^(\w+) $INVENTORY_KEY (\w+)$/mg;
	$room_content_ref->{ $1 }{ $2 }  = 1  while /^(\w+) $ROOM_CONTENTS_KEY (\w+)$/mg;
	$location_ref->{ $1 } 	         = $2 while /^(\w+) $LOCATION_KEY (\w+)$/mg;
	$exit_ref->{ $1 }{ $2 } 	 = $3 while /^(\w+) (\w+) $EXIT_KEY (\w+)$/mg;
	
	# Since we didn't create a separate code block for the filehandle, we want to 
	# close it explicitly (it just feels a better practice, although Perl would take
	# care of it implicitly).
	
	close $fh;	
}

#------------------------------------------------------------------------------------------------------------

sub give
{
  local $_ = shift;
  /(\S+)\s+to\s+(\S+)/ or return warn "\tGive what to who?\n";
  delete $inventory{me}{$1} or return warn "\tYou don't have a $1\n";
  $inventory{$2}{$1}++;
  print "\tGiven\n";
}

sub drop
{
  my $what = shift;
  delete $inventory{me}{$what} or return warn "\tYou don't have a $what\n";
  my $here = $location{me};
  $room_contents{$here}{$what}++;
  print "\tDropped\n";
}

sub take
{
  my $what = shift;
  my $here = $location{me};
  delete $room_contents{$here}{$what} or return warn "\tThere's no $what here\n";
  $inventory{me}{$what}++;
  print "\tTaken\n";
}

sub inventory
{
  for my $have ( keys %{ $inventory{me} } )
  {
    print "\tYou have a $have\n";
  }
}

#------------------------------------------------------------------------------------------------------------			<----- Modified part 2
# Lab 15, Objective 1 

# We need to extend the "look" subroutine to report possible exits

sub look
{
  my $here = $location{me};
  print "\tYou are in the $here\n";
  for my $around ( keys %{ $room_contents{$here} } )
  {
    print "\tThere is a $around on the ground\n";
  }
  for my $actor ( keys %location )
  {
    next if $actor eq 'me';
    print "\tThere is a $actor here\n" if $location{$actor} eq $here;
  }
  
  # Here's the addition: if our current location has any exits,
  # we just list them.
  
  if ( keys %{ $exit{ $here } } )
  { 
	  print "\tThere are exits leading ";
	  print join(', ', keys %{ $exit{ $here } });	  
	  print "\n";
  }
}

#------------------------------------------------------------------------------------------------------------	

sub kill
{
	my $finish_ref = get_finish_ref( 'kill' );	
	$finish_ref->( $_[0] );    
}

sub slay
{
	my $finish_ref = get_finish_ref( 'slay' );	
	$finish_ref->( $_[0] );  
}

sub get_finish_ref
{
	my $verb = shift;
	
	return sub { 

		local $_ = shift;
		  
		/(\S+)\s+with\s+(\S+)/ or return warn "\t\u$verb who with what?\n";
		$inventory{me}{$2} or return warn "\tYou don't have a $2\n";
		my $here = $location{me};
		my $its_at = $location{$1} or return warn "\tNo $1 to $verb\n";
		$its_at eq $here or return warn "\tThe $1 isn't here\n";
		delete $location{$1};
		my $had_ref = delete $inventory{$1};
		$room_contents{$here}{$_}++ for keys %$had_ref;
		print "\t\u${verb}ed!\n";
		
	};
}

#------------------------------------------------------------------------------------------------------------			<----- Modified part 3
# Lab 15, Objective 1 

# The "go" subroutine makes it possible to move from location to location through the exits
# associated with locations.

sub go
{
	my $where = shift;
	
	
	# If the argument value is defined in the "exit" hash...
	
	if ( defined $exit{ $location{ me }}{ $where } )
	{
		# ...we assign it to our current location. 
		
		$location{ me } = $exit{ $location{ me }}{ $where }; 
	}
	else
	{
		# Otherwise we just warn the user.
		 
		return warn "\tCan't go $where from here\n";
	}
	
}

#------------------------------------------------------------------------------------------------------------		