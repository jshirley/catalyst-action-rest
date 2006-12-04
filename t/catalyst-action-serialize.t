package Test::Catalyst::Action::Serialize;

use FindBin;

use lib ("$FindBin::Bin/../lib");

use strict;
use warnings;

use Catalyst::Runtime '5.70';

use Catalyst;

__PACKAGE__->config(
    name => 'Test::Catalyst::Action::Serialize',
    serialize => {
        'default'   => 'YAML',
        'stash_key' => 'rest',
        'map'       => {
            'text/x-yaml'        => 'YAML',
            'text/x-data-dumper' => [ 'Data::Serializer', 'Data::Dumper' ],
            'text/broken'        => 'Broken',
        },
    }
);

__PACKAGE__->setup;

sub test :Local :ActionClass('Serialize') {
    my ( $self, $c ) = @_;
    $c->stash->{'rest'} = {
        lou => 'is my cat',
    };
}

sub test_second :Local :ActionClass('Serialize') {
    my ( $self, $c ) = @_;
    $c->stash->{'rest'} = {
        lou => 'is my cat',
    };
}

package main;

use strict;
use warnings;
use Test::More tests => 7;
use Data::Serializer;
use FindBin;
use Data::Dump qw(dump);

use lib ("$FindBin::Bin/lib", "$FindBin::Bin/../lib", "$FindBin::Bin/broken");
use Test::Rest;

# Should use Data::Dumper, via YAML 
my $t = Test::Rest->new('content_type' => 'text/x-data-dumper');

use_ok 'Catalyst::Test', 'Test::Catalyst::Action::Serialize';

my $res = request($t->get(url => '/test'));
ok( $res->is_success, 'GET the serialized request succeeded' );
is( $res->content, "{'lou' => 'is my cat'}", "Request returned proper data");

my $nt = Test::Rest->new('content_type' => 'text/broken');
my $bres = request($nt->get(url => '/test'));
is( $bres->code, 415, 'GET on un-useable Serialize class returns 415');

my $ut = Test::Rest->new('content_type' => 'text/not-happening');
my $ures = request($ut->get(url => '/test'));
is ($bres->code, 415, 'GET on unknown Content-Type returns 415');

# This check is to make sure we can still serialize after the first
# request.
my $res2 = request($t->get(url => '/test_second'));
ok( $res2->is_success, '2nd request succeeded' );
is( $res2->content, "{'lou' => 'is my cat'}", "2nd request returned proper data");


1;
