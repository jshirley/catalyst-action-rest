package SampleREST::Controller::Monkey;

use strict;
use warnings;
use base 'Catalyst::Controller::REST';

sub myindex :Path :Args(0) :ActionClass('REST') {}

sub myindex_GET {
    my ( $self, $c, $rdata ) = @_;

    $c->stash->{'rest'} = {
        'monkey' => 'likes chicken!',
    };
}

sub myindex_POST {
    my ( $self, $c, $rdata ) = @_;

    $c->stash->{'rest'} = $c->request->data;
}

1;
