use strict;
use warnings;
use Test::More;
use FindBin;

use lib ("$FindBin::Bin/lib", "$FindBin::Bin/../lib");
use Test::Rest;

eval 'require JSON';
plan skip_all => 'Install JSON to run this test' if ($@);

plan tests => 9;

use_ok 'Catalyst::Test', 'Test::Serialize';

my $json = JSON->new;
# The text/x-json should throw a warning
for ('text/x-json', 'application/json') {
    my $t = Test::Rest->new('content_type' => $_);
    my $monkey_template = {
        monkey => 'likes chicken!',
    };
    my $mres = request($t->get(url => '/monkey_get'));
    ok( $mres->is_success, 'GET the monkey succeeded' );
    is_deeply($json->decode($mres->content), $monkey_template, "GET returned the right data");

    my $post_data = {
        'sushi' => 'is good for monkey',
    };
    my $mres_post = request($t->post(url => '/monkey_put', data => $json->encode($post_data)));
    ok( $mres_post->is_success, "POST to the monkey succeeded");
    is_deeply($mres_post->content, "is good for monkey", "POST data matches");
}

1;
