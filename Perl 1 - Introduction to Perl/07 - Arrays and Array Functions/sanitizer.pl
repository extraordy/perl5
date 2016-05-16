#!/usr/bin/perl
use strict;
use warnings;


	# name 1

my $name = "Charles Francis Xavier";
my @names = split " ", $name;
my $first_name = shift @names;
my $last_name = pop @names;
my $middle_initial = "X";

if ( defined $names[0] ) {
	($middle_initial) = split "", shift @names, 0;
	$middle_initial .= "\.";
}

print "$first_name $middle_initial $last_name\n";


	# name 2

$name = "Hiram K. Hackenbacker";
@names = split " ", $name;
$first_name = shift @names;
$last_name = pop @names;
$middle_initial = "X";

if ( defined $names[0] ) {
	($middle_initial) = split "", shift @names, 0;
	$middle_initial .= "\.";
}

print "$first_name $middle_initial $last_name\n";


	# name 3

$name = "James Moriarty";
@names = split " ", $name;
$first_name = shift @names;
$last_name = pop @names;
$middle_initial = "X";

if ( defined $names[0] ) {
	($middle_initial) = split "", shift @names, 0;
	$middle_initial .= "\.";
}

print "$first_name $middle_initial $last_name\n";


	# name 4

$name = "Samuel Finley Breese Morse";
@names = split " ", $name;
$first_name = shift @names;
$last_name = pop @names;
$middle_initial = "X";

if ( defined $names[0] ) {
	($middle_initial) = split "", shift @names, 0;
	$middle_initial .= "\.";
}

print "$first_name $middle_initial $last_name\n";