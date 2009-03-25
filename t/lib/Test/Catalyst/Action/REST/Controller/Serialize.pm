package Test::Catalyst::Action::REST::Controller::Serialize;

use strict;
use warnings;
use base 'Catalyst::Controller';

__PACKAGE__->config(
    'default'   => 'text/x-yaml',
    'stash_key' => 'rest',
    'map'       => {
        'text/x-yaml'        => 'YAML',
        'application/json'   => 'JSON',
        'text/x-data-dumper' => [ 'Data::Serializer', 'Data::Dumper' ],
        'text/broken'        => 'Broken',
    },
);

sub test :Local :ActionClass('Serialize') {
    my ( $self, $c ) = @_;
    $c->stash->{'rest'} = {
        lou => 'is my cat',
    };
}

sub test_second :Local :ActionClass('Serialize') {
    my ( $self, $c ) = @_;
    # 'serialize_content_type' is configured in the test config in t/conf
    $c->stash->{'serialize_content_type'} = $c->req->params->{'serialize_content_type'};
    $c->stash->{'rest'} = {
        lou => 'is my cat',
    };
}

1;
