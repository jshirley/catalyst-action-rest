#
# Catlyst::Action::Serialize::YAML.pm
# Created by: Adam Jacob, Marchex, <adam@marchex.com>
# Created on: 10/12/2006 03:00:32 PM PDT
#
# $Id$

package Catalyst::Action::Serialize::YAML;

use strict;
use warnings;

use base 'Catalyst::Action';
use YAML::Syck;

sub execute {
    my $self = shift;
    my ( $controller, $c, $test ) = @_;

    my $stash_key = $controller->serialize->{'stash_key'} || 'rest';
    $c->response->output( Dump( $c->stash->{$stash_key} ) );
    return 1;
}

1;
