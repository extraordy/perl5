package SavingsAccount;

#------------------------------------------------------------------------------------------------------------			<----- Modified part
# Lab 6, Objective 1 
#
# We have to convert SavingsAccount.pm to Moose. To do this, we need to edit it to insert the 
# necessary statements. 

# For the proper transition from regular Perl OO to Moose, we need to analyze first what we 
# actually want to achieve. Since we want to be able to instantiate the SavingsAccount class,  
# we have to "use Moose" first. This will load important Moose functions into the class,
# which help us to redefine it.

use Moose;

# We don't have a constructor subroutine in the SavingsAccount class, because we use its parent's
# "new" subroutine to create objects. SavingsAccount is a subclass of the BankingAccount class,
# this relationship needs to be indicated explicitly for Moose. The "extends" statement will
# force Moose to load any classes we specify in the statement to maintain inheritance.

extends 'BankAccount';

# The initial interest rate value was originally stored in the $Interest_Rate variable. Since we
# create a Moose attribute for the interest rate, the initial value will act more like a constant, 
# which we will set as a default value to the attribute.

my $INTEREST_RATE = 0.015;

# The Interest_Rate attribute will give us an implicit accessor method to read and write the 
# interest rate value and lots of control to specify its type and other properties. We want to declare 
# it as a numeric value, both readable and writable and required. We also want to specify distinct  
# "getter" and "setter" methods for reading and writing (just to comply with Damian Conway's 
# recommendations from Perl Best Paractices). Until our attribute is not set in the 
# instance, its default value is also provided in the class level. 

has Interest_Rate => ( isa      => 'Num', 
                       is       => 'rw', 
		       required => 1,
		       reader=> 'get_interest_rate',
		       writer => 'set_interest_rate',  
		       default  => $INTEREST_RATE );
		       
# Moose takes care of the accessor methods for attributes, so we don't need the set_interest_rate method
# anymore. Because we explicitly specified the name of the reader and writer methods for the Interest_Rate 
# attribute (get_interest_rate and set_interest_rate), we will be able to test the "setter" method directly
# from usebank.pl...

sub add_interest
{
  my $self = shift;

  # We need to follow the changes in the instance methods as well, so we need to change the carrier of 
  # the interest rate value in the add_interest method as well. Now we have a Moose attribute, which always
  # provides the current rate for the instance methods. Since the reader method of the attribute is explicitly 
  # specified, it needs to be called here in order to get the current interest rate value.
  
  my $pct = $self->get_interest_rate * 100;
  $self->transact( "Interest at $pct%", $self->balance * $self->get_interest_rate );
}

#------------------------------------------------------------------------------------------------------------

1;
