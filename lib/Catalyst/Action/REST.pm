#
# REST.pm
# Created by: Adam Jacob, Marchex, <adam@marchex.com>
# Created on: 10/12/2006 03:00:32 PM PDT
#
# $Id$

package Catalyst::Action::REST;

use strict;
use warnings;

use base 'Catalyst::Action';

sub dispatch {
    my ( $self, $c ) = @_;

    my $controller = $self->class;
    my $method = $self->name . "_" . uc($c->request->method);
    if ($controller->can($method)) {
        $c->log->debug("REST ActionClass is calling $method");
        return $controller->$method($c);
    } else {
        $c->log->debug("REST ActionClass is calling " . $self->name);
        return $c->execute( $self->class, $self );
    }
}

1;
