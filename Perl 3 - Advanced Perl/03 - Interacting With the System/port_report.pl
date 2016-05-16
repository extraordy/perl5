#!/usr/bin/perl
use strict;
use warnings;

# To reach our goal we need to redirect the output of the netstat shell command
# to a filehandle we can read from. Piped open is specified in the objective, but it 
# seems to be the most native solution to Perl anyway, than using system() or exec() 
# and probably much faster and more memory friendly, than simply using backticks. 
# We just need to be careful about the direction of the pipe we choose
# (we need "piped open from" here: "-|", as we plan to read from the output of a shell
# command.   

open my $fh, '-|', "netstat -an" or die "Can't open pipe: $!\n";

# Let's put the result into a hash

my %ports;
my $index = 0;

# We need to loop through the output what we get line by line

while ( <$fh> )
{
	# If the line doesn't contain the substring "LISTEN",
	# then we just skip it and continue with the next line
	
	next unless /\bLISTEN\b/;
	
	# Since the data comes in distinct columns, we can clice
	# it up. Grabbing the value from the fourth column and 
	# using regex, we can easily extract the port number.  
	
	my $port = $1 if (split)[3] =~ /(?:.+):(\d+)\z/;
    
    	# Although we don't need to count occurrence of the 
    	# unique ports, the following line does the key-value
    	# initialization in a single step if the key doesn't
    	# exist, there's no need to detect it first using the 
    	# exist function.
    	
	$ports{$port}++;
}

# Before we start to list the port numbers, we create an informative 
# header and let the user know about how many unique port we found.

print "\nUnique port numbers ( ", scalar( keys ( %ports )), " ) the student machine is listening on:\n\n";

# Finally here comes the key-sorted port list. We must make 
# matrix-like horizontal list, because we have several 
# hundred hits, and we don't want the user to scroll a lot or simply
# loose the beginning of the list from the screen buffer. 

++$index and $index%10 ? printf "%03d. %05d\t",$index, $_ : printf "%03d. %05d\n", $index, $_  for sort { $a <=> $b } keys %ports;

# The final new line comes handy if the list ends abruptly (anywhere 
# before the tenth value in the row, as that last value would carry 
# normally the line feed.

print "\n";
