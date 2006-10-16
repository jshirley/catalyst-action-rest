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
use Class::Inspector;

sub dispatch {
    my ( $self, $c ) = @_;

    my $controller = $self->class;
    my $method = $self->name . "_" . uc($c->request->method);
    if ($controller->can($method)) {
        return $controller->$method($c);
    } else {
        $self->_return_405($c);
        return $c->execute( $self->class, $self );
    }
}

sub _return_405 {
    my ( $self, $c ) = @_;

    my $controller = $self->class;
    my $methods = Class::Inspector->methods($controller);
    my @allowed;
    foreach my $method (@{$methods}) {
        my $name = $self->name;
        if ($method =~ /^$name\_(.+)$/) {
            push(@allowed, $1);
        }
    }
    $c->response->content_type('text/plain');
    $c->response->status(405);
    $c->response->header('Allow' => \@allowed);
    $c->response->body("Method " . $c->request->method . " not implemented for " . $c->uri_for($self->reverse));
}

1;
