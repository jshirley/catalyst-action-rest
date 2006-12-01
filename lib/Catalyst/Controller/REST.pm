package Catalyst::Controller::REST;

=head1 NAME

Catalyst::Controller::REST - A RESTful controller 

=head1 SYNOPSIS

    package Foo::Controller::Bar;

    use base 'Catalyst::Controller::REST';

    sub thing : Local : ActionClass('REST') { }

    # Answer GET requests to "thing"
    sub thing_GET {
       my ( $self, $c ) = @_;
     
       # Return a 200 OK, with the data in entity
       # serialized in the body 
       $self->status_ok(
            $c, 
            entity => {
                some => 'data',
                foo  => 'is real bar-y',
            },
       );
    }

    # Answer PUT requests to "thing"
    sub thing_PUT { 
      .. some action ..
    }

=head1 DESCRIPTION

Catalyst::Controller::REST implements a mechanism for building
RESTful services in Catalyst.  It does this by extending the
normal Catalyst dispatch mechanism to allow for different 
subroutines to be called based on the HTTP Method requested, 
while also transparently handling all the serialization/deserialization for
you.

This is probably best served by an example.  In the above
controller, we have declared a Local Catalyst action on
"sub thing", and have used the ActionClass('REST').  

Below, we have declared "thing_GET" and "thing_PUT".  Any
GET requests to thing will be dispatched to "thing_GET", 
while any PUT requests will be dispatched to "thing_PUT".  

Any unimplemented HTTP METHODS will be met with a "405 Method Not Allowed"
response, automatically containing the proper list of available methods. 

The HTTP POST, PUT, and OPTIONS methods will all automatically deserialize the
contents of $c->request->body based on the requests content-type header.
A list of understood serialization formats is below.

Also included in this class are several helper methods, which
will automatically handle setting up proper response objects 
for you.

To make your Controller RESTful, simply have it

  use base 'Catalyst::Controller::REST'; 

=head1 SERIALIZATION

Catalyst::Controller::REST will automatically serialize your
responses.  The currently implemented serialization formats are:

   text/x-yaml        ->   YAML::Syck
   text/x-data-dumper ->   Data::Serializer

By default, L<Catalyst::Controller::REST> will use YAML as
the serialization format.

Implementing new Serialization formats is easy!  Contributions
are most welcome!  See L<Catalyst::Action::Serialize> and
L<Catalyst::Action::Deserialize> for more information.

=head1 STATUS HELPERS

These helpers try and conform to the HTTP 1.1 Specification.  You can
refer to it at: http://www.w3.org/Protocols/rfc2616/rfc2616.txt.  
These routines are all implemented as regular subroutines, and as
such require you pass the current context ($c) as the first argument.

=over 4

=cut

use strict;
use warnings;
use base 'Catalyst::Controller';
use Params::Validate qw(:all);

__PACKAGE__->mk_accessors(qw(serialize));

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

sub end : ActionClass('Serialize') { }

=item status_ok

Returns a "200 OK" response.  Takes an "entity" to serialize.

Example:

  $self->status_ok(
    $c, 
    entity => {
        radiohead => "Is a good band!",
    }
  );

=cut

sub status_ok {
    my $self = shift;
    my $c = shift;
    my %p = validate(@_,
        {
            entity => 1, 
        },
    );

    $c->response->status(200);
    $self->_set_entity($c, $p{'entity'});
    return 1;
}

=item status_created

Returns a "201 CREATED" response.  Takes an "entity" to serialize,
and a "location" where the created object can be found.

Example:

  $self->status_created(
    $c, 
    location => $c->req->uri->as_string,
    entity => {
        radiohead => "Is a good band!",
    }
  );

In the above example, we use the requested URI as our location.
This is probably what you want for most PUT requests.

=cut

sub status_created {
    my $self = shift;
    my $c = shift;
    my %p = validate(@_,
        {
            location => { type => SCALAR | OBJECT },
            entity => { optional => 1 }, 
        },
    );

    my $location;
    if (ref($p{'location'})) {
        $location = $p{'location'}->as_string;
    } else {
        $location = $p{'location'};
    }
    $c->response->status(201);
    $c->response->header('Location' => $location);
    $self->_set_entity($c, $p{'entity'});
    return 1;
}

=item status_accepted

Returns a "202 ACCEPTED" response.  Takes an "entity" to serialize.

Example:

  $self->status_accepted(
    $c, 
    entity => {
        status => "queued",
    }
  );

=cut
sub status_accepted {
    my $self = shift;
    my $c = shift;
    my %p = validate(@_,
        {
            entity => 1, 
        },
    );

    $c->response->status(202);
    $self->_set_entity($c, $p{'entity'});
    return 1;
}

=item status_bad_request

Returns a "400 BAD REQUEST" response.  Takes a "message" argument
as a scalar, which will become the value of "error" in the serialized
response.

Example:

  $self->status_bad_request(
    $c, 
    message => "Cannot do what you have asked!",
  );

=cut
sub status_bad_request {
    my $self = shift;
    my $c = shift;
    my %p = validate(@_,
        {
            message => { type => SCALAR }, 
        },
    );

    $c->response->status(400);
    $c->log->debug("Status Bad Request: " . $p{'message'});
    $self->_set_entity($c, { error => $p{'message'} });
    return 1;
}

=item status_not_found

Returns a "404 NOT FOUND" response.  Takes a "message" argument
as a scalar, which will become the value of "error" in the serialized
response.

Example:

  $self->status_not_found(
    $c, 
    message => "Cannot find what you were looking for!",
  );

=cut
sub status_not_found {
    my $self = shift;
    my $c = shift;
    my %p = validate(@_,
        {
            message => { type => SCALAR }, 
        },
    );

    $c->response->status(404);
    $c->log->debug("Status Not Found: " . $p{'message'});
    $self->_set_entity($c, { error => $p{'message'} });
    return 1;
}

sub _set_entity {
    my $self = shift;
    my $c = shift;
    my $entity = shift;
    if (defined($entity)) {
        $c->stash->{$self->config->{'serialize'}->{'stash_key'}} = $entity;
    }
    return 1;
}

=back

=head1 MANUAL RESPONSES

If you want to construct your responses yourself, all you need to
do is put the object you want serialized in $c->stash->{'rest'}.

=head1 SEE ALSO

L<Catalyst::Action::REST>, L<Catalyst::Action::Serialize>,
L<Catalyst::Action::Deserialize>

For help with REST in general:

The HTTP 1.1 Spec is required reading. http://www.w3.org/Protocols/rfc2616/rfc2616.txt

Wikipedia! http://en.wikipedia.org/wiki/Representational_State_Transfer

The REST Wiki: http://rest.blueoxen.net/cgi-bin/wiki.pl?FrontPage

=head1 AUTHOR

Adam Jacob <adam@stalecoffee.org>, with lots of help from mst and jrockway

Marchex, Inc. paid me while I developed this module.  (http://www.marchex.com)

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut

1;
