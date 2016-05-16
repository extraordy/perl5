#!/usr/bin/perl
use strict;
use warnings;

# Constant declarations to esnure readability 

my $BUFFER_SIZE 	= 16;
my $LOWEST_PRINTABLE 	= 32;
my $HIGHEST_PRINTABLE 	= 126;
my $REPEAT_COUNT 	= 16;

# The offset for future use 

# my $offset = 0;

# We take one optional command line switch - 
# for the parsing we use a hash to make the code expandable.

my %options = ( -c => 0 );

# We take one required command line argument - if we don't 
# get any, we terminate the program.

scalar(@ARGV) or die "Usage: $0 [<-c>] <binary file>\n";

# If we have command line arguments, we need to find out. 
# if option -c is set.

exists $options{$_} and $options{$_}++ foreach @ARGV; 

# The option -c was set, so we drop it from the argument list.

$options{$_} and shift foreach keys %options;

# We need to make sure we have the required file name argument, 
# too, in the command line. 

my $binary_file = shift or die "Usage: $0 [<-v>] [<-i>] <pattern> [<file>]\n";

# If the file name argument was provided, we need to open the 
# file for reading.

open my $fh, '<', $binary_file or die "Couldn't read file: $!\n";

# We start a loop to load data into the buffer in 16-byte 
# long chunks

while ( read $fh, my $buffer, $BUFFER_SIZE ) 
{	
	# Implementing the offset is not so hard from here
	
        # printf "%08X --- ", $offset; 

	# If we have option -c set, we need to handle printable data
	# separately, the rest should be printed as their haxadecimal
	# representation.	
	
	if ( $options{'-c'} ) 
	{
		# The following ternary operator is checking if the data
		# is between 32 and 126 inclusively.
	
		(( $_ >= $LOWEST_PRINTABLE and $_ <= $HIGHEST_PRINTABLE ) ? 
			
			# If the actual unpacked character in the loop 
			# satisfies the condition, we'll print it as a 
			# character. 
			
			dumper( "%2c", $_ ) : 
			
			# If it is not printable, we print it as a 
			# hexa decimal code. Half-baked unpack template 
			# needed to be reconsidered.
			
			dumper( "%02X", $_ )) foreach unpack( "(C)$REPEAT_COUNT", $buffer );
	}
	
	# If option -c is not set, we print each unpacked value from the 
	# buffer as a hexadecimal value.
	
	else
	{
			# We print everything as a hexa decimal code. 	
	
			dumper( "%02X", $_ ) foreach unpack( "(C)$REPEAT_COUNT", $buffer );
	}

	# This is the line which sums up the offset value

	# $offset += $BUFFER_SIZE;
	
	# After the whole buffer is processed, we jump to the beginning of 
	# the next line.
	
	print "\n";

}

# To make some code reusable, this small subroutine does the printing.
# It has two arguments: a template to format the output with and the 
# value to be printed. 

sub dumper
{
 	my ( $template, $data ) = @_;
 	
 	# printf will send the formatted value to STDOUT. In the 
 	# template string we use capital X in order to get capital
 	# letters in the hexadecimal code, which makes the layout 
 	# nice and homogeneous. 
 	 	
	printf( "$template ", $data);
}