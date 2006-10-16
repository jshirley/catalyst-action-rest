#
# Catlyst::Action::Deserialize
# Created by: Adam Jacob, Marchex, <adam@marchex.com>
#
# $Id$

package Catalyst::Action::Deserialize;

use strict;
use warnings;

use base 'Catalyst::Action';
use Module::Pluggable::Object;
use Catalyst::Request::REST;

__PACKAGE__->mk_accessors(qw(plugins));

sub execute {
    my $self = shift;
    my ( $controller, $c, $test ) = @_;

    my $nreq = bless( $c->request, 'Catalyst::Request::REST' );
    $c->request($nreq);

    unless ( defined( $self->plugins ) ) {
        my $mpo = Module::Pluggable::Object->new(
            'require'     => 1,
            'search_path' => ['Catalyst::Action::Deserialize'],
        );
        my @plugins = $mpo->plugins;
        $self->plugins( \@plugins );
    }
    my $content_type = $c->request->content_type;
    my $sclass       = 'Catalyst::Action::Deserialize::';
    my $sarg;
    my $map = $controller->serialize->{'map'};
    if ( exists( $map->{$content_type} ) ) {
        my $mc;
        if ( ref( $map->{$content_type} ) eq "ARRAY" ) {
            $mc   = $map->{$content_type}->[0];
            $sarg = $map->{$content_type}->[1];
        } else {
            $mc = $map->{$content_type};
        }
        $sclass .= $mc;
        if ( !grep( /^$sclass$/, @{ $self->plugins } ) ) {
            die "Cannot find plugin $sclass for $content_type!";
        }
    } else {
        if ( exists( $controller->serialize->{'default'} ) ) {
            $sclass .= $controller->serialize->{'default'};
        } else {
            die "I cannot find a default serializer!";
        }
    }

    my @demethods = qw(POST PUT OPTIONS);
    my $method    = $c->request->method;
    if ( grep /^$method$/, @demethods ) {
        if ( defined($sarg) ) {
            $sclass->execute( $controller, $c, $sarg );
        } else {
            $sclass->execute( $controller, $c );
        }
        $self->NEXT::execute( @_, );
    } else {
        $self->NEXT::execute(@_);
    }
}

1;
