#
# REST.pm
# Created by: Adam Jacob, Marchex, <adam@hjksolutions.com>
# Created on: 10/13/2006 03:54:33 PM PDT
#
# $Id: $

package Catalyst::Request::REST;

use strict;
use warnings;

use base qw/Catalyst::Request Class::Accessor::Fast/;
use HTTP::Headers::Util qw(split_header_words);

sub _insert_self_into {
  my ($class, $app) = @_;
  my $req_class = $app->request_class;
  return if $req_class->isa($class);
  if ($req_class eq 'Catalyst::Request') {
    $app->request_class($class);
  } else {
    die "$app has a custom request class $req_class, "
      . "which is not a $class; see Catalyst::Request::REST";
  }
}

=head1 NAME

Catalyst::Request::REST - A REST-y subclass of Catalyst::Request

=head1 SYNOPSIS

     if ( $c->request->accepts('application/json') ) {
         ...
     }

     my $types = $c->request->accepted_content_types();

=head1 DESCRIPTION

This is a subclass of C<Catalyst::Request> that adds a few methods to
the request object to faciliate writing REST-y code. Currently, these
methods are all related to the content types accepted by the client.

Note that if you have a custom request class in your application, and it does
not inherit from C<Catalyst::Request::REST>, your application will fail with an
error indicating a conflict the first time it tries to use
C<Catalyst::Request::REST>'s functionality.  To fix this error, make sure your
custom request class inherits from C<Catalyst::Request::REST>.

=head1 METHODS

If the request went through the Deserializer action, this method will
returned the deserialized data structure.

=cut

__PACKAGE__->mk_accessors(qw(data accept_only));

=over 4 

=item accepted_content_types

Returns an array reference of content types accepted by the
client.

The list of types is created by looking at the following sources:

=over 8

=item * Content-type header

If this exists, this will always be the first type in the list.

=item * content-type parameter

If the request is a GET request and there is a "content-type"
parameter in the query string, this will come before any types in the
Accept header.

=item * Accept header

This will be parsed and the types found will be ordered by the
relative quality specified for each type.

=back

If a type appears in more than one of these places, it is ordered based on
where it is first found.

=cut

sub accepted_content_types {
    my $self = shift;

    return $self->{content_types} if $self->{content_types};

    my %types;

    # First, we use the content type in the HTTP Request.  It wins all.
    $types{ $self->content_type } = 3
        if $self->content_type;

    if ($self->method eq "GET" && $self->param('content-type')) {
        $types{ $self->param('content-type') } = 2;
    }

    # Third, we parse the Accept header, and see if the client
    # takes a format we understand.
    #
    # This is taken from chansen's Apache2::UploadProgress.
    if ( $self->header('Accept') ) {
        $self->accept_only(1) unless keys %types;

        my $accept_header = $self->header('Accept');
        my $counter       = 0;

        foreach my $pair ( split_header_words($accept_header) ) {
            my ( $type, $qvalue ) = @{$pair}[ 0, 3 ];
            next if $types{$type};

            unless ( defined $qvalue ) {
                $qvalue = 1 - ( ++$counter / 1000 );
            }

            $types{$type} = sprintf( '%.3f', $qvalue );
        }
    }

    return $self->{content_types} =
        [ sort { $types{$b} <=> $types{$a} } keys %types ];
}

=item preferred_content_type

This returns the first content type found. It is shorthand for:

  $request->accepted_content_types->[0]

=cut

sub preferred_content_type { $_[0]->accepted_content_types->[0] }

=item accepts($type)

Given a content type, this returns true if the type is accepted.

Note that this does not do any wildcard expansion of types.

=cut

sub accepts {
    my $self = shift;
    my $type = shift;

    return grep { $_ eq $type } @{ $self->accepted_content_types };
}

=back

=head1 AUTHOR

Adam Jacob <adam@stalecoffee.org>, with lots of help from mst and jrockway

=head1 MAINTAINER

J. Shirley <jshirley@cpan.org>

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut

1;
