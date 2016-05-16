#!/usr/bin/perl
use strict;
use warnings;

# Our goal is to create a program including a subroutine that can tell 
# whether or not it is being called from an eval at any higher level.

print "\nDetecting subroutine calls from eval by 'caller'\n\n";

# These are the test cases hardwired into the program

{
	print 'Test 1: in_eval()';
	printf "\n%s\n", '-'x55;
	in_eval(); sub in_eval { who_called() };
	print "\n";
}

{
	print 'Test 2: eval { in_eval() }';
	printf "\n%s\n", '-'x55;
	eval { in_eval() };
	print "\n";
}

{
	print 'Test 3: eval { foo() }; sub foo { in_eval() }';
	printf "\n%s\n", '-'x55;
	eval { foo() }; sub foo { in_eval() };
	print "\n";
}

{
	print 'Test 4: eval "who_called()"';
	printf "\n%s\n", '-'x55;
	eval "who_called()";
	print "\n";
}

# This is the test subroutine

sub who_called
{ 

	# Constant declarations for 'caller' to make the code readable
	
	my $SUBROUTINE = 3;		# Fourth element of the list returned by 'caller' in list context
	my $EVALTEXT   = 6;		# Seventh element of the list returned by 'caller' in list context
	
	# Variable declarations
	
	my $level = 1;			# Index value of the parental level
	my $who;			# Subroutine name returned by 'caller'
	my $evaltext;			# String expression of a potential string-eval call
	my $is_eval = 0;		# Custom switch variable to store state
	
	# We need to detect all stages of the parental levels for nested calls.
	# We want to capture the name of the caller subroutine at every parental level
	
	while ( $who = (( caller( $level ))[$SUBROUTINE] ))
	{
		# If the captured subroutine name matches the string '(eval)' 
		# our caller at that level is an eval.
		
		if ( $who =~ /^\(eval\)$/ )
		{
			# We store the state.
			
			$is_eval = 1;
			
			# If the 'evaltext' variable is initialized, then our caller is a string-eval
			
			$evaltext = (( caller( $level ))[$EVALTEXT] ) ? (( caller( $level ))[$EVALTEXT] ): '';			
			 
		}

		# Let's step to the higher calling level by increasing the iterator
		
		++$level;	
		
		# But before we continue the loop, we need to print the actual parental level result
		
		printf "\tParental Level %d\. %15s   -   %-5s\n", $level-1, $who, (( $is_eval and ! $evaltext ) ? "Yes (block-eval)" : ( $is_eval and $evaltext ) ? "Yes (string-eval)" : "No" );  	
	}
}

