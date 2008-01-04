#
# Catlyst::Action::Serialize::XML::Simple.pm
# Created by: Adam Jacob, Marchex, <adam@hjksolutions.com>
# Created on: 10/12/2006 03:00:32 PM PDT
#
# $Id$

package Catalyst::Action::Serialize::XML::Simple;

use strict;
use warnings;

use base 'Catalyst::Action';

sub execute {
    my $self = shift;
    my ( $controller, $c ) = @_;

    eval {
        require XML::Simple
    };
    if ($@) {
        $c->log->debug("Could not load XML::Serializer, refusing to serialize: $@")
            if $c->debug;
        return 0;
    }
    my $xs = XML::Simple->new(ForceArray => 0,);

    my $stash_key = (
            $controller->config->{'serialize'} ?
                $controller->config->{'serialize'}->{'stash_key'} :
                $controller->config->{'stash_key'} 
        ) || 'rest';
    my $output;
    eval {
        $output = $xs->XMLout({ data => $c->stash->{$stash_key} });
    };
    if ($@) {
        return $@;
    }
    $c->response->output( $output );
    return 1;
}

1;
