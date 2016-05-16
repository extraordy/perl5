#!/usr/local/bin/perl
use strict;
use warnings;

use Data::Dumper;
use lib "$ENV{HOME}/mylib/lib/perl5";
use HTML::TreeBuilder;
use LWP::Simple;

#------------------------------------------------------------------------------------------------------------			<----- Modified part 1
# Lab 12, Objective 1 

# Our objective is to extend the top_speakers.pl to email to us the entire list of speakers (not just 
# the top three) and the number of talks they gave, sorted as before. 

# These are the modules for sending simple emails

use Email::Sender::Simple;
use Email::Simple;
use Email::Simple::Creator;

# This module helps to easily determine the sender's hostname

use Sys::Hostname;

# Our global variables for the recipient's email address and the message to be sent

my $recipient = qw{cgaspar@telus.net};
my $message = "List of speakers and the number of talks they gave:\n\n";

#------------------------------------------------------------------------------------------------------------

my %speakers;
my $speaker;

my $URL = 'http://perl4.oreillyschool.com/conf-mirror/conferences.oreillynet.com/speakers.html';
my $tree = HTML::TreeBuilder->new;
$tree->parse( get( $URL ) );

frisk( $tree, 0 );

#------------------------------------------------------------------------------------------------------------			<----- Modified part 2
# Lab 12, Objective 1 

# As the output has to be assembled with a different intent, we need to reorganize our
# tasks by creating additional subroutines. prepare() will create the formatted message
# for the email body and transfer() is going to take care of the sending.

prepare(\$message);
transfer( $recipient, \$message );

#------------------------------------------------------------------------------------------------------------

sub frisk
{
    my ( $node, $depth ) = @_;

    if ( ref $node ) {
        $speaker = $node->as_text if (( $node->tag() eq 'a' ) and                                     
                                      ( defined $node->attr('href') ) and                             
                                      ( $node->attr('href') =~ /(e_spkr)/ ) and                       
                                      ( $node->as_text !~ /(Click)/ ));                               
 
 	push @{ $speakers{ $speaker } }, $node->as_text if (( $node->tag eq 'a' ) and                 
	                                                    ( defined $node->attr('href') ) and      
	                                                    ( $node->attr('href') =~ /(e_sess)/ ));   

        my @children = $node->content_list();
        for my $child_node (@children) {
            frisk( $child_node, $depth + 1 );
        }
    }
}


#------------------------------------------------------------------------------------------------------------			<----- Modified part 3
# Lab 12, Objective 1 

sub prepare
{
	my $msg = shift;
	
	for my $speaker ( sort { scalar @{ $speakers{ $b }} <=> scalar @{ $speakers{ $a }} } keys %speakers) {
		
		# Looping through the data structure we simply concatenate the speakers' name and result.
			
	    	$$msg .= $speaker." ( ".@{$speakers{ $speaker }}." )\n";
	}
}

# This part is so portable, it is almost completely the same as it was written in the lesson, I barely had to
# modify it. I tried to implement some unicode support, but finally decided not to, we haven't heard about 
# MIME types so far. 

sub transfer
{
	my ( $to, $msg ) = @_;
	
	my $user  = $ENV{USER};
	my $gecos = (getpwnam $user)[6];
	my $from  = "$user\@" . hostname();
	my $email = Email::Simple->create( 
			header => [
		           To      => qq{"$gecos" <$to>},
		           From    => qq{"$gecos" <$from>},
		           Subject => "List of speakers and the number of talks they gave",
		    ],
		    body => $$msg,
	);

	Email::Sender::Simple->send( $email );
}
	