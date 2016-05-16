#!/usr/local/bin/perl
use strict;
use warnings;


# The 'outstanding1.pl' and 'deposit1.pl' programs are reading a different type of report, but there is enough in common 
# between the two report formats to be able to extract the job of reading it to a single subroutine stored in a separate file.

# Our job is now to provide a single file named Report.pm that will make both of these new programs produce the same results 
# as the old ones.

sub read_report
{
	# First, we parse the subroutine argument, which is a filehandle passed by the caller.
	
	my $fh = shift;	
	
	# We will store the extracted information in a hash of hashes data structure.
	
	my %account;
	
	# The parent level (primary) keys are given and are the same in both data set, so we create  
	# a constant indicating, that this is a "static" element wired into the code explicitly. 
	
	my $PARENT_FIELD = 'account_number';
	
	# The first data line carries the field information, its elements represent one data line
	# consecutively in a repetitive sequence.  
		
	chomp( local $_ = <$fh> );
	
	# We need to parse this line and store its elements in an array except the first one, 
	# which is a simple line descriptor. 
	
	my ( undef, @field_names ) = split /:\s*|,\s*/;
	
	# Another hash needs to be created to store the associated field values. We build 
	# the hash dynamically with a single initialization step by using map(). 
	
	my %field_values = map { $_, undef } @field_names;

        # Now we can start to parse the data lines and store the corresponding field values 
        # in the hash.
        
        # The default variable could provide with a pretty dense coding style in the following blocks, 
        # but its usage is not without any danger in a perl module, so we'd better stick to a lexical 
        # variable here for storing the lines.
         
	my $line;	       
	
	# Let's read all lines in an outer loop until we reach the end of the data.
	
        while ( ! eof $fh )
	{
		# Since each line represented by a field name in the sequence, we start an inner
		# loop to periodically read up all lines record by record.  
		
		for my $field ( @field_names )
		{
			# We read a line and store it temporarily
			
			chomp( $line = <$fh> );
			
			# Now, if we hit a comment line we need to read the next line into the 
			# very same filed position, so we redo the loop with the same iterator. 
			
			redo if $line =~ /\A#/ and ! eof $fh;
			
			# If we reach the end of data in the inner loop, we simply jump out from it.
			
			last if eof $fh;
			
			# If reach this point in the loop, we can finally store the value represented
			# by the data line in our field value hash. 
			
			$field_values{ $field } = $line;
		}
		
		# If a single record gets ready, we can store it in the hash of hashes, but we need to 
		# inject the record into a more complex structure. New anonymous hashes will be assigned
		# to the parent level keys (account numbers). To create the new anonymous hashes we use  
		# linked map and grep, where grep provides a slice of the field_name array to exclude
		# the account_number field (as that will be a higher level key) and map creates the 
		# key-value pairs from the field_value hash using the narrowed set of keys.    
 		
		$account{ $field_values { $PARENT_FIELD } } = { map { $field_names[$_] => $field_values{ $field_names[$_] }} grep { $field_names[$_] ne $PARENT_FIELD } (0 .. @field_names-1) };	
	}
	
	# When the outer loop stops, the account hash is ready to be returned to the caller 
	# (here simply by value).
	
	return %account;	
}
1;