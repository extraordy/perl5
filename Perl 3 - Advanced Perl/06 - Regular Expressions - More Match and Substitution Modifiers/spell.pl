#!/usr/bin/perl
use strict;
use warnings;

# The spell checker gets the properly spelled valid words (only A to Z letter sequences)
# from the "word" dictionary file, so we need to load its content filtered into a hash. 
# The piped chain of grep and map is the best option to do it in a single code line. 

open my $fh, '<', '/usr/share/dict/words' or die "Couldn't open file: $!\n";
my %word = map { ( lc $_, 1 ) } grep { chomp; /\A[a-z]+\z/i } <$fh>;

# We accept file names from the command line, or data from standard input.

while ( <> )
{
	# If we find a valid word match in the input line, we capture it. The /e modifier 
	# in a regex substitution operator makes it possible to alter the replacement 
	# string according to what was matched. When we evaluate the captured word,
	# we need to look it up in our filtered word hash. If we can't find the captured 
	# word in there, then it is quite possibly misspelled, so we need to construct a  
	# code, which - when it is executed - produces a text of the misspelled word  
	# surrounded by square brackets. If the match is in the hash, we replace it 
	# with its original value.  
	
	# Since our spell checker is case-insensitive, we must use /i modifier for the 
	# matching to pick up any possible uppercase-lowercase variation of a word, then
	# we need to use the lowercase version of the captured word to find it in the hash. 
	
	s/\b([a-z]+)\b/ exists $word{lc $1} ? $1 : qq{[$1]} /ige;
	print;
}

# We brake the last line intentionally to place the command prompt into a new line.

print "\n";

# I was going to try the /x modifier, but I realized, that - in spite of any justification - 
# it actually makes the regex harder to interpret for me... 
