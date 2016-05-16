#!/usr/bin/perl
use strict;
use warnings;


   # Paul, please scroll down to line 50...


my $INVALID = "Invalid statement\n";
my $Accumulator;

while ( print( "> " ) && defined( my $line = <> ) )
{
  chomp $line;
  my $ok;
  ($ok, $Accumulator) = execute( $line, $Accumulator );
  if ( $ok )
  {
    print "OK\n";
  }
  else
  {
    warn $INVALID;
  }
}

sub execute
{
  my ($line, $current) = @_;

  if ( length $line == 0 )
  {
    return;
  }
  my $operator_length = index $line, ' ';
  if ( $operator_length < 0 )
  {
    return monadic( $line, $current );
  }
  else
  {
    unless ( defined $current )
    {
      die "Accumulator has not been set\n";
    }
    my $operator = substr $line, 0, $operator_length;
    my $operand = substr $line, $operator_length + 1;
    
    # ******************************************************************************************************
     	$operand =~ /\A[\+\-]?\d+\.\d+\z/ || $operand =~ /\A[\+\-]?\d+\z/ or die "Invalid operand format\n";
    # ******************************************************************************************************
    
    return dyadic ( $operator, $operand, $current );
  }
}

sub monadic
{
  my ($operator, $current) = @_;

  if ( $operator eq 'EQUALS' )
  {
    if ( defined $current )
    {
      print " = $current\n";
    }
    else
    {
      print " (undefined)\n";
    }
    return ( 1, $current );
  }
  elsif ( $operator eq 'CLEAR' )
  {
    return ( 1, 0 );
  }
  return;
}

sub dyadic
{
  my ( $operator, $operand, $current) = @_;

  if ( $operator eq 'PLUS' )
  {
    return ( 1, $current + $operand );
  }
  elsif ( $operator eq 'MINUS' )
  {
    return ( 1, $current - $operand );
  }
  elsif ( $operator eq 'TIMES' )
  {
    return ( 1, $current * $operand );
  }
  elsif ( $operator eq 'OVER' )
  {
    return ( 1, $current / $operand );
  }
  return;
}