#!/bin/sh

while :
do
	read -p "Enter a positive integer (0 to quit) to list its prime factors, followed by [ENTER]:" number
	if [ $number -eq 0 ]
	then	       
		break
	fi
		perl -le '$x = shift; for ( 2..$x ){ next if $x%$_; $x/=$_; print; redo }' $number 
	
done

