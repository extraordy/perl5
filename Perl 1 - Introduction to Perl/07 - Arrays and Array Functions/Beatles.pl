#!/usr/bin/perl
use strict;
use warnings;

my @Beatles = qw(John Paul George Ringo);
my ($drummer, @vocals);

$drummer = pop @Beatles;
push @Beatles, 'Pete Best';
push @vocals, shift @Beatles;
push @vocals, shift @Beatles;
push @vocals, shift @Beatles;
shift @Beatles;
unshift @Beatles, @vocals;
push @Beatles, $drummer;

print join( ", ", @Beatles), "\n";