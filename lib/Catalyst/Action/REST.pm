#
# REST.pm
# Created by: Adam Jacob, Marchex, <adam@hjksolutions.com>
# Created on: 10/12/2006 03:00:32 PM PDT
#
# $Id$

package Catalyst::Action::REST;

use strict;
use warnings;

use base 'Catalyst::Action';
use Class::Inspector;
use Catalyst;
use Catalyst::Request::REST;
use 5.8.1;

our
   $VERSION = '0.60';

# This is wrong in several ways. First, there's no guarantee that
# Catalyst.pm has not been subclassed. Two, there's no guarantee that
# the user isn't already using their request subclass.
Catalyst->request_class('Catalyst::Request::REST')
  unless Catalyst->request_class->isa('Catalyst::Request::REST');

=head1 NAME

Catalyst::Action::REST - Automated REST Method Dispatching

=head1 SYNOPSIS

    sub foo :Local :ActionClass('REST') {
      ... do setup for HTTP method specific handlers ...
    }

    sub foo_GET { 
      ... do something for GET requests ...
    }

    sub foo_PUT { 
      ... do somethign for PUT requests ...
    }

=head1 DESCRIPTION

This Action handles doing automatic method dispatching for REST requests.  It
takes a normal Catalyst action, and changes the dispatch to append an
underscore and method name. 

For example, in the synopsis above, calling GET on "/foo" would result in
the foo_GET method being dispatched.

If a method is requested that is not implemented, this action will 
return a status 405 (Method Not Found).  It will populate the "Allow" header 
with the list of implemented request methods.  You can override this behavior
by implementing a custom 405 handler like so:

   sub foo_not_implemented {
      ... handle not implemented methods ...
   }

If you do not provide an _OPTIONS subroutine, we will automatically respond
with a 200 OK.  The "Allow" header will be populated with the list of
implemented request methods.

It is likely that you really want to look at L<Catalyst::Controller::REST>,
which brings this class together with automatic Serialization of requests
and responses.

When you use this module, the request class will be changed to
L<Catalyst::Request::REST>.

=head1 METHODS

=over 4

=item dispatch

This method overrides the default dispatch mechanism to the re-dispatching
mechanism described above.

=cut

sub dispatch {
    my $self = shift;
    my $c    = shift;

    my $controller = $c->component( $self->class );
    my $method     = $self->name . "_" . uc( $c->request->method );
    if ( $controller->can($method) ) {
        $c->execute( $self->class, $self, @{ $c->req->args } );
        return $controller->$method( $c, @{ $c->req->args } );
    } else {
        if ( $c->request->method eq "OPTIONS" ) {
            return $self->_return_options($c);
        } else {
            my $handle_ni = $self->name . "_not_implemented";
            if ( $controller->can($handle_ni) ) {
                return $controller->$handle_ni( $c, @{ $c->req->args } );
            } else {
                return $self->_return_not_implemented($c);
            }
        }
    }
}

sub _return_options {
    my ( $self, $c ) = @_;

    my @allowed = $self->_get_allowed_methods($c);
    $c->response->content_type('text/plain');
    $c->response->status(200);
    $c->response->header( 'Allow' => \@allowed );
}

sub _get_allowed_methods {
    my ( $self, $c ) = @_;

    my $controller = $self->class;
    my $methods    = Class::Inspector->methods($controller);
    my @allowed;
    foreach my $method ( @{$methods} ) {
        my $name = $self->name;
        if ( $method =~ /^$name\_(.+)$/ ) {
            push( @allowed, $1 );
        }
    }
    return @allowed;
}

sub _return_not_implemented {
    my ( $self, $c ) = @_;

    my @allowed = $self->_get_allowed_methods($c);
    $c->response->content_type('text/plain');
    $c->response->status(405);
    $c->response->header( 'Allow' => \@allowed );
    $c->response->body( "Method "
          . $c->request->method
          . " not implemented for "
          . $c->uri_for( $self->reverse ) );
}

1;

=back

=head1 SEE ALSO

You likely want to look at L<Catalyst::Controller::REST>, which implements
a sensible set of defaults for a controller doing REST.

L<Catalyst::Action::Serialize>, L<Catalyst::Action::Deserialize>

=head1 AUTHOR

Adam Jacob <adam@stalecoffee.org>, with lots of help from mst and jrockway

Marchex, Inc. paid me while I developed this module.  (http://www.marchex.com)

=head1 CONTRIBUTERS

Daisuke Maki <daisuke@endeworks.jp>

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut

