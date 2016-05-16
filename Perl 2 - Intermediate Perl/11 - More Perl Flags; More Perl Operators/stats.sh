#!/bin/sh

netstat | perl -nle '/:\w+\s+\b(\S+):/ and (3..12) ? print $1 : next'