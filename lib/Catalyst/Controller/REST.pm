package Catalyst::Controller::REST;

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

# You probably want to refer to the HTTP 1.1 Spec for these; they should
# conform as much as possible.
#
# ftp://ftp.isi.edu/in-notes/rfc2616.txt

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
    }
    $c->response->status(201);
    $c->response->header('Location' => $location);
    $self->_set_entity($c, $p{'entity'});
    return 1;
}

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

sub status_not_found {
    my $self = shift;
    my $c = shift;
    my %p = validate(@_,
        {
            message => { type => SCALAR }, 
        },
    );

    $c->response->status(404);
    $c->response->body($p{'message'});
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

1;
