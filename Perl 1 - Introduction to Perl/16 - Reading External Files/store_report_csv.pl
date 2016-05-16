#!/usr/bin/perl
use strict;
use warnings;

my %sold;
if ( @ARGV > 2 && shift eq "-s" )
{
  my $sales_file = shift;
  my @saved_argv = @ARGV;
  @ARGV = $sales_file;
  while ( defined( my $line = <> ) )
  {
    chomp $line;
    my ($quantity, $item) = split " ", $line, 2;
    $sold{$item} = $quantity;

  }
  @ARGV = @saved_argv;
}
else
{
  die "Usage: $0 -s sales_file inventory file...\n";
}

# We start to process our Store_report.csv file first

my (%item_cost, %inventory);
while ( defined( my $line = <> ) )
{
  # We need to skip the header line of the csv file, so we check
  # the actual line number. If it is equal to 1, we start the next
  # iteration of the loop without processing the first line.
  
  if ( $. == 1 )
  {
     next;
  }
  chomp $line;
  
  # Since we changed the format of our inventory file to csv,
  # our data is separated by comma now, so the split needs
  # a new pattern (comma instead of space).  
  
  my ($cost, $quantity, $item) = split ",", $line, 3;
  $item_cost{$item} = $cost;
  $inventory{$item} = $quantity;
  
  # If the quantity in the actual line is negative, then a
  # warning needs to be raised
  
  if ( $inventory{$item} < 0 )
  {
    warn "*** Inventory is negative at line $.\n";
  }
  
}

foreach my $item ( keys %sold )
{
  if ( exists $inventory{$item} )
  {
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