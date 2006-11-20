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
    unless ( defined( $self->plugins ) ) {
        my $mpo = Module::Pluggable::Object->new(
            'require'     => 1,
            'search_path' => ['Catalyst::Action::Serialize'],
        );
        my @plugins = $mpo->plugins;
        $self->plugins( \@plugins );
    }

    # Look up what serializer to use from content_type map
    #
    # If we don't find one, we use the default
    my $content_type = $c->request->content_type;
    my $sclass       = 'Catalyst::Action::Serialize::';
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

    # Go ahead and serialize ourselves
    if ( defined($sarg) ) {
        $sclass->execute( $controller, $c, $sarg );
    } else {
        $sclass->execute( $controller, $c );
    }

    if ( !$c->response->content_type ) {
        $c->response->content_type( $c->request->content_type );
    }

    return 1;
}

1;

=head1 NAME

Catalyst::Action::Serialize - Serialize Data in a Response

=head1 SYNOPSIS

    package Foo::Controller::Bar;

    __PACKAGE__->config(
        serialize => {
            'default'   => 'YAML',
            'stash_key' => 'rest',
            'map'       => {
                'text/x-yaml'        => 'YAML',
                'text/x-data-dumper' => [ 'Data::Serializer', 'Data::Dumper' ],
            },
        }
    );

    sub end : ActionClass('Serialize') {}

=head1 DESCRIPTION

This action will serialize the body of an HTTP Response.  The serializer is
selected by introspecting the requests content-type header.

It requires that your Catalyst controller have a "serialize" entry
in it's configuration.

The specifics of serializing each content-type is implemented as
a plugin to L<Catalyst::Action::Serialize>.

=head1 CONFIGURATION

=over 4

=item default

The default Serialization format.  See the next section for
available options.  This is used if a requested content-type
is not recognized.

=item stash_key 

Where in the stash the data you want serialized lives.

=item map

Takes a hashref, mapping Content-Types to a given plugin.

=back

=head1 SEE ALSO

You likely want to look at L<Catalyst::Controller::REST>, which implements
a sensible set of defaults for a controller doing REST.

L<Catalyst::Action::Deserialize>, L<Catalyst::Action::REST>

=head1 AUTHOR

Adam Jacob <adam@stalecoffee.org>, with lots of help from mst and jrockway

Marchex, Inc. paid me while I developed this module.  (http://www.marchex.com)

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut
