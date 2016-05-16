#!/usr/bin/perl
use strict;
use warnings;

# Schematic patterns for on-screen comparison only

my $pattern_1 = "+1 DDD-DDD-DDDD";
my $pattern_2 = "(DDD) DDD-DDDD";

print "\n";

while ( defined( my $line = <DATA> ) )
{
  chomp $line;
  
  printf "%s %s> %s\n", $line, '-' x (50-length($line)) , $pattern_1 
    if $line =~ m{\+1 \d\d\d-\d\d\d-\d\d\d};
    
  printf "%s %s> %s\n", $line, '-' x (50-length($line)) , $pattern_2 
    if $line =~ m{\(\d\d\d\) \d\d\d-\d\d\d\d};    
}

print "\n";

__END__
+3454 723-7483
+1 432-422-2342
(343) 348-4284
9847367289
(2322) 3423-34234
My number is (800) 998-9938, extension 7187
+2 823-238-3732
+1 (352) 235-8476