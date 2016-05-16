#!/usr/bin/perl
use strict;
use warnings;

# I decided to split up the code into separate subroutines and to call them in void context 
# without parameters, as they don't share information with each other.

# The following subroutine generates the two-letter filenames and creates all the files

permutator();

# The following subroutine does the rest of the job, it prints the content of the "q-files",
# deletes them and counts the remaining two-letter files and reports the results. 

q_file_terminator();


sub permutator
{
	# The filename permutation is based on Perl glob using the range operator. Because the 
	# range operator returns the expected result only in list context, I combined it with
	# the join built-un function, to create a comma separated list for the glob permutation.
	# The reason why the permutation can work this way is becasue I didn't actually use any 
	# matching in the glob expression. All newly generated file names are stored here - 
	# thanks to the glob, practically sorted - in an array.
	
	my @files =  glob "{" . join(',', 'a'..'z' ) . "}{" . join(',', 'a'..'z' ) . "}";
	 
	# I loop through the array, 
	 
	for my $file (@files)
	{
	        # and create a new filehandle in order to create a new file with the current name
	        # in the iterator variable. If the file creation fails, I terminate the program.
	        
		open my $fh, '>', $file or die $!;
		
		# Since the file content will be the same as the filename, all I need to do is 
		# turn it upper case before I write the value of the iterator variable into the 
		# new file. 
		
		print {$fh} uc $file;
		
		# Although Perl closes the filehandle implicitely before I attempt to reuse it,
		# it is always wise to do it explicitely. 
		
		close $fh;
	}
	
	# When it the file generation is done, we report the total number of files created.
	
	print "Step 1. ", scalar @files, " files have been successfully created.\n\n"
}

sub q_file_terminator
{	

	# To save memory we don't use foreach loop or glob to process the files,
	# so we use opendir and readdir to grab the appropriate files one by one.
	
	my $dir = '.';
	opendir my $dh, $dir or die "Couldn't open $dir: $!\n";
 
 	print "Step 2. The contents of the Q-Files are as follows:\n\n";
 
        my $q_file_counter = 1;
 
	while ( my $file = readdir $dh )
	{
	
		# We need those files, which have  the letter "q" in their name,
		# the regex is ideal tool to filter the rest out.
		
		if ( $file =~ /\A(?:q.)|(?:.q)\z/ )
		{
			# We have to open a filehandle for each file to be able to read them
			
			open my $fh, '<', $file or die $!;
			
			# We need only the first row from each file - although the diamond 
			# operator is in scalar context, there's no loop to iterate through
			# the file, we'll get only the value of the first row, saving some 
			# line of codes. 
			
			my $row = <$fh>;
			print "$row ";
			close $fh;
			
			# Printing the 51 value in matrix gives a better look for the list,
			# we need to use the modulus trick to break the line by tens.
			
			print "\n" if !( $q_file_counter % 10 );
			$q_file_counter++; 
		}
	}
	
	print "\n\n";
	
	# We don't need the directory handle anymore, so we close it explicitely.
	
	closedir $dh;
	
	# For getting rid of the "q-files" we can use glob combined with unlink, the latter reports 
	# the number of files deleted successfully. 
	
	print "Step 3. ", scalar ( unlink glob "?q q?" ), " Q-Files have been deleted, ";
	
	# To count the number of the remaining two-letter files the glob is ideal, as it actually returns
	# the name of the files, which can be directed into an array. The array in scalar context tells
	# us how many files the glob counted. 
	
	my @two_letter_files = glob "??";
	
	print "the number of files left (with two-letter name) is ", scalar @two_letter_files, ".\n\n";
}
	
