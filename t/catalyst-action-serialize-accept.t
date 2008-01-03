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
        'default'   => 'text/x-yaml',
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
my $t = Test::Rest->new('content_type' => 'text/x-yaml');

use_ok 'Catalyst::Test', 'Test::Catalyst::Action::Serialize';

my $data = <<EOH;
--- 
lou: is my cat
EOH

{
	my $req = $t->get(url => '/test');
	$req->remove_header('Content-Type');
	$req->header('Accept', 'text/x-yaml');
	my $res = request($req);
	ok( $res->is_success, 'GET the serialized request succeeded' );
	is( $res->content, $data, "Request returned proper data");
	is( $res->header('Content-type'), 'text/x-yaml', '... with expected content-type')
}

# Make sure we don't get a bogus content-type when using default
# serializer (rt.cpan.org ticket 27949)
{
	my $req = $t->get(url => '/test');
	$req->remove_header('Content-Type');
	$req->header('Accept', '*/*');
	my $res = request($req);
	ok( $res->is_success, 'GET the serialized request succeeded' );
	is( $res->content, $data, "Request returned proper data");
	is( $res->header('Content-type'), 'text/x-yaml', '... with expected content-type')
}

1;
