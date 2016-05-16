#!/usr/local/bin/perl
use strict;
use warnings;

use TiedDir;

tie my @current, 'TiedDir', '.';
print "Files in '.':\n";
print "\t$_\n" for @current;