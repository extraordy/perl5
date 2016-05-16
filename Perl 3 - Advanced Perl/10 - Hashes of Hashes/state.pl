#!/usr/bin/perl
use strict;
use warnings;
# use Data::Dumper;

# We start the program with parsing command line parameters. The first two parameters are required,
# the third one is optional.

my $data_file = shift or die "Usage: $0 <data_file> <state_abbreviation> [<attribute_name>]\n";
my $state_abbr = shift or die "Usage: $0 <data_file> <state_abbreviation> [<attribute_name>]\n";
my $attr_name = shift if @ARGV;

# We stored the first parameter temporarily in a scalar until we finished parsing the rest, now 
# we can put it back to @ARGV, so that we can process it without explicitly declaring a filehandle.

push @ARGV, $data_file;

# The data file cannot be processed without schema. We don't have a header line in the data file,
# we need to load it from an external file. This global "constant" declaration represents the 
# schema file.

my $SCHEMA_FILE = '/software/Perl3/state_header.key';

# We need to initialize the "schema" array from the schema file and the "state" hash from the
# data file. The "state" hash is a komplex data structure (hash of hashes), which we create 
# on the fly (without any initial data structure declaration) utilizing Perl's cool 
# autovivification feature.

my %state;
my @schema;

# Since our schema file is hard wired into the program (we have a "constant" declaration for it),
# we will load its content by using a subroutine and handle the return value in the main program
# to report the result. The subroutine has two parameters, the schema array is passed by reference
# to be able to write it from inside the subroutine. The second parameter is the path to the 
# schema file. 

print load_schema( \@schema, $SCHEMA_FILE ) ? 
	( "\nSchema imported...\n" ) :   
	( "\nSchema couldn't be imported...\n" );

# Now we can start to build up the state hash line by line

while ( <> )
{
	chomp;
	
	# The "primary key" is the state name abbreviation , we need to parse it separately to be
	# able to create the top level keys of the parent hash. The rest can go into a separate list
	# variable. The elements are separated by a combination of spaces and the pipe symbol, that's 
	# what we use to split up the lines of the data file .
	
	my ($abbreviation, @fields) = split /\s*\|\s*/;		
	
	# The following construct can hardly be comprehended, it is so dense: this is hash slice 
	# of our "state" hash, where we are using an array slice to narrow down the acceptable keys  
	# for the child hashes (namely, we need to exclude the very first "key" state attribute from  
	# the "schema" array, because that is the key of our parent hash, it actually represents the  
	# state abbreviation in the data file). We can simply assign the parsed attribute list to
	# this anonymous child hash, which is represented here by the hash slice. 
		
	@{ $state{$abbreviation} }{@schema[1..$#schema]} = @fields;
}

# If we have keys in the parent hash, we consider it loaded.

print keys %state ? 
     ( "Data imported...\n\n" ) :
     ( "Data couldn't be imported...\n\n" );

# The Dumper can visually help to assess whether we did a good job, or something went wrong here.
# print Dumper \%state;

# This is our subroutine to do the rest of the job. It takes three parameters, the first of them is 
# the loaded "state" hash which is also passed by reference, although we don't want to alter it from 
# inside the subroutine in any way, but this makes the whole dereferencing a little bit 
# more challenging.

dump_state( \%state, $state_abbr, $attr_name );


# And here are our subroutines

sub load_schema
{
	my ( $schema_ref, $schema_file ) = @_;
	
	open my $fh, '<', $schema_file or die "Couldn't open $schema_file: $!\n\n";
	
	# This is a beautiful, complex Perl statement; it loads the lines iterating from the schema file 
	# into the "schema" array after it removed the new line character from their end.
	 
	chomp( @$schema_ref = <$fh> );
	close $fh;

	# If the array is not empty we return 1, otherwise 0.
	
	@$schema_ref ? return 1 : return 0;
}

sub dump_state
{
	my ( $state_ref, $abbr, $attr ) = @_;
	
	# If the specified state abbreviation in the command line doesn't match any key in the "state" hash
	# we need to terminate the program with an error message.
	
	die "The specified state abbreviation ($abbr) doesn't exist.\n\n" unless exists $state_ref->{$abbr};
	
	# If the optional command line parameter was specified, we can double check if it is valid (that is,
	# it has a match among the child level anonymous hashes as a key).
	
	if ( defined( $attr ) and length( $attr ) )
	{
		# If tehere is no match, we need to terminate the program with an error message.
		 
		die "The specified state attribute ($attr) doesn't exist.\n\n" unless exists $state_ref->{$abbr}{$attr};

		# If the specified state attribute is valid, we only need to list its corresponding value, nothing else.

		print "The specified state abbreviation was \"$abbr\".\nThe value of the requested attribute \"$attr\" is:\n\n";
		printf "\t%-12s => %-8s\n", $attr, $state_ref->{$abbr}{$attr};
	}
	else
	{
		# If there was no optional parameter specified in the command line, we need to list all state attribute
		# values we have for the specified state abbreviation key.
	
		print "The specified state abbreviation was \"$abbr\".\nIts associated attributes are:\n\n";
	
		for my $key ( sort keys %{ $state_ref->{$abbr} } )
		{
			printf "\t%-12s => %-8s\n", $key, $state_ref->{$abbr}{$key};
		}
	}	
	print "\n";          
}