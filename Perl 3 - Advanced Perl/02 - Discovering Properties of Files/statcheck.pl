#!/usr/bin/perl
use strict;
use warnings;

# $0 will provide the current file name of this program,
# it will work even if the file name is altered
my $file = $0;

# This line reports the status of the program file (I 
# added the readable and writable status, as well, just 
# out of curiosity

printf "Status of %s: %s\n", $file, join(" | ", ((-x $file) ? "EXECUTABLE"
                                                            : "NOT EXECUTABLE"), 
                                                ((-r $file) ? "READABLE"
                                                            : "NOT READABLE"), 
                                                            
                 (( $] >= 5.010 ) ? ((-w -T $file)          ? "WRITABLE"
                                                            : "NOT WRITABLE")
                                                            
                                  : ((-w $file && -T $file) ? "WRITABLE"
                                                            : "NOT WRITABLE")));
