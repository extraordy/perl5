#!/usr/local/bin/perl
use strict;
use warnings;

# Our goal is to write a program (process.pl) that forks, and the parent 
# process blocks waiting for the child to complete, while the child process 
# fetches the web page http://perl4.oreillyschool.com/ost-mirror/ and exits 
# with an exit code set to the HTTP status code of fetching the page. 

# Because we need to fetch and return the HTTP status code from the fetching, 
# the easiest way is to use the WWW::Mechanize module. It has a response method,
# which returns the current response as an HTTP::Response object. The code
# method of this object returns the actual result.

use lib "$ENV{HOME}/mylib/lib/perl5";
use WWW::Mechanize;

# The skeleton of the forking is quite straightforward: the return value of 
# the fork tells which process is the parent and which one is the child,
# as they are executing at the same spot in our code (it is always the process 
# id of the child in the parent, but zero or undef in the child). 

my $pid = fork;

# If the process ID is higer than 0, the parent process is running. 

if ( $pid )               
{
	# The objective doesn't require any other tasks from the parent
	# than simply wait for the exit code of the child, so it can wait
	# endlessly, so we don't need to implement any signal handler to
	# let it work until the exit signal comes from the child.
	       	
	my $pid_found = wait;
	    
	# The waiting ended here, we've finally got the exit code from the child,
	# let's exemine it whether everything went OK.
	    
	die "wait error" if $pid_found < 0;
	die "Found a different child process $pid_found!" if $pid_found != $pid;
	    
	# The exit code is carried by the least significant byte of the $? value.
	# To get it, we need to shift the value left by 8 bits. 
	    
	printf "Code = %d\n", $?>>8;
	    
	# We are done...
}

# If the value of the process ID is not higher than 0 and it is not undef 
# either, the child process is running. 

elsif ( defined( $pid ) )
{
	# We are in the child process, let's roll with the fetch...
	   
	my $URL = 'http://perl4.oreillyschool.com/oscon-mirror/';
	my $mech = WWW::Mechanize->new;
	$mech->get( $URL );
	
	# We don't really want to parse the webpage, all we need is
	# the HTTP response code, which we simply return as an exitcode.
	  
	exit $mech->response->code();
}

# When the returned process ID is undef, that indicates fork error, the  
# child may have had issue with getting a free process slot...

else
{
  	die "Error in fork: $!\n";
}