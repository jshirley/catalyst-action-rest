#
# Catlyst::Action::Serialize::JSON.pm
# Created by: Adam Jacob, Marchex, <adam@marchex.com>
# Created on: 10/12/2006 03:00:32 PM PDT
#
# $Id$

package Catalyst::Action::Serialize::JSON;

use strict;
use warnings;

use base 'Catalyst::Action';
use JSON::Syck;

sub execute {
    my $self = shift;
    my ( $controller, $c ) = @_;

    my $stash_key = $controller->config->{'serialize'}->{'stash_key'} || 'rest';
    my $output;
    eval {
        $output = JSON::Syck::Dump($c->stash->{$stash_key});
    };
    if ($@) {
        return $@;
    }
    $c->response->output( $output );
    return 1;
}

1;
