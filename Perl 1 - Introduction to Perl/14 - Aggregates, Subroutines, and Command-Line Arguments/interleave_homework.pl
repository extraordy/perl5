#!/usr/bin/perl
use strict;
use warnings;

my @first = qw(Can unlock secret);
my @second = qw(you the code?);

my @mixed = interleave_words( scalar(@first), @first, @second );
print "Result: @mixed\n";

sub interleave_words
{
    # I wouldn't unpack the argument list using splice (the way the objective suggested),
    # because we have only a few parameters. The list-assignment is brief and readable enough.
    
    my ( $count, @words ) = @_;
    
    # Now, I can splice all elements coming originally from the @first array
    # into the @result array in a single step.
    
    my @results = splice(@words, 0, $count);
    
    # The remaining elements are coming from the @second array. Their number should be equal to 
    # the element number of the original @first array, that is, the value of the $count scalar.
    
    if ( @words != $count)
    {
        die "Second array not same size ($count) as the first\n";
    }
    
    foreach my $index ( 0 .. $count-1 )
    {
        # Using the original indexing and splice we can easily combine the two lists in a loop.
        
        splice( @results, $index*2+1, 0, $words[$index] ); 
    }
    return @results;
}