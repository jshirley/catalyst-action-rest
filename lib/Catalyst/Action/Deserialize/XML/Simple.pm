#
# Catlyst::Action::Deserialize::XML::Simple.pm
# Created by: Adam Jacob, Marchex, <adam@marchex.com>
# Created on: 10/12/2006 03:00:32 PM PDT
#
# $Id$

package Catalyst::Action::Deserialize::XML::Simple;

use strict;
use warnings;

use base 'Catalyst::Action';

sub execute {
    my $self = shift;
    my ( $controller, $c, $test ) = @_;

    eval {
        require XML::Simple;
    };
    if ($@) {
        $c->log->debug("Could not load XML::Simple, refusing to deserialize: $@");
        return 0;
    }

    my $body = $c->request->body;
    if ($body) {
        my $xs = XML::Simple->new('ForceArray' => 0,);
        my $rdata;
        eval {
            $rdata = $xs->XMLin( "$body" );
        };
        if ($@) {
            return $@;
        }
        if (exists($rdata->{'data'})) {
            $c->request->data($rdata->{'data'});
        } else {
            $c->request->data($rdata);
        }
    } else {
        $c->log->debug(
            'I would have deserialized, but there was nothing in the body!');
    }
    return 1;
}

1;
