package Test::Catalyst::Action::Deserialize;

use FindBin;

use lib ("$FindBin::Bin/../lib");

use strict;
use warnings;

use Catalyst::Runtime '5.70';

use Catalyst;

__PACKAGE__->config(
    name => 'Test::Catalyst::Action::Deserialize',
    serialize => {
        'stash_key' => 'rest',
        'map'       => {
            'text/x-yaml'        => 'YAML',
            'text/x-data-dumper' => [ 'Data::Serializer', 'Data::Dumper' ],
            'text/broken'        => 'Broken',
        },
    }
);

__PACKAGE__->setup;

sub test :Local :ActionClass('Deserialize') {
    my ( $self, $c ) = @_;
    $c->res->output($c->req->data->{'kitty'});
}

package main;

use strict;
use warnings;
use Test::More tests => 5;
use YAML::Syck;
use FindBin;
use Data::Dump qw(dump);

use lib ("$FindBin::Bin/lib", "$FindBin::Bin/../lib", "$FindBin::Bin/broken");
use Test::Rest;

# Should use Data::Dumper, via Data::Serializer 
my $t = Test::Rest->new('content_type' => 'text/x-yaml');

use_ok 'Catalyst::Test', 'Test::Catalyst::Action::Deserialize';

my $res = request($t->put( url => '/test', data => Dump({ kitty => "LouLou" })));
ok( $res->is_success, 'PUT Deserialize request succeeded' );
is( $res->content, "LouLou", "Request returned deserialized data");

my $nt = Test::Rest->new('content_type' => 'text/broken');
my $bres = request($nt->put( url => '/test', data => Dump({ kitty => "LouLou" })));
is( $bres->code, 415, 'PUT on un-useable Deserialize class returns 415');

my $ut = Test::Rest->new('content_type' => 'text/not-happening');
my $ures = request($ut->put( url => '/test', data => Dump({ kitty => "LouLou" })));
is ($bres->code, 415, 'GET on unknown Content-Type returns 415');

1;
