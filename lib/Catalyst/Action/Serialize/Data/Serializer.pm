#
# Catalyst::Action::Serialize::Data::Serializer
# Created by: Adam Jacob, Marchex, <adam@marchex.com>
#
# $Id$

package Catalyst::Action::Serialize::Data::Serializer;

use strict;
use warnings;

use base 'Catalyst::Action';
use Data::Serializer;

sub execute {
    my $self = shift;
    my ( $controller, $c, $serializer ) = @_;

    my $stash_key = $controller->serialize->{'stash_key'} || 'rest';
    my $dso = Data::Serializer->new( serializer => $serializer );
    $c->response->output( $dso->raw_serialize( $c->stash->{$stash_key} ) );
    return 1;
}

1;
