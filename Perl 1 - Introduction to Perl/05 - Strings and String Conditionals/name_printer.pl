#!/usr/bin/perl
use strict;
use warnings;

my $boss_first_name 	= "Penelope";
my $boss_last_name 	= "Creighton-Ward";
my $butler_first_name 	= "Aloysius";
my $butler_last_name	= "Parker";

# my $boss_first_name 	= "John";
# my $boss_last_name 	= "Basil-Cleese";
# my $butler_first_name = "Andrew";
# my $butler_last_name	= "Manuel-Sachs";

my $field_width 	= 15;

print '|', ' 'x$field_width, '|', ' 'x$field_width, "|\n";

my $boss_full_name 		= $boss_first_name.' '.$boss_last_name;
my $butler_full_name		= $butler_first_name.' '.$butler_last_name;
my $boss_full_name_length	= length( $boss_full_name );
my $butler_full_name_length	= length( $butler_full_name );
my $boss_first_name_length	= length( $boss_first_name );
my $boss_last_name_length	= length( $boss_last_name );
my $butler_first_name_length	= length( $butler_first_name );
my $butler_last_name_length	= length( $butler_last_name );

if (( $boss_full_name_length <= $field_width ) && ( $butler_full_name_length <= $field_width ))
{
	print '|', $boss_full_name, ' 'x( $field_width - $boss_full_name_length ), '|', $butler_full_name, ' 'x( $field_width - $butler_full_name_length ), "|\n";
}
elsif (( $boss_full_name_length > $field_width ) && ( $butler_full_name_length <= $field_width ))
{
	print '|', $boss_first_name, ' 'x( $field_width - $boss_first_name_length ), '|', $butler_full_name, ' 'x( $field_width - $butler_full_name_length ), "|\n";
	print '|', $boss_last_name, ' 'x( $field_width - $boss_last_name_length ), '|', ' 'x$field_width, "|\n";
}
elsif (( $boss_full_name_length <= $field_width ) && ( $butler_full_name_length > $field_width ))
{
	print '|', $boss_full_name, ' 'x( $field_width - $boss_full_name_length ), '|', $butler_first_name, ' 'x( $field_width - $butler_first_name_length ), "|\n";
	print '|', ' 'x$field_width, '|', $butler_last_name, ' 'x( $field_width - $butler_last_name_length ), "|\n";
}
elsif (( $boss_full_name_length > $field_width ) && ( $butler_full_name_length > $field_width ))
{
	print '|', $boss_first_name, ' 'x( $field_width - $boss_first_name_length ), '|', $butler_first_name, ' 'x( $field_width - $butler_first_name_length ), "|\n";
	print '|', $boss_last_name, ' 'x( $field_width - $boss_last_name_length ), '|', $butler_last_name, ' 'x( $field_width - $butler_last_name_length ), "|\n";
}
else
{
	# This block should never be run...
} 
