#!/usr/bin/perl
use strict;
use warnings;

# The program will consider only URLs with http, https and ftp schemes,
# so we can declare a scheme hash with these literal values to collect 
# occurrence information.
 
my %schemes = qw( http 0 https 0 ftp 0 );

# The program accepts URLs from any servers, we need to assign these 
# values dinamically to a servers hash in order to collect occurrence
# information. 

my %servers;

# We have a path to our data file. Because it's somewhere else in the 
# filesystem, the most convenient way to process it is using a filehandle.

my $DATA_FILE = '/software/Perl2/urls.dat';

open my $fh, '<', $DATA_FILE or die "Couldn't open $DATA_FILE: $!\n";

while ( <$fh> )
{
  	chomp;
  
  	# The regex below matches only the scheme and server part of
  	# a given URL and the path and file data will be ignored.
  	# We have two anchors, one matches the scheme, the another 
  	# one matches the server (I preferred to capture the top-level 
  	# domain and its subdomain label only - e.g. "example.com" -  
  	# to make the regex a little bit more selective).
  	
  	#      scheme ($1)           server ($2)
	#        -----             --------------     
	#        |   |             |            |   
  	
  	if ( m{\A(\w+)://(?:\w+\.)*(\w+\.\w{2,3})/(?:\b|\z)}i )
	{	
	
	   # If there's a scheme match we increase its hash value
	   
	   $schemes{ lc $1 }++ if ( exists $schemes{ lc $1 } ); 	
	   
	   # If the server hasn't been recorded yet, we make the 
	   # assignment first, creating an new key-value pair.
	   
           $servers{ lc $2 } = 0 unless exists $servers{ lc $2 };
           
           # If the server exists in the hash, we increase its value.
           
           $servers{ lc $2 }++;          
	}	
}

# Since the reporting task is identical in both cases and we don't need to
# alter the content of the hashes during reporting, using a subroutine
# seemed to be a good idea. We pass the hashes to the subroutine by value.

report( "schemes", %schemes );
report( "servers", %servers );


sub report 
{
	my ( $topic, %topic_hash ) = @_;
	
	my $counter = 0;	
	print "The most popular $topic: \n";

	# Sorting the hash values in a descending order is a key step in the solution,
	# we need only the top two values to report. 
		
	foreach ( sort { $topic_hash{$b} <=> $topic_hash{$a} } ( keys %topic_hash ) )
	{
		last unless $counter < 2;
		printf "%d\. %s (%d)\n", $counter+1, $_, $topic_hash{$_}; 		
		$counter++;
	}
	print "\n";
}

