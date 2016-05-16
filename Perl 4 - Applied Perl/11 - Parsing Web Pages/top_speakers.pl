#!/usr/local/bin/perl
use strict;
use warnings;
use Data::Dumper;

# The objective requires us to extract the top three speakers indicated 
# in our designated URL by count of the number of sessions and/or 
# tutorials they are presenting.

# CPAN documents for the preparation:
# http://search.cpan.org/~cjm/HTML-Tree-5.03/lib/HTML/Element.pm#tag
# http://search.cpan.org/~cjm/HTML-Tree-5.03/lib/HTML/TreeBuilder.pm

use lib "$ENV{HOME}/mylib/lib/perl5";
use HTML::TreeBuilder;
use LWP::Simple;

# This is our target URL

my $URL = 'http://perl4.oreillyschool.com/conf-mirror/conferences.oreillynet.com/speakers.html';

my $tree = HTML::TreeBuilder->new;

my %speakers;
my $speaker;

$tree->parse( get( $URL ) );

# After our target HTML page is parsed, we need to traverse across the node tree recursively
# to double check each anchor node where the speaker and the corresponding lecture name 
# anchor nodes are indicated. Because there's no hierarchical structural (parent-child) 
# relationship between the two kinds of anchors, we need to use the node sequence to  
# unfold and preserve the connection between speakers and their lectures. The HTML::Element 
# CPAN module features are powerful tools, but without the recursive traversing we wouldn't 
# be able to model this relationship in our data structure. 

frisk( $tree, 0 );

# When the data structure (hash of arrayrefs) is built and populated, we need to sort this
# complex hash on its values in a descending order and print the first three speakers with 
# the highest number of lectures. The beauty of this solution is that we captured and stored
# not only the number of lectures per speaker, but the titles of the lectures as well.

announce();

# Dumping is a precious tool when testing, either using the one available from the Data::Dumper
# or from the HTML::Element modules.

# print Dumper %speakers;

# The frisk() subroutine does the traversing calling itself deeper and deeper into the node tree 
# until it finds the last descendants by following each branch. 

sub frisk
{
    my ( $node, $depth ) = @_;

    if ( ref $node ) {
    	
    	# The sequence of our target nodes will mimic their true relationship, hence we need to
    	# find the speakers, then any following lectures. 
    	
    	#  
	
        $speaker = $node->as_text if (( $node->tag() eq 'a' ) and                                     # The "speaker node" must be an anchor,
                                      ( defined $node->attr('href') ) and                             # it has to have a 'href' attribute, 
                                      ( $node->attr('href') =~ /(e_spkr)/ ) and                       # which holds an important distinction (e_spkr), 
                                      ( $node->as_text !~ /(Click)/ ));                               # but doesn't contain a certain text (Click).
        
	push @{ $speakers{ $speaker } }, $node->as_text if (( $node->tag eq 'a' ) and                 # The "lecture node" must be an anchor,
	                                                    ( defined $node->attr('href') ) and       # it also has to have a 'href' attribute, 
	                                                    ( $node->attr('href') =~ /(e_sess)/ ));   # which holds an important distinction (e_sess).

	# The recursion is implemeted below. First we get the chidren nodes of our actual node.
	# Looping through them we run frisk() on each one.
	
        my @children = $node->content_list();
        for my $child_node (@children) {
            frisk( $child_node, $depth + 1 );
        }
    }
}

# The result is printed by announce() subroutine.  

sub announce
{
	my $cnt = 0;
	
	# We need to loop through the speakers hash to find its keys to be able to sort its elements 
	# by value. As the real value in this hash stores array references, we need to 
	# dereference those and put them into scalar context in order to get the number of lectures  
	# for each speaker. When we printed the first three with the highest numbers, we abandon 
	# the loop and the subroutine.
	
	for my $speaker ( sort { scalar @{ $speakers{ $b }} <=> scalar @{ $speakers{ $a }} } keys %speakers) {
	    printf "%-20s (%d)\n", $speaker, scalar @{$speakers{ $speaker }};
	     last if ++$cnt == 3;
	}
}
	