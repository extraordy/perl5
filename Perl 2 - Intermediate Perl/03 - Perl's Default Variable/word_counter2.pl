#!/usr/bin/perl
use strict;
use warnings;

# The first argument is assigned to a regular variable whose value is checked
# in a short-circuiting at the very same statement. If the value of $char_num 
# is evaluated to false after the assignment (that is, there are no arguments 
# or the value of the first argument is 0), the program dies with a "usage" message. 

# I could assign the result of the shift to the $_ default variable to demonstrate,
# that it is possible, but then I should assign its value to a regular variable right 
# before the loop, as inside there $_ gets into a different scope and its value from the 
# previous scope won't be available . 

my $char_num = shift or die "Usage: $0 <number_of_characters> [<text_file_name>]\n";

my %count;

# If no file handle is used with the diamond operator, Perl will examine the @ARGV 
# special variable. If @ARGV has no more elements (our second command line argument 
# is optional), then the diamond operator will read from STDIN.

# Although it wasn't mentioned in this lesson, but logically deductable, that
# if we don't assign the diamond operator explicitly to any variable, it will 
# read implicitly into the default variable. 

while ( <> )
{
   # If we need to read from STDIN, we would like to give control to the user to 
   # terminate the entry simply by entering an empty line. If we ensure, that no 
   # any entry contains "new line" character, the test can be accomplished easier.
    
   chomp;
   
   # If the content of the (inner) default variable (locale to the while loop) is 
   # an empty string, we terminate the loop using a short-circuiting again.
   
   defined && length or last;
   
   # The following statement turned out immensely succinct (a combination of using 
   # default variable, short-circuiting and postfix modifier), but it actually works.
   # Without placing imaginary parentheses into the proper positions, it is hard to 
   # understand how this complex statement works:
   #
   # ( length >= $char_num and $count{$_}++ ) foreach split;
   #
   # We split each line into words and put them implicitly into the default variable.
   # Then, depending on whether their character number is greater than or equal to the 
   # value of our first comand line argument, we place them into our "count" hash and 
   # later increase their value with every new hit. Beautiful and very effective...
   
   length >= $char_num and $count{$_}++ foreach split;

}

# When we finishd with the counting (or the user entered an empty line), we print the result
# using a postfixed foreach statement and the newly initialized (outer) default variable. 

print "$_: $count{$_}\n" foreach sort keys %count;