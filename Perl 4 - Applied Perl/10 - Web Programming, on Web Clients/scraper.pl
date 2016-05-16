#!/usr/local/bin/perl
use strict;
use warnings;

# Our goal is to scrape part of the O'Reilly School of Technology static mirror site 
# (http://perl4.oreillyschool.com/ost-mirror/). Using WWW::Mechanize, we have to follow 
# the link labelled 'Contact', then to fill in just our name on the form on the next 
# page (this is the first visible field), and submit the form.

# If we have done this correctly, the resulting page will contain an answer to the 
# riddle: "Why is a camel like a lemon?" The answer will be between the 
# tags <B>...</B> and there will be no other angle brackets on the page. 

use lib "$ENV{HOME}/mylib/lib/perl5";
use WWW::Mechanize;

# The web server of the static mirror currently is having an operational upset,
# it fetches rather than executing CGI files, so I needed to remodell the 
# necessary page structure under my student account for the sake of the
# demonstration (I also contacted the OST technical support coordinator).

# The static mirror won't work as expected:
# my $URL = 'http://perl4.oreillyschool.com/ost-mirror/';

# Here's the local address for the working CGI

my $URL = 'http://cgaspar.oreillystudent.com/project4/practice_10/';

# First, we need to create a Mechanize object.

my $mech = WWW::Mechanize->new;

# The get method fetches the page content from index.html

$mech->get( $URL );
$mech->success or die $mech->res->message;

# We need to follow the 'Contact' link, which leads us to a contact 
# form. 

$mech->follow_link( text => 'Contact' );

my $content = $mech->content;
$content =~ /Your Message/ or die "Page contents mismatch";

# The contact.cgi will send back two kinds of response depending on 
# how it was invoked: if the request came from the contact.html page 
# (via the submitform() Java Script function), the CGI script 
# prompts us to write the WWW::Mechanize script to find the solution.
# If we get to the CGI script using WWW::Mechanize, it revails the
# answer to the riddle.

# Let's submit the value for the first form element.
 
$mech->set_visible( 'Csaba Gaspar' );
$mech->submit->is_success or die $mech->res->message;

# We need to get the content again, this time it comes directly from 
# the contact.cgi. 

$content = $mech->content;

# If the contact.cgi is properly executed by the web server, the answer
# is interpolated into the response as a substring, so we can find it 
# between the opening <B> and closing </B> HTML tag using regex, and
# we can print the solution at the same time.

$content =~ /B>(.*)</ and print "The answer to the riddle is: $1\n";

