#!/usr/bin/perl
use strict;
use warnings;

# For parsing command line options, I'm trying to take a generic approach,
# that makes the option list expandable for my program. For this, I need an 
# "options" hash to store options as stateful switches. 

my %options = ( -v => 0, -i => 0 );

# First, we need to know if we have any command line arguments at all. The pattern 
# is the only required argument, so the size of the @ARGV array must be greater 
# than zero.

scalar(@ARGV) or die "Usage: $0 [<-v>] [<-i>] <pattern> [<file>]\n";

# If we have options set in the command line, this is the right spot to check them out.
# This single code line below copies one element from the @ARGV command line argument 
# array into $_ default scalar variable. Then, $_ is implicitly tested if its value 
# exists in the "options" hash as a key, and if it does, its corresponding value 
# is set to 1.   

exists $options{$_} and $options{$_}++ foreach @ARGV; 

# Although, we haven't discussed it yet, the leading caret (^) meta-character in a pattern
# matches only the beginning of the text, so when using regex to find options, this is
# a very useful feature. The code line below is equivalent with the upper line,
# however it is not that generic, because each option has to be hardwired into the code
# in a separate matching.

# /^-v/ || /^-i/ and $options{$_}++ foreach @ARGV; 

# By looping through the "options" hash (following which key-value pair is altered), we can
# remove the options from the @ARGV command line argument array. It's easy, because their 
# precedence is guaranteed in the argument list. If the value associated with a key is 
# greater than zero, we have one argument to delete from the beginning of the argument list.
# The order doesn't even matter, should we have more of them.

$options{$_} and shift foreach keys %options;

# When we remove all options from the @ARGV array, the nex available argument is
# our required pattern. If not, we complain and terminate the program.

my $regex = shift or die "Usage: $0 [<-v>] [<-i>] <pattern> [<file>]\n";

# If we have a file argument, it remaines in @ARGV. Our diamond operator implicitly 
# open it from there reading its content line by line. If there are more file specified, 
# they all will be read sequentially. If no file was specified at all, the STDIN will 
# be read, and matching text line will be echoed to STDOUT right away (like in GREP).

while ( <> )
{
	
	  # Separate options are supposed to modify the behavior during pattern matching,
	  # so we need to create separate a version for each possible combination.
	  # Since we put the text line into the default scalar variable, we'd better not
	  # use $_ explicitly, so the binding operators  ( "=~" or "!~" ) won't be used 
	  # explicitly, and the control flow will be regulated by postfix conditional 
	  # statements. 
	
	  	# Both -v and -i is set
	  
	  if ( $options{'-i'} && $options{'-v'} ) 		
	  {
	  	# prints case-insensitively non-matching lines
	  	
	  	print unless /$regex/i; 				
	  } 
	  
	  	# Only -i is set
	  
	  elsif ( $options{'-i'} )				
	  {
	  	# prints case-insensitively matching lines
	  	
	  	print if /$regex/i;  	
	  }
	  
	  	# Only -v is set
	  
	  elsif ( $options{'-v'} )				
	  {
	    	# prints case-sensitively non-matching lines
	    	
	  	print unless /$regex/;  	
	  }
	  
	  	# None of them is set
	  
	  else							
	  {
	  	# prints case-sensitively matching lines
	  
	        print if /$regex/;
	  }
}