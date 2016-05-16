#!/usr/bin/perl
use strict;
use warnings;

# I have more and more stuff to comment, so if you feel, that this makes the code hard to read
# (I know, it does), please let me know. Normally, I wouldn't do this. Thanks, Paul. 

my $lines = <<'END_OF_REPORT';
 0.95   300   White Peaches
 1.45   120   California Avocados
10.50    10   Durien
 0.40  1500   Spartan Apples
END_OF_REPORT

# We want to store the inventory data in a hash, so that the comparison of the two data sets
# (inventory vs sold items) is much easier. We can't initialize the inventory hash
# explicitly (only declare it), because the data is available only from the heredoc.

my %inventory;
my %sold = ( 'White Peaches' 		=> 12, 
             'Rainier Cherries' 	=> 20,
             'Durien'        		=> -1, 
             'Spartan Apples'  		=> 24,

             # My own addition to the %sold hash: items which are not in the inventory

             'Fiddlehead' 		=> 8,
             'Fluted Pumpkin' 		=> 3,
             'Malabar spinach' 		=> 25,
             'Prussian Asparagus' 	=> 4,
             'Arugula'			=> 7 );  # One durien returned... too smelly
            
foreach my $line ( split "\n", $lines )
{
  my ($cost, $quantity, $item) = split " ", $line, 3;

  # This is the right spot to store inventory data into our %inventory hash.
  # Although, we won't use any of the quantity and cost information this time,
  # with a single concatenation we can actually store both in a single hash value.
   
  $inventory{ $item } = $quantity." ".$cost;
  
  if ( exists $sold{$item} )
  {
    $quantity -= $sold{$item};
  }
  else
  {
    warn "Didn't sell any $item this time\n";
  }
  printf "%5.2f %6d %s\n", $cost, $quantity, $item;
}

# Now, if we loop through the %sold hash (key by key), we can actually check
# if any of the %sold keys exist in the %inventory hash as an %inventory key

foreach my $key ( keys %sold )
{
  # IF the current %sold key does NOT EXIST in the %inventory hash, then we
  # have a hit to report.
  
  unless ( exists $inventory{ $key } )
  {
    # I could have used printf here to padd and align the key-value pair,
    # but then I should have checked the lengths, too, to avoid being truncated.
    # On the other hand, print is more reliable and simple.
     
    print "*** Sold $sold{ $key } of $key, which were not in inventory\n";
  }  
}
