#!/usr/bin/perl
use strict;
use warnings;

# We want the word "slay" to be synonymous with "kill," so the subroutine that gets executed 
# should do exactly the same, except that instead of printing "kill," it should print "slay."
# Our goal is to do this with creating a closure over the particular verb.

# We need to extend the dispatch table with the new command and its associated coderef

 my %verb = ( give => \&give, drop => \&drop,
              take => \&take, kill => \&kill,
              look => \&look, have => \&inventory, 
              slay => \&slay, quit => sub { exit } );

my %inventory     = ( me => { jewel => 1 }, troll => { diamond => 1 } );
my %room_contents = ( cave => { sword => 1 } );
my %location      = ( me => 'cave', troll => 'cave', thief => 'attic' );

for ( prompt(); $_ = <STDIN>; prompt() )
{
  chomp;
  next unless /(\S+)(?:\s+(.+))?/;
  $verb{$1} or warn "\tI don't know how to $1\n" and next;
  $verb{$1}->($2);
}

sub prompt { print "Command: " }

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
}

# The subroutine behind the kill coderef

sub kill
{
	
	# First we get a codref to our closure by passing the 'kill' string literal. 
	
	my $finish_ref = get_finish_ref( 'kill' );	
	
	# Then we pass the "who with what" part of the command directly to the closure
	
	$finish_ref->( $_[0] );    
}


# The subroutine behind the slay coderef

sub slay
{

	# First we get a codref to our closure by passing the 'slay' string literal. 
	
	my $finish_ref = get_finish_ref( 'slay' );	
	
	# Then we pass the "who with what" part of the command directly to the closure
	
	$finish_ref->( $_[0] );  
}

# This subroutine returns the closure coderef for the specific subroutines behind the different 
# "finishing" commands.

sub get_finish_ref
{
	my $verb = shift;
	
	return sub { 

		local $_ = shift;
		
		# And finally here come the interpolation tricks the objective taught us.
		  
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
