use strict;
use warnings;
use Test::More qw(no_plan);
use YAML::Syck;
use FindBin;

use lib ("$FindBin::Bin/lib", "$FindBin::Bin/../lib");
use Test::Rest;

# Should use the default serializer, YAML
my $t = Test::Rest->new('content_type' => 'text/plain');

BEGIN { use_ok 'Catalyst::Test', 'SampleREST' }

my $mres = request($t->get(url => '/monkey'));
# We should find the monkey
ok( $mres->is_success, 'GET the monkey succeeded' );

# We should use the default serializer, YAML
my $monkey_template = {
    monkey => 'likes chicken!',
};
my $monkey_data = Load($mres->content); 
is_deeply($monkey_data, $monkey_template, "GET returned the right data");

$t->{'content_type'} = 'text/x-yaml'; # Try again, with x-yaml
my $mres_yaml = request($t->get(url => '/monkey'));
ok( $mres_yaml->is_success, 'GET the monkey x-yaml succeeded' );
is_deeply(Load($mres_yaml->content), $monkey_template, "GET x-yaml returned the right data");

$t->{'content_type'} = 'text/plain'; # Try again, with text/plain 
my $post_data = {
    'sushi' => 'is good for monkey',
};
my $mres_post = request($t->post(url => '/monkey', data => Dump($post_data)));
ok( $mres_post->is_success, "POST to the monkey succeeded");
is_deeply($mres_post->content, Dump($post_data), "POST data matches");

my $mdel = request($t->delete(url => '/monkey'));
ok(! $mdel->is_success, "DELETE-ing the monkey failed; long live monkey!");
ok($mdel->code eq "405", "DELETE-ing the monkey returned 405");
my @allowed = $mdel->header('allow');
my @rallowed = qw(GET POST);
ok(@allowed eq @rallowed, "Default 405 handler returned proper methods in Allow header");

1;
