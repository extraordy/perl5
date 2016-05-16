#!/usr/bin/perl
use strict;
use warnings;

# The sales numbers are supplied on the command line as item names and sold amounts consistently, 
# so we can unpack the argument list directly into a hash, wehere consecutive name and amount data 
# will be loaded into key-value hash elements.

my %sold = @ARGV;

my $lines = <<'END_OF_REPORT';
 0.95   300   White Peaches
 1.45   120   California Avocados
10.50    10   Durien
 0.40  1500   Spartan Apples
 1.50   400   Cherry Tomatoes
END_OF_REPORT

my (%item_cost, %inventory);
foreach my $line ( split "\n", $lines )
{
  my ($cost, $quantity, $item) = split " ", $line, 3;
  $item_cost{$item} = $cost;
  $inventory{$item} = $quantity;
}

foreach my $item ( keys %sold )
{
  if ( exists $inventory{$item} )
  {
    # The following conditional statement will examine if the sale of the current item would 
    # decrease inventory level below zero  
    
    if ( $inventory{$item} - $sold{$item} < 0 )
    {
      warn "*** Selling $sold{$item} of $item will decrease the inventory level below zero (", $inventory{$item} - $sold{$item},")\n";
    }
    
    $inventory{$item} -= $sold{$item};
  }
  else
  {
    warn "*** Sold $sold{$item} of $item, which were not in inventory\n";
  }
}

foreach my $item ( sort keys %item_cost )
{
  printf "%5.2f %6d %s\n", $item_cost{$item}, $inventory{$item}, $item;
}