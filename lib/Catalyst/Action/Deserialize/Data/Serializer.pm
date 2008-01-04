#
# Catalyst::Action::Deserialize::Data::Serializer.pm
# Created by: Adam Jacob, Marchex, <adam@hjksolutions.com>
# Created on: 10/12/2006 03:00:32 PM PDT
#
# $Id$

package Catalyst::Action::Deserialize::Data::Serializer;

use strict;
use warnings;

use base 'Catalyst::Action';
use Data::Serializer;

sub execute {
    my $self = shift;
    my ( $controller, $c, $serializer ) = @_;

    my $sp = $serializer;
    $sp =~ s/::/\//g;
    $sp .= ".pm";
    eval {
        require $sp
    };
    if ($@) {
        $c->log->debug("Could not load $serializer, refusing to serialize: $@")
            if $c->debug;
        return 0;
    }
    my $body = $c->request->body;
    if ($body) {
        my $rbody;
        if ( -f $c->request->body ) {
            open( BODY, "<", $c->request->body );
            while ( my $line = <BODY> ) {
                $rbody .= $line;
            }
            close(BODY);
        }
        my $dso = Data::Serializer->new( serializer => $serializer );
        my $rdata;
        eval {
            $rdata = $dso->raw_deserialize($rbody);
        };
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
