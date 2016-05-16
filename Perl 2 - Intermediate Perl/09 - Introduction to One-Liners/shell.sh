#!/bin/sh
perl -nle 'm{\A(?:.*:){6}(.+\b)}i and $h{lc $1}++; END{ print "$_: $h{$_}" foreach sort { $h{$b} <=> $h{$a} } keys %h }' /etc/passwd