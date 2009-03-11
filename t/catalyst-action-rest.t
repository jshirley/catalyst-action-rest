package Test::Catalyst::Action::REST;

use FindBin;

use lib ("$FindBin::Bin/../lib");

use strict;
use warnings;

use Catalyst::Runtime '5.70';

use Catalyst;

__PACKAGE__->config( name => 'Test::Catalyst::Action::REST' );
__PACKAGE__->setup;

sub test : Local : ActionClass('REST') {
    my ( $self, $c ) = @_;
    $c->stash->{'entity'} = 'something';
}

sub test_GET : Local : ActionClass('REST') {
    my ( $self, $c ) = @_;

    $c->stash->{'entity'} .= " GET";
    $c->forward('ok');
}

sub test_POST : Local : ActionClass('REST') {
    my ( $self, $c ) = @_;

    $c->stash->{'entity'} .= " POST";
    $c->forward('ok');
}

sub test_PUT : Local : ActionClass('REST') {
    my ( $self, $c ) = @_;

    $c->stash->{'entity'} .= " PUT";
    $c->forward('ok');
}

sub test_DELETE : Local : ActionClass('REST') {
    my ( $self, $c ) = @_;

    $c->stash->{'entity'} .= " DELETE";
    $c->forward('ok');
}

sub test_OPTIONS : Local : ActionClass('REST') {
    my ( $self, $c ) = @_;

    $c->stash->{'entity'} .= " OPTIONS";
    $c->forward('ok');
}

sub notreally : Local : ActionClass('REST') {
}

sub notreally_GET {
    my ( $self, $c ) = @_;

    $c->stash->{'entity'} = "notreally GET";
    $c->forward('ok');
}

sub not_implemented : Local : ActionClass('REST') {
}

sub not_implemented_GET {
    my ( $self, $c ) = @_;

    $c->stash->{'entity'} = "not_implemented GET";
    $c->forward('ok');
}

sub not_implemented_not_implemented {
    my ( $self, $c ) = @_;

    $c->stash->{'entity'} = "Not Implemented Handler";
    $c->forward('ok');
}

sub not_modified : Local : ActionClass('REST') { }

sub not_modified_GET {
    my ( $self, $c ) = @_;
    $c->res->status(304);
    return 1;
}


sub ok : Private {
    my ( $self, $c ) = @_;

    $c->res->content_type('text/plain');
    $c->res->body( $c->stash->{'entity'} );
}

package main;

use strict;
use warnings;
use Test::More tests => 18;
use FindBin;
use Data::Dump qw(dump);

use lib ( "$FindBin::Bin/lib", "$FindBin::Bin/../lib" );
use Test::Rest;

# Should use the default serializer, YAML
my $t = Test::Rest->new( 'content_type' => 'text/plain' );

use_ok 'Catalyst::Test', 'Test::Catalyst::Action::REST';

foreach my $method (qw(GET DELETE POST PUT OPTIONS)) {
    my $run_method = lc($method);
    my $result     = "something $method";
    my $res;
    if ( grep /$method/, qw(GET DELETE OPTIONS) ) {
        $res = request( $t->$run_method( url => '/test' ) );
    } else {
        $res = request(
            $t->$run_method(
                url  => '/test',
                data => { foo => 'bar' }
            )
        );
    }
    ok( $res->is_success, "$method request succeeded" );
    is(
        $res->content,
        "something $method",
        "$method request had proper response"
    );
}

my $fail_res = request( $t->delete( url => '/notreally' ) );
is( $fail_res->code, 405, "Request to bad method gets 405 Not Implemented" );
is( $fail_res->header('allow'), "GET", "405 allow header properly set." );

my $options_res = request( $t->options( url => '/notreally' ) );
is( $options_res->code, 200, "OPTIONS request handler succeeded" );
is( $options_res->header('allow'),
    "GET", "OPTIONS request allow header properly set." );

my $modified_res = request( $t->get( url => '/not_modified' ) );
is( $modified_res->code, 304, "Not Modified request handler succeeded" );

my $ni_res = request( $t->delete( url => '/not_implemented' ) );
is( $ni_res->code, 200, "Custom not_implemented handler succeeded" );
is(
    $ni_res->content,
    "Not Implemented Handler",
    "not_implemented handler had proper response"
);

1;
