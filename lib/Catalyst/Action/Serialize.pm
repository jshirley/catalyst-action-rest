#
# Catlyst::Action::Serialize.pm
# Created by: Adam Jacob, Marchex, <adam@marchex.com>
#
# $Id$

package Catalyst::Action::Serialize;

use strict;
use warnings;

use base 'Catalyst::Action';
use Module::Pluggable::Object;

__PACKAGE__->mk_accessors(qw(plugins));

sub execute {
    my $self = shift;
    my ( $controller, $c ) = @_;

    return 1 if $c->req->method eq 'HEAD';
    return 1 if length( $c->response->body );
    return 1 if scalar @{ $c->error };
    return 1 if $c->response->status =~ /^(?:204|3\d\d)$/;

    # Load the Serialize Classes
    unless(defined($self->plugins)) {
        my $mpo = Module::Pluggable::Object->new(
            'require' => 1,
            'search_path' => [ 'Catalyst::Action::Serialize' ],
        );
        my @plugins = $mpo->plugins;
        $self->plugins(\@plugins);
    }

    # Look up what serializer to use from content_type map
    # 
    # If we don't find one, we use the default
    my $content_type = $c->request->content_type;
    my $sclass = 'Catalyst::Action::Serialize::';
    my $sarg;
    my $map = $controller->serialize->{'map'};
    if (exists($map->{$content_type})) {
        my $mc;
        if (ref($map->{$content_type}) eq "ARRAY") {
            $mc = $map->{$content_type}->[0];
            $sarg = $map->{$content_type}->[1];
        } else {
            $mc = $map->{$content_type};
        }
        $sclass .= $mc;
        if (! grep(/^$sclass$/, @{$self->plugins})) {
            die "Cannot find plugin $sclass for $content_type!";
        }
    } else {
        if (exists($controller->serialize->{'default'})) {
            $sclass .= $controller->serialize->{'default'};
        } else {
            die "I cannot find a default serializer!";
        }
    }

    # Go ahead and serialize ourselves
    if (defined($sarg)) {
        $sclass->execute($controller, $c, $sarg);
    } else {
        $sclass->execute($controller, $c);
    }

    if (! $c->response->content_type ) {
        $c->response->content_type($c->request->content_type);
    }

    return 1;
};

1;
