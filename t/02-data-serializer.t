use strict;
use warnings;
use Test::More qw(no_plan);
use Data::Serializer;
use FindBin;

use lib ("$FindBin::Bin/lib", "$FindBin::Bin/../lib");
use Test::Rest;

my $dso = Data::Serializer->new(serializer => 'Data::Dumper');

# Should use Data::Dumper, via Data::Serializer 
my $t = Test::Rest->new('content_type' => 'text/x-data-dumper');

BEGIN { use_ok 'Catalyst::Test', 'SampleREST' }

my $mres = request($t->get(url => '/monkey'));
# We should find the monkey
ok( $mres->is_success, 'GET the monkey succeeded' );

my $monkey_template = {
    monkey => 'likes chicken!',
};
my $monkey_data = $dso->raw_deserialize($mres->content); 
is_deeply($monkey_data, $monkey_template, "GET returned the right data");

my $post_data = {
    'sushi' => 'is good for monkey',
};
my $mres_post = request($t->post(url => '/monkey', data => $dso->raw_serialize($post_data)));
ok( $mres_post->is_success, "POST to the monkey succeeded");
is_deeply($mres_post->content, $dso->raw_serialize($post_data), "POST data matches");

1;
