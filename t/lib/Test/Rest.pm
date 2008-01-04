#
# Rest.pm
# Created by: Adam Jacob, Marchex, <adam@hjksolutions.com>
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
    my %p    = validate( @_, { 
            content_type => { type => SCALAR }, 
        }, 
    );
    my $ref  = {
        'ua'           => LWP::UserAgent->new,
        'content_type' => $p{'content_type'},
    };
    bless $ref, $self;
}

{
    my @non_data_methods = qw(GET DELETE OPTIONS);
    foreach my $method (@non_data_methods) {
        no strict 'refs';
        my $sub = lc($method);
        *$sub = sub {
            my $self = shift;
            my %p    = validate( @_, { url => { type => SCALAR }, }, );
            my $req  = HTTP::Request->new( "$method" => $p{'url'} );
            $req->content_type( $self->{'content_type'} );
            return $req;
        };
    }

    my @data_methods = qw(PUT POST);
    foreach my $method (@data_methods) {
        no strict 'refs';
        my $sub = lc($method);
        *{$sub} = sub {
            my $self = shift;
            my %p    = validate(
                @_,
                {
                    url  => { type => SCALAR },
                    data => 1,
                },
            );
            my $req = HTTP::Request->new( "$method" => $p{'url'} );
            $req->content_type( $self->{'content_type'} );
            $req->content_length(
                do { use bytes; length( $p{'data'} ) }
            );
            $req->content( $p{'data'} );
            return $req;
        };
    }
}

1;

