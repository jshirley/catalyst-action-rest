package Catalyst::Controller::REST;

use strict;
use warnings;
use base 'Catalyst::Controller';

__PACKAGE__->mk_accessors(qw(serialize));

__PACKAGE__->config(
    serialize => {
        'default' => 'YAML',
        'stash_key' => 'rest',
        'map' => {
            'text/x-yaml' => 'YAML',
            'text/x-data-dumper' => [ 'Data::Serializer', 'Data::Dumper' ],
        },
    }
);

sub begin :ActionClass('Deserialize') {}

sub end :ActionClass('Serialize') {}

1;
