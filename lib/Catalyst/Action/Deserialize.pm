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

=head1 NAME

Catalyst::Action::Deserialize - Deserialize Data in a Request

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

    sub begin : ActionClass('Deserialize') {}

=head1 DESCRIPTION

This action will deserialize HTTP POST, PUT, and OPTIONS requests.
It assumes that the body of the HTTP Request is a serialized object.
The serializer is selected by introspecting the requests content-type
header.

It requires that your Catalyst controller have a "serialize" entry
in it's configuration.

The specifics of deserializing each content-type is implemented as
a plugin to L<Catalyst::Action::Deserialize>.  You can see a list
of currently implemented plugins in L<Catalyst::Controller::REST>.

The results of your Deserializing will wind up in $c->req->data.
This is done through the magic of L<Catalyst::Request::REST>.

=head1 CONFIGURATION

=over 4

=item default

The default Serialization format.  See the next section for
available options.

=item map

Takes a hashref, mapping Content-Types to a given plugin.

=back

=head1 SEE ALSO

You likely want to look at L<Catalyst::Controller::REST>, which implements
a sensible set of defaults for a controller doing REST.

L<Catalyst::Action::Serialize>, L<Catalyst::Action::REST>

=head1 AUTHOR

Adam Jacob <adam@stalecoffee.org>, with lots of help from mst and jrockway

Marchex, Inc. paid me while I developed this module.  (http://www.marchex.com)

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut

1;
