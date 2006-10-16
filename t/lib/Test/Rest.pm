#
# Rest.pm
# Created by: Adam Jacob, Marchex, <adam@marchex.com>
# Created on: 10/16/2006 11:11:25 AM PDT
#
# $Id: $

package Test::Rest;

use strict;
use warnings;

use LWP::UserAgent;
use Params::Validate qw(:all);

sub new {
    my $self = shift;
    my %p = validate(@_,
        {
            content_type => { type => SCALAR },
        },
    );
    my $ref = { 
        'ua' => LWP::UserAgent->new,
        'content_type' => $p{'content_type'},
    };
    bless $ref, $self;
}

sub get {
    my $self = shift;
    my %p = validate(@_,
        {
            url => { type => SCALAR },
        },
    );
    my $req = HTTP::Request->new('GET' => $p{'url'});
    $req->content_type($self->{'content_type'});
    return $req;
}

sub delete {
    my $self = shift;
    my %p = validate(@_,
        {
            url => { type => SCALAR },
        },
    );
    my $req = HTTP::Request->new('DELETE' => $p{'url'});
    $req->content_type($self->{'content_type'});
    return $req;
}

sub put {
    my $self = shift;
    my %p = validate(@_,
        {
            url => { type => SCALAR },
            data => 1,
        },
    );
    my $req = HTTP::Request->new('PUT' => $p{'url'});
    $req->content_type($self->{'content_type'});
    $req->content_length(do { use bytes; length($p{'data'}) });
    $req->content($p{'data'});
    return $req;
}

sub post {
    my $self = shift;
    my %p = validate(@_,
        {
            url => { type => SCALAR },
            data => { required => 1 },
        },
    );
    my $req = HTTP::Request->new('POST' => $p{'url'});
    $req->content_type($self->{'content_type'});
    $req->content_length(do { use bytes; length($p{'data'}) });
    $req->content($p{'data'});
    return $req;
}


1;

