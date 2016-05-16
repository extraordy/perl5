package TiedDir;

use strict;
use warnings;

#------------------------------------------------------------------------------------------------------------			<----- Modified part 1
# Lab 7, Objective 1 
#
# Our correct method name for the given code is TIEARRAY, it should return a blessed reference through 
# which the tied array will be emulated. It acts similarly as a constructor for a class.

sub TIEARRAY
{
  my ($class, $dir) = @_;

  opendir my $dh, $dir or die "opendir $dir: $!";
  bless [ sort readdir $dh ], $class;
}

#------------------------------------------------------------------------------------------------------------			<----- Modified part 2
# Lab 7, Objective 1 
#
# We also need to implement two more required methods, FETCH and FETCHSIZE for minimal functionality.

# The FETCH method is run whenever an individual element in the tied array is accessed. It receives one 
# argument after the object: the index of the value we are trying to fetch. 

sub FETCH
{
	my ( $self, $index ) = @_;
	return $self->[$index];
}

# The FETCHSIZE method returns the total number of items in the tied array. It's equivalent to "scalar @array" 
# or "$#array + 1". 

sub FETCHSIZE
{
	my $self = shift;
        return scalar @{$self};
}

1;