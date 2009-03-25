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

use_ok 'Catalyst::Test', 'Test::Catalyst::Action::REST';
my $url = '/deserialize/test';

my $res = request($t->put( url => $url, data => Dump({ kitty => "LouLou" })));
ok( $res->is_success, 'PUT Deserialize request succeeded' );
is( $res->content, "LouLou", "Request returned deserialized data");

my $nt = Test::Rest->new('content_type' => 'text/broken');
my $bres = request($nt->put( url => $url, data => Dump({ kitty => "LouLou" })));
is( $bres->code, 415, 'PUT on un-useable Deserialize class returns 415');

my $ut = Test::Rest->new('content_type' => 'text/not-happening');
my $ures = request($ut->put( url => $url, data => Dump({ kitty => "LouLou" })));
is ($bres->code, 415, 'GET on unknown Content-Type returns 415');

1;
