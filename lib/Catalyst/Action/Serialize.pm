#
# Catlyst::Action::Serialize.pm
# Created by: Adam Jacob, Marchex, <adam@hjksolutions.com>
#
# $Id$

package Catalyst::Action::Serialize;

use strict;
use warnings;

use base 'Catalyst::Action::SerializeBase';
use Module::Pluggable::Object;
use Data::Dump qw(dump);

sub execute {
    my $self = shift;
    my ( $controller, $c ) = @_;

    $self->NEXT::execute(@_);

    return 1 if $c->req->method eq 'HEAD';
    return 1 if length( $c->response->body );
    return 1 if scalar @{ $c->error };
    return 1 if $c->response->status =~ /^(?:204|3\d\d)$/;

    my ( $sclass, $sarg, $content_type ) =
      $self->_load_content_plugins( "Catalyst::Action::Serialize",
        $controller, $c );
    unless ( defined($sclass) ) {
        if ( defined($content_type) ) {
            $c->log->info("Could not find a serializer for $content_type");
        } else {
            $c->log->info(
                "Could not find a serializer for an empty content type");
        }
        return 1;
    }
    $c->log->debug(
        "Serializing with $sclass" . ( $sarg ? " [$sarg]" : '' ) ) if $c->debug;

    my $rc;
    if ( defined($sarg) ) {
        $rc = $sclass->execute( $controller, $c, $sarg );
    } else {
        $rc = $sclass->execute( $controller, $c );
    }
    if ( $rc eq 0 ) {
        return $self->_unsupported_media_type( $c, $content_type );
    } elsif ( $rc ne 1 ) {
        return $self->_serialize_bad_request( $c, $content_type, $rc );
    }

    return 1;
}

1;

=head1 NAME

Catalyst::Action::Serialize - Serialize Data in a Response

=head1 SYNOPSIS

    package Foo::Controller::Bar;

    __PACKAGE__->config(
        'default'   => 'text/x-yaml',
        'stash_key' => 'rest',
        'map'       => {
            'text/html'          => [ 'View', 'TT', ],
            'text/x-yaml'        => 'YAML',
            'text/x-data-dumper' => [ 'Data::Serializer', 'Data::Dumper' ],
        }
    );

    sub end :ActionClass('Serialize') {}

=head1 DESCRIPTION

This action will serialize the body of an HTTP Response.  The serializer is
selected by introspecting the HTTP Requests content-type header.

It requires that your Catalyst controller is properly configured to set up the
mapping between Content Type's and Serialization classes.

The specifics of serializing each content-type is implemented as a plugin to
L<Catalyst::Action::Serialize>.

Typically, you would use this ActionClass on your C<end> method.  However,
nothing is stopping you from choosing specific methods to Serialize:

  sub foo :Local :ActionClass('Serialize') {
     .. populate stash with data ..
  }

When you use this module, the request class will be changed to
L<Catalyst::Request::REST>.

=head1 CONFIGURATION

=head2 map

Takes a hashref, mapping Content-Types to a given serializer plugin.

=head2 default

This is the 'fall-back' Content-Type if none of the requested or acceptable
types is found in the L</map>. It must be an entry in the L</map>.

=head2 stash_key 

Specifies the key of the stash entry holding the data that is to be serialized.
So if the value is "rest", we will serialize the data under:

  $c->stash->{'rest'}

=head2 content_type_stash_key

Specifies the key of the stash entry that optionally holds an overriding
Content-Type. If set, and if the specified stash entry has a valid value,
then it takes priority over the requested content types.

This can be useful if you want to dynamically force a particular content type,
perhaps for debugging.

=head1 HELPFUL PEOPLE

Daisuke Maki pointed out that early versions of this Action did not play
well with others, or generally behave in a way that was very consistent
with the rest of Catalyst. 

=head1 SEE ALSO

You likely want to look at L<Catalyst::Controller::REST>, which implements
a sensible set of defaults for doing a REST controller.

L<Catalyst::Action::Deserialize>, L<Catalyst::Action::REST>

=head1 AUTHOR

Adam Jacob <adam@stalecoffee.org>, with lots of help from mst and jrockway

Marchex, Inc. paid me while I developed this module.  (http://www.marchex.com)

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut

