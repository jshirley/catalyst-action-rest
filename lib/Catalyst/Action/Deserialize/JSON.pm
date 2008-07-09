#
# Catlyst::Action::Deserialize::JSON.pm
# Created by: Adam Jacob, Marchex, <adam@hjksolutions.com>
# Created on: 10/12/2006 03:00:32 PM PDT
#
# $Id$

package Catalyst::Action::Deserialize::JSON;

use strict;
use warnings;

use base 'Catalyst::Action';
use JSON qw( decode_json );

sub execute {
    my $self = shift;
    my ( $controller, $c, $test ) = @_;

    my $body = $c->request->body;
    my $rbody;

    if ($body) {
        while (my $line = <$body>) {
            $rbody .= $line;
        }
    }

    if ( $rbody ) {
        my $rdata = eval { decode_json( $rbody ) };
        if ($@) {
            return $@;
        }
        $c->request->data($rdata);
    } else {
        $c->log->debug(
            'I would have deserialized, but there was nothing in the body!')
            if $c->debug;
    }
    return 1;
}

1;
