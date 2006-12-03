#
# Catlyst::Action::SerializeBase.pm
# Created by: Adam Jacob, Marchex, <adam@marchex.com>
#
# $Id$

package Catalyst::Action::SerializeBase;

use strict;
use warnings;

use base 'Catalyst::Action';
use Module::Pluggable::Object;
use Data::Dump qw(dump);
use HTTP::Headers::Util qw(split_header_words);

__PACKAGE__->mk_accessors(qw(_serialize_plugins _loaded_plugins));

sub _load_content_plugins {
    my $self = shift;
    my ( $search_path, $controller, $c ) = @_;

    unless ( defined( $self->_loaded_plugins ) ) {
        $self->_loaded_plugins( {} );
    }

    # Load the Serialize Classes
    unless ( defined( $self->_serialize_plugins ) ) {
        my @plugins;
        my $mpo =
          Module::Pluggable::Object->new( 'search_path' => [$search_path], );
        @plugins = $mpo->plugins;
        $self->_serialize_plugins( \@plugins );
    }

    # First, we use the content type in the HTTP Request.  It wins all.
    my $content_type = $c->request->content_type || '';

    # Second, we allow GET requests to tunnel the content-type as
    #  a query param.
    if (!$content_type && $c->req->method eq "GET" && $c->req->param('content-type')) {

        $content_type = $c->req->param('content-type');
    }

    # Third, we parse the Accept header, and see if the client
    # takes a format we understand.
    #
    # This is taken from chansen's Apache2::UploadProgress.
    my $used_accept = 0;
    if ( !$content_type && $c->request->header('Accept') ) {
        my $accept_header = $c->request->header('Accept');
        my %accept        = ();
        my $counter       = 0;

        foreach my $pair ( split_header_words($accept_header) ) {

            my ( $type, $qvalue ) = @{$pair}[ 0, 3 ];

            unless ( defined $qvalue ) {
                $qvalue = 1 - ( ++$counter / 1000 );
            }

            $accept{$type} = sprintf( '%.3f', $qvalue );
        }

        foreach my $type ( sort { $accept{$b} <=> $accept{$a} } keys %accept )
        {

            if ( exists $controller->config->{'serialize'}->{'map'}->{$type} )
            {
                $content_type = $type;
                last;
            }
        }
        $used_accept = 1;
    }

    # Finally, we load the class.  If you have a default serializer,
    # and we still don't have a content-type that exists in the map,
    # we'll use it.
    my $sclass = $search_path . "::";
    my $sarg;
    my $map = $controller->config->{'serialize'}->{'map'};
    if ( exists( $map->{$content_type} ) ) {
        my $mc;
        if ( ref( $map->{$content_type} ) eq "ARRAY" ) {
            $mc   = $map->{$content_type}->[0];
            $sarg = $map->{$content_type}->[1];
        } else {
            $mc = $map->{$content_type};
        }
        # TODO: Handle custom serializers more elegantly.. this is a start,
        # but how do we determine which is Serialize and Deserialize?
        #if ($mc =~ /^+/) {
        #    $sclass = $mc;
        #    $sclass =~ s/^+//g;
        #} else {
        $sclass .= $mc;
        #}
        if ( !grep( /^$sclass$/, @{ $self->_serialize_plugins } ) ) {
            return $self->_unsupported_media_type($c, $content_type);
        }
    } else {
        if ( exists( $controller->config->{'serialize'}->{'default'} ) ) {
            $sclass .= $controller->config->{'serialize'}->{'default'};
        } else {
            return $self->_unsupported_media_type($c, $content_type);
        }
    }
    unless ( exists( $self->_loaded_plugins->{$sclass} ) ) {
        my $load_class = $sclass;
        $load_class =~ s/::/\//g;
        $load_class =~ s/$/.pm/g;
        eval { require $load_class; };
        if ($@) {
            $c->log->error(
                "Error loading $sclass for " . $content_type . ": $!" )
              if $c->log->is_debug;
            return $self->_unsupported_media_type($c, $content_type);
        } else {
            $self->_loaded_plugins->{$sclass} = 1;
        }
    }

    if ($search_path eq "Catalyst::Action::Serialize") {
        if ($content_type) {
            $c->response->header( 'Vary' => 'Content-Type' );
        } elsif ($used_accept) {
            $c->response->header( 'Vary' => 'Accept' );
        }
        $c->response->content_type($content_type);
    }

    return $sclass, $sarg, $content_type;
}

sub _unsupported_media_type {
    my ( $self, $c, $content_type ) = @_;
    $c->res->content_type('text/plain');
    $c->res->status(415);
    if (defined($content_type)) {
        $c->res->body(
            "Content-Type " . $content_type . " is not supported.\r\n" );
    } else {
        $c->res->body(
            "Cannot find a Content-Type supported by your client.\r\n" );
    }
    return undef;
}

sub _serialize_bad_request {
    my ( $self, $c, $content_type, $error ) = @_;
    $c->res->content_type('text/plain');
    $c->res->status(400);
    $c->res->body(
        "Content-Type " . $content_type . " had a problem with your request.\r\n***ERROR***\r\n$error" );
    return undef;
}

1;

=head1 NAME

B<Catalyst::Action::SerializeBase>

Base class for Catalyst::Action::Serialize and Catlayst::Action::Deserialize.

=head1 DESCRIPTION

This module implements the plugin loading and content-type negotiating
code for L<Catalyst::Action::Serialize> and L<Catalyst::Action::Deserialize>.

=head1 SEE ALSO

L<Catalyst::Action::Serialize>, L<Catalyst::Action::Deserialize>,
L<Catalyst::Controller::REST>,

=head1 AUTHOR

Adam Jacob <adam@stalecoffee.org>, with lots of help from mst and jrockway.

Marchex, Inc. paid me while I developed this module.  (http://www.marchex.com)

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut

