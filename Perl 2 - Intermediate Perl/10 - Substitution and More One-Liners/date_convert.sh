#!/bin/sh
perl -pi.bak -e 's{(\d{2})/(\d{2})/(\d{4})}{$3-$1-$2}' some_dates.txt