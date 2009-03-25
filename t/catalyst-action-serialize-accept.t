use strict;
use warnings;
use Test::More tests => 16;
use Data::Serializer;
use FindBin;
use Data::Dump qw(dump);

use lib ("$FindBin::Bin/lib", "$FindBin::Bin/../lib", "$FindBin::Bin/broken");
use Test::Rest;

# Should use Data::Dumper, via YAML 
my $t = Test::Rest->new('content_type' => 'text/x-yaml');

use_ok 'Catalyst::Test', 'Test::Catalyst::Action::REST';

my $data = <<EOH;
--- 
lou: is my cat
EOH

{
	my $req = $t->get(url => '/serialize/test');
	$req->remove_header('Content-Type');
	$req->header('Accept', 'text/x-yaml');
	my $res = request($req);
    SKIP: {
        skip "can't test text/x-yaml without YAML support",
        3 if ( 
                not $res->is_success and 
                $res->content =~ m#Content-Type text/x-yaml is not supported# 
             );
	    ok( $res->is_success, 'GET the serialized request succeeded' );
	    is( $res->content, $data, "Request returned proper data");
	    is( $res->header('Content-type'), 'text/x-yaml', '... with expected content-type')

    };
}

SKIP: {
    eval 'require JSON 2.12;';
    skip "can't test application/json without JSON support", 3 if $@;
    my $json = JSON->new;
    my $at = Test::Rest->new('content_type' => 'text/doesnt-exist');
	my $req = $at->get(url => '/serialize/test');
	$req->header('Accept', 'application/json');
	my $res = request($req);
    ok( $res->is_success, 'GET the serialized request succeeded' );
    my $ret = $json->decode($res->content);
    is( $ret->{lou}, 'is my cat', "Request returned proper data");
    is( $res->header('Content-type'), 'application/json', 'Accept header used if content-type mapping not found')
};

# Make sure we don't get a bogus content-type when using default
# serializer (rt.cpan.org ticket 27949)
{
	my $req = $t->get(url => '/serialize/test');
	$req->remove_header('Content-Type');
	$req->header('Accept', '*/*');
	my $res = request($req);
	ok( $res->is_success, 'GET the serialized request succeeded' );
	is( $res->content, $data, "Request returned proper data");
	is( $res->header('Content-type'), 'text/x-yaml', '... with expected content-type')
}

# Make that using content_type_stash_key, an invalid value in the stash gets ignored
{
	my $req = $t->get(url => '/serialize/test_second?serialize_content_type=nonesuch');
	$req->remove_header('Content-Type');
	$req->header('Accept', '*/*');
	my $res = request($req);
	ok( $res->is_success, 'GET the serialized request succeeded' );
	is( $res->content, $data, "Request returned proper data");
	is( $res->header('Content-type'), 'text/x-yaml', '... with expected content-type')
}

# Make that using content_type_stash_key, a valid value in the stash gets priority
# this also tests that application-level config is properly passed to
# individual controllers; see t/lib/Test/Catalyst/Action/REST.pm
{
	my $req = $t->get(url =>
	    '/serialize/test_second?serialize_content_type=text/x-data-dumper'
	);
	$req->remove_header('Content-Type');
	$req->header('Accept', '*/*');
	my $res = request($req);
	ok( $res->is_success, 'GET the serialized request succeeded' );
	is( $res->content, "{'lou' => 'is my cat'}", "Request returned proper data");
	is( $res->header('Content-type'), 'text/x-data-dumper', '... with expected content-type')
}

1;
