#!/usr/bin/perl
use strict;
use warnings;

open my $fh, '<', '/usr/share/dict/words' or die "Couldn't open file: $!\n";

# To comply with the objective we need to chain together "map", "grep" and the  
# diamond operator in a single pipeline. 

# "Grep" takes one line at a time from the diamond operator and removes the new line 
# character from the end. The regex acts as a filter: those words will be sent to
# the input of the map, which consist solely of letters.

# "Map" turns each word coming from "grep" lowercase before it returns it in a list
# of key-value pair to assign it to the word hash. The key will be the word,
# its associated value will be set to 1. Since we turn each word to lowercase, any 
# potential duplication coming from an uppercase variant will be overwritten in  
# the word hash, there's no need to use "exixsts". 

my %word = map { ( lc $_, 1 ) } grep { chomp; /\A[a-z]+\z/i } <$fh>;


print "Verification: the following words should be in the hash:\n";
print "$_: ", $word{$_} ? 'PASS' : 'FAIL', "\n" for qw(wolf schumpeter saltpeter);
print "Verification: the following words should not be in the hash:\n";
print "$_: ", $word{$_} ? 'FAIL' : 'PASS', "\n" for qw(wolfsmilk Schumpeter peter-penny);

