#!/usr/bin/env perl
use strict;
use warnings;
use vars qw($VERSION %IRSSI);
use Irssi;
use LWP::UserAgent;

$VERSION = '0.01';
%IRSSI = (
    authors     => 'Jan Tore Morken',
    contact     => 'http://wobbled.org/contact/',
    name        => 'last dot pl',
    description => 'Grabs last played tracks from last.fm RSS feed',
    license     => 'GNU GPLv2',
    url         => 'http://wobbled.org/',
);

our $userName = 'myLastFmUsername';

sub getTracks {
    my @tracks = ();

    my $ua = LWP::UserAgent->new;
    $ua->timeout(10);

    my $response = $ua->get('http://ws.audioscrobbler.com/1.0/user/' . $userName . '/recenttracks.rss');

    return @tracks if(!$response->is_success);
    my $content = $response->content;
    while($content =~ /<item>[\n ]*<title>([^<]*)<\/title>/g) {
        push(@tracks, $1);
    }
    
    return @tracks;
}

sub cmd_lastfm {
    my($data, $server, $window) = @_;
    my @tracks = getTracks();

    return if(!(scalar(@tracks) > 0));
    my $last = $tracks[0];

    if($window && ($window->{type} eq "CHANNEL" || $window->{type} eq "QUERY")) {
	$window->command("ME & " . $last);
    }
}


Irssi::command_bind('lastfm', 'cmd_lastfm');
