#!/usr/local/bin/perl
use strict;
use warnings;

# Our objective is to write a program (dl_page.pl), that forks a child process 
# that waits until a given time and then downloads a web page 
# (http://perl4.oreillyschool.com/ost-mirror/) to a local file 
# (ost-mirror.html). Running our program should look like this:

# cold:~/perl4homework/Project14$ ./dl_page.pl 17:05
# Child will run in 145 seconds

# 145 seconds (in this example 17:05 is 145 seconds away) from this point, the 
# child process will run (the server is in the United States Central time zone), 
# meanwhile, we could be doing other things. The child does not have to output 
# anything to the terminal. We can expect that the time entered will be only a 
# short time away (we want to be able to verify the operation while you are 
# logged on) and we don't have to worry about daylight savings time, 
# leap seconds, month boundary crossings, or being in any other way completely 
# precise about the time. The given hint: the getstore method of LWP::Simple 
# can save us a few lines. 

use lib "$ENV{HOME}/mylib/lib/perl5";

use DateTime;
use LWP::Simple;

# First, we make sure we get at least one command line argument.

scalar(@ARGV) or die "Usage: $0 hh:mm\n";

# We take the semantics and syntax for granted: won't double check the content 
# and the format of the argument, but spplit it into hour and minute values.

my ( $hour, $minute ) = split( ":", $ARGV[0] );

# We need to find out the duration between the current and given time, so 
# let's create a subroutine which takes care of the calculation. It takes
# two parameters (the given time split up into hour and minute value) and it 
# returns the duration measured in seconds. 

my $duration = timing( $hour, $minute );

# Since the objective tells to fork a child process that waits until a 
# given time, we use the familiar forking skeleton below with the parent's
# control flow first, than the child's one next. From the phrasing it is clear,
# that the delay should actually happen in the running child process.

my $pid = fork;

if ( $pid )               
{
	# Because the objective expects the parent process to "do other things",
        # it is necessary to implement a signal handler, so that the wait() can 
        # execute without blocking. The signal interrupts the parent's process,
        # when the child exits. 
	
	local $SIG{CHLD} = sub {
	  my $pid_found = wait;
	  die "wait error" if $pid_found < 0;
	  die "Found a different child process $pid_found!" if $pid_found != $pid;
	};

	# Because the objective doesn't specify the parent's task, we add an
	# "infinite" sleep at the end of its code, which will also be interrupted 
	# by the signal, anyway. This makes it possible to avoid the parent 
	# finishing its task before the child process is terminated. 
	
	sleep;
}
elsif ( defined( $pid ) )
{
	# Here's the delay in the child's control flow, which can be implemented 
	# simply by sleeping for the period of time determined by the value of the 
	# $duration variable. Because the child process inherits its parent's attributes,
	# the value of the $duration global variable is also available in the child. 

	print "Child will run in $duration seconds\n";
	sleep $duration;
	   
	# When the delay comes to an end, the process continues with the task
	# set by the objective. Downloading and storing a web page is a piece of cake
	# when using the getstore method of the LWP::Simple module.  
	
	my $url  = 'http://perl4.oreillyschool.com/ost-mirror/';
	my $file = "ost-mirror.html";
	  
	exit getstore( $url, $file );
}
else
{
  	die "Error in fork: $!\n";
}

# The timing() subroutine takes care of the calculation of the 
# duration measured in seconds.

sub timing
{
	my ( $hh, $mm ) = @_;
	
	# The system time is usually synchronized with and expressed in UTC 
	# (Coordinated Universal Time), which is 6 hours ahead of CST (Central
	# Standard Time) and 5 hours ahead of CDT (Central Gaylight Time), so
	# we need to compensate the difference in order to be able to keep track
	# of our test seconds, because the OST server is somewhere in the Central 
	# time zone. 
	
	# We'll use DateTime to get the current time in CDT. Although, it's out of 
	# scope of this excercise, we'd like to utilize a portable solution.
	
	my $start = DateTime->now( time_zone => 'America/Chicago' );
	
	# To generate the DateTime object for the given time, we start with the 
	# current time again.
	
	my $end   = DateTime->now( time_zone => 'America/Chicago' );

	# Then, we just set the hour, minute to the given time and empty the second 
	# value.
	
	$end->set_hour( $hour );
	$end->set_minute( $minute );
	$end->set_second( 0 );

	# With the two DateTime objects ($start and $end) are generated, we can do the 
	# arithmetics (which is the subtraction of the earlier date from the later one 
	# expressed in seconds) and return the result of the expression.

	return $end->subtract_datetime_absolute( $start )->seconds(); 
}