package SavingsAccount;
use strict;
use warnings;

my $Interest_Rate = 0.015;
use BankAccount;

BEGIN{ our @ISA = qw( BankAccount )}

sub add_interest
{
 my $self = shift;
 my $pct = $Interest_Rate * 100;
 $self->transact( "Interest at $pct%", $self->balance * $Interest_Rate );
}

#------------------------------------------------------------------------------------------------------------			<----- Modified part
# Lab 4, Objective 1 

# Our SavingsAccount class needs to define a class method that acts on $Interest_Rate class attribute that is 
# defined for the class as a whole and stored within the class. 

sub set_interest_rate
{
 	# Our class method is invoked with the classname as a bareword 
 	# on the left side of the arrow operator, this classname is 
 	# passed to the class method as the first argument. Because this 
 	# class method is actually not a constructor (only an accessor),  
 	# we won't use the class name for blessing (creating a new 
 	# object instance), so we simply ignore the first subroutine
 	# argument. The second one carries the new interest rate, 
 	# which we take as a list assignment. 
 	 
 	my ( undef, $new_inretest_rate ) = @_;
 	
 	# Since our $Interest_Rate variable is a lexical value and 
 	# it needs to be available for all object instances 
 	# (irrespectively of the actual state of any object instances), 
 	# it can and should only be set from a class method. This can 
 	# be done from our actual set_interest_rate class method by 
  	# a simple assignment, no any kind of extra OOP magic is 
 	# necessary... 
 	
  	$Interest_Rate = $new_inretest_rate;	
  	
}

1;