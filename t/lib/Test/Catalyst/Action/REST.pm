package Test::Catalyst::Action::REST;

use strict;
use warnings;

use Catalyst::Runtime '5.70';

use Catalyst;

__PACKAGE__->config(
    name => 'Test::Catalyst::Action::REST',
);
__PACKAGE__->setup;

1;
