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
    if (exists($p{'entity'})) {
        $c->stash->{$self->config->{'serialize'}->{'stash_key'}} = $p{'entity'};
    }
    return 1;
}

1;
