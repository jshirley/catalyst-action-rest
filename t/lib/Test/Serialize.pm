
package Test::Serialize;

use FindBin;

use lib ("$FindBin::Bin/../lib");

use strict;
use warnings;

use Catalyst::Runtime '5.70';

use Catalyst;

__PACKAGE__->config(
    name => 'Test::Serialize',
);

__PACKAGE__->setup;

__PACKAGE__->setup_component("Test::Serialize::Controller::REST");
__PACKAGE__->setup_component("Test::Serialize::View::Simple");

1;

