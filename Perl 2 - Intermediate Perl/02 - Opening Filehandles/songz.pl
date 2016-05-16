#!/usr/bin/perl
use strict;
use warnings;

# We must obtain the music file name through a command line argument

die "Usage: $0 path_to_songz.txt...\n" unless @ARGV == 1;

my ( $songz_file ) = @ARGV;		# Scalar assigned to the music file name
my $MP3_SONG_PATH = "~/perl2/music/";	# Scalar assigned to the destination path of the song files

# The naked block ensures that our lexical filehandle to the music file will be closed 
# implicitly when control gets outside of the block

{

  # We declare our lexical filehandle to the music file and open the file for reading   

  open my $fh, '<', $songz_file or die "Couldn't open $songz_file: $!\n";

  # We read the music file line by line
  
  while ( my $line = <$fh> )
  {
	  chomp $line;
	  
	  # Now, we are able to split the line into a list of scalars using colon as a pattern
	  
	  my ( $artist_name, $song_title, $album_name, $play_time, $genre ) = split ":", $line;
	  
	  # Since each line represents a new file in the specified destination subdirectory
	  # we can use this loop to create the particular file right away. We need another 
	  # filehandle to create a file and open it for writing. We can declare another filehandle 
	  # using the same name, if we place it in a different scope. Like the other filehandle in 
	  # its own scope, this filehandle will also be closed when the control leaves the block.
	  
	  {
	  	# The song file names consist of the artist name and the song title separated 
	  	# by a dash. We need to tell open() what subdirectory to use to place the 
	  	# files, so we need to apply the proper path to the song file names. 
	  	
	  	my $MP3_SONG = $MP3_SONG_PATH.$artist_name."-".$song_title;
	  	
	  	# I didn't want to use relative path as a destination in order to ensure, 
	  	# that whereever the program is run, the files will always be created in 
	  	# my perl2 subdirectory. Since I don't know the absolute path to my home directory,
	  	# I had to use tilde in the path scalar, which has to be expanded for open(),
	  	# otherwise it won't be able to interpret it. For this, I had to use glob().
	  	
	  	open my $fh, '>', glob( $MP3_SONG ) or die "Couldn't open $MP3_SONG: $!\n";	
	  	
	  	# The final step is to write the album name, play time and genre into the file
	  	# separated by colon. 
	  	
	  	print { $fh } $album_name.":". $play_time.":".$genre;	  	
	  }
	  
	  # Inner file handle now closed	   
  }
  
  # Outer filehandle now closed
  
}

print "Done - music files have been created in $MP3_SONG_PATH directory.\n";
