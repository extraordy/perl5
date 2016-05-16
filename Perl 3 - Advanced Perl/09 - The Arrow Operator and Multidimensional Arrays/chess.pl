#!/usr/bin/perl
use strict;
use warnings;

# This two dimensional array stores the value of each position on the board
my @board;

my $index;

# These arrays store the movements in a timely manner

my @froms;
my @tos;

$index = 0;

# the following line stores the initial state of our board in the matrix. 

chomp( $board[ $index++ ] = [ split ] ) while <DATA>; 		

# The following moves belong to a historical chess game between Viktor Korchnoi and Boris Spassky
# Sicilian, Dragon, Levenfish Opening Variation, 12 moves

# Black resigned because he simply didn't have a reasonable move. This game took place in Leningrad 
# Palace of Pioneers during a session of simultaneous game which Korchnoi (17 years old) gave. After 
# the game ended Spassky (11 years old) burst into tears.

move(\@board, 'e2', 'e4');
move(\@board, 'c7', 'c5');
move(\@board, 'g1', 'f3');
move(\@board, 'd7', 'd6');
move(\@board, 'd2', 'd4');
move(\@board, 'c5', 'd4');
move(\@board, 'f3', 'd4');
move(\@board, 'g8', 'f6');
move(\@board, 'b1', 'c3');
move(\@board, 'g7', 'g6');
move(\@board, 'f2', 'f4');
move(\@board, 'c8', 'g4');
move(\@board, 'f1', 'b5');
move(\@board, 'b8', 'd7');
move(\@board, 'b5', 'd7');
move(\@board, 'd8', 'd7');
move(\@board, 'd1', 'd3');
move(\@board, 'e7', 'e5');
move(\@board, 'd4', 'f3');
move(\@board, 'g4', 'f3');
move(\@board, 'd3', 'f3');
move(\@board, 'd7', 'g4');
move(\@board, 'c3', 'd5');

# Let's print the board, it will show only the final state of the game

print_board (\@board); 

# This routine moves the piece at location $from in the board pointed
# to by $bref to the location $to. (So afterwards, whatever was in
# $from is now in $to and $from is blank.) 

sub move
{
	
	my ($bref, $from, $to) = @_;	
	
	# Sinece our matrix indeces don't follow the traditional positioning
	# on the board, we need two hashses (one for the rows, one for the columns) 
	# to translate them. 
	
	my %columns = qw( a 1 b 2 c 3 d 4 e 5 f 6 g 7 h 8 );
	my %rows    = qw( 1 8 2 7 3 6 4 5 5 4 6 3 7 2 8 1 );	
	
	
	# If the from position formally acceptable
	
	if ( $from =~ /([a-h])([1-8])/i )
	{
		# We split and store the column and row value of the "from" position.
		 
		my $from_column = $1;
		my $from_row    = $2;
					
		if ( $to =~ /([a-h])([1-8])/i )
		{
		
			# The position values are accepted, so we store them.
			
			push @froms, $from;
			push @tos, $to;

			# We split and store the column and row value of the "to" position.	
							
			my $to_column = $1;
			my $to_row    = $2;
				
			# We save the content of the "from" position into a temporary variable
		
			my $piece = $bref->[ $rows{ $from_row } - 1 ][ $columns{ $from_column } - 1 ];
			
			# We make the original from position blank.
			
			$bref->[ $rows{ $from_row } - 1 ][ $columns{ $from_column } - 1 ] = "--";	
	
			# Finally we set the temporarily stored value into the "to" position.
					
			$bref->[ $rows{ $to_row } - 1 ][ $columns{ $to_column } - 1 ] = $piece; 
		}		
	}	
}


# This routine prints the board which is passed to it. 
	
sub print_board
{
	  my $board_ref = shift;
	  	  	
	  $index = 8;
	  
	  # We create a list of the movements in pairs (when both white and black steps)
	  
	  print "\nList of moves on the board:\n\n";

	  for (my $i = 0; $i < @froms; $i+=2)
	  {
	  	if ( exists $froms[$i+1] )
	  	{
		  	printf "\t%02d.  W: %s -> %s  B: %s -> %s\n", $i/2+1, $froms[$i], $tos[$i], $froms[$i+1], $tos[$i+1]; 
		}
		else
		{
			# When the game ends with white's last step.
			
			printf "\t%02d.  W: %s -> %s\n", $i/2+1, $froms[$i], $tos[$i]; 
		} 
	  }
	  
	  # And here comes the board
	  
	  print "\n  ", "-" x 41, "\n";
	  
	  for my $row ( @$board_ref )
	  {

		# We indicate the row number.  	

		print $index--, " ";
		for my $column ( @$row )
		{
		 	print "| $column ";
		}
		print "|\n  ", "-" x 41, "\n";
	  }
	  
	  # The traditional column indication comes at the bottom.
	  
	  print "     a    b    c    d    e    f    g    h\n\n";
} 

__END__
Br Bk Bb BQ BK Bb Bk Br
Bp Bp Bp Bp Bp Bp Bp Bp
-- -- -- -- -- -- -- --
-- -- -- -- -- -- -- --
-- -- -- -- -- -- -- --
-- -- -- -- -- -- -- --
Wp Wp Wp Wp Wp Wp Wp Wp
Wr Wk Wb WK WQ Wb Wk Wr