package Catalyst::Controller::REST;

use strict;
use warnings;
use base 'Catalyst::Controller';

__PACKAGE__->mk_accessors(qw(serialize));

__PACKAGE__->config(
    serialize => {
        'stash_key' => 'rest',
    }
);

sub begin :ActionClass('Deserialize::YAML') {}

sub end :ActionClass('Serialize::YAML') {}

1;
