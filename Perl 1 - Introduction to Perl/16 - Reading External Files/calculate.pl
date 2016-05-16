#!/usr/bin/perl
use strict;
use warnings;

# The initial number of arguments tell us where the intructions 
# are coming: from STDIN or from file(s)

my $init_arg_num = scalar @ARGV; 
	
my $accumulator; # carries the result of the last calculation
my $response;	 # containes the output of the last calculation

# The diamond oparator will attempt to read @ARGV for files available 
# from command line arguments. If @ARGV carries more than one filename,
# <> will read up their content one by one. If @ARGV is empty, it 
# starts to read STDIN automatically.

while ( defined( my $line = <> ) )
{
	chomp $line;	

	my ($instruction, $value) = split " ", $line, 2;

	# If the instructions are coming from files, we want to show
	# them on the screen before the result of the calculation
	
	if ( $init_arg_num )
	{
		$response = echo_instruction( $instruction, $value );
		print $response;
	}
	
	# To make the repetative core of the program (the calculation) easily reusable, 
	# a "carry_out_instruction" subroutine has been created. It returns a list
	# of two scalars: the new accumulator value and the program feedback.
		
	( $accumulator, $response ) = carry_out_instruction( $accumulator, $instruction, $value );

	print $response;
}

# The subroutine shows each intruction coming from files on the screen 
# before the result feedback

sub echo_instruction
{
	my ( $instruction, $value ) = @_;
	if ( defined( $value ))
	{
		return "$instruction $value\n";
	}
	else
	{
		return "$instruction\n";
	}	
}

# According to the type of the instruction, the subroutine carries out arithmetic
# operations (if any applies) on the value of the accumulator, and returns
# a feedback regarding the result.

sub carry_out_instruction
{

	my ( $accumulator, $instruction, $value ) = @_;
	my $response;
	
	if ( uc $instruction eq 'EQUALS' )
	{
		if ( defined $accumulator )
		{
			$response = " = $accumulator\nOK\n"; 	
		}
		else
		{
			$response = "(undefined)\nOK\n";
		}		
	}
	elsif ( uc $instruction eq 'CLEAR' )
	{
                $accumulator = 0;
		$response = "OK\n";
	}
	elsif ( uc $instruction eq 'PLUS' )
	{
		$accumulator += $value; 
		$response = "OK\n";
	}
	elsif ( uc $instruction eq 'MINUS' )
	{
		$accumulator -= $value;
		$response = "OK\n";
	}
	elsif ( uc $instruction eq 'TIMES' )
	{
		$accumulator *= $value;
		$response = "OK\n";
	}
	elsif ( uc $instruction eq 'OVER' )
	{
		$accumulator /= $value;
		$response = "OK\n";
	}
	else
	{
		$response = "Invalid statement\n";
	}
	
	return ( $accumulator, $response );
}