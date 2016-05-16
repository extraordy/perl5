#!/usr/bin/perl
use strict;
use warnings;

# Main program **********************************************************************

# User needs to specify the music files as command line arguments

die "Usage: $0 path_to_music_files...\n" unless @ARGV > 0;

# We need to save the file names in order to extract the artist names

my @music_files = @ARGV;
my %play_times;

foreach my $file ( @music_files )
{
	# Let's get the artist name, the rest will be ignored
	
 	my ( $artist_name, $song_title ) = extract_artist( $file );
     
        # When the artist name is extracted, we can check if we have already stored it
        # in %play_times, the play time recording hash. If this is the first time, 
        # its corresponding value pair will be set to undef, providing an elegant way 
        # to indicate, that the value hasn't yet been initialized.
          
	$play_times{ $artist_name } = undef unless exists $play_times{ $artist_name };
	
	# Now, we can read the file content of the current file
	
	@ARGV = $file;
	
	 while ( defined( my $line = <> ) )
	{
	        # We will jump out from the loop in case we have more lines,
	        # only the first one means value for us.
	        
		last unless $. == 1;
		chomp $line;
		
		# Let's get the play time, the rest will be ignored
		
		my ( $album, $play_time, $genre ) = extract_play_time( $line );
		
		# If the artist of the current song han't been recorded so far,
		# its time value will be undef, which indicates that we don't have
		# to care about any previous value, otherwise we need to add 
		# the current play time to a previously recorded one.
		
		if ( defined $play_times{ $artist_name } )
		{
			$play_times{ $artist_name } += $play_time;
		}
		else
		{
			$play_times{ $artist_name } = $play_time;
		}		
	}	
}

# The result is ready, all we need to do is loop through the paly_times hash
# and print the key-value pairs out.

foreach my $key ( keys %play_times )
{
	print $key, " has a total of ", $play_times{ $key }, " in music ";
}

print "\n";

# Subroutines **********************************************************************


# extract_artist() returns the artist name (and song title) from the given file path

sub extract_artist
{
	my $path = shift;
	
	if ( defined $path )
	{
                # rindex() finds the last occurrence of the slash character
                # in the path, above this position comes the file name, which we
                # split into artist name and song title using the dash.
                 
		return split( "-", substr( $path, rindex( $path, "/" ) + 1 ))
	}
	else
	{
		die "Invalid music file path at extract_play_time(): $path\n";		
	}
}

# extract_play_time() returns the play time (,the album name and the genre) from 
# the given description line

sub extract_play_time
{
	my $description = shift;
	
	if ( defined $description )
	{
	        # The description line consists of album name, play time and genre,
	        # all we need to do is split this up using colon and return the list 
	        # of these tree values.
	        
		return split( ":", $description );
	}
	else
	{
		die "Invalid description line at extract_artist(): $description\n";		
	}
}
