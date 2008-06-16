use strict;
use warnings;
use Test::More tests => 24;
use FindBin;
use lib ( "$FindBin::Bin/../lib" );

use Catalyst::Request::REST;
use HTTP::Headers;

{
    my $request = Catalyst::Request::REST->new;
    $request->{_context} = 'MockContext';
    $request->headers( HTTP::Headers->new );
    $request->parameters( {} );
    $request->method('GET');
    $request->content_type('text/foobar');

    is_deeply( $request->accepted_content_types, [ 'text/foobar' ],
               'content-type set in request headers is found' );
    is( $request->preferred_content_type, 'text/foobar',
        'preferred content type is text/foobar' );
    ok( ! $request->accept_only, 'accept_only is false' );
    ok( $request->accepts('text/foobar'), 'accepts text/foobar' );
    ok( ! $request->accepts('text/html'), 'does not accept text/html' );
}

{
    my $request = Catalyst::Request::REST->new;
    $request->{_context} = 'MockContext';
    $request->headers( HTTP::Headers->new );
    $request->parameters( { 'content-type' => 'text/fudge' } );
    $request->method('GET');
    $request->content_type('text/foobar');

    is_deeply( $request->accepted_content_types, [ 'text/foobar', 'text/fudge' ],
               'content-type set in request headers and type in parameters is found' );
    is( $request->preferred_content_type, 'text/foobar',
        'preferred content type is text/foobar' );
    ok( ! $request->accept_only, 'accept_only is false' );
    ok( $request->accepts('text/foobar'), 'accepts text/foobar' );
    ok( $request->accepts('text/fudge'), 'accepts text/fudge' );
    ok( ! $request->accepts('text/html'), 'does not accept text/html' );
}

{
    my $request = Catalyst::Request::REST->new;
    $request->{_context} = 'MockContext';
    $request->headers( HTTP::Headers->new );
    $request->parameters( { 'content-type' => 'text/fudge' } );
    $request->method('POST');
    $request->content_type('text/foobar');

    ok( ! $request->accepts('text/fudge'), 'content type in parameters is ignored for POST' );
}

{
    my $request = Catalyst::Request::REST->new;
    $request->{_context} = 'MockContext';
    $request->headers( HTTP::Headers->new );
    $request->parameters( {} );
    $request->method('GET');
    $request->headers->header(
        'Accept' =>
        # From Firefox 2.0 when it requests an html page
        'text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5',
    );

    is_deeply( $request->accepted_content_types,
               [ qw( text/xml application/xml application/xhtml+xml
                     image/png
                     text/html
                     text/plain
                     */*
                   ) ],
               'accept header is parsed properly' );
    is( $request->preferred_content_type, 'text/xml',
        'preferred content type is text/xml' );
    ok( $request->accept_only, 'accept_only is true' );
    ok( $request->accepts('text/html'), 'accepts text/html' );
    ok( $request->accepts('image/png'), 'accepts image/png' );
    ok( ! $request->accepts('image/svg'), 'does not accept image/svg' );
}

{
    my $request = Catalyst::Request::REST->new;
    $request->{_context} = 'MockContext';
    $request->headers( HTTP::Headers->new );
    $request->parameters( {} );
    $request->method('GET');
    $request->content_type('text/x-json');
    $request->headers->header(
        'Accept' =>
        # From Firefox 2.0 when it requests an html page
        'text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5',
    );

    is_deeply( $request->accepted_content_types,
               [ qw( text/x-json
                     text/xml application/xml application/xhtml+xml
                     image/png
                     text/html
                     text/plain
                     */*
                   ) ],
               'accept header is parsed properly, and content-type header has precedence over accept' );
    ok( ! $request->accept_only, 'accept_only is false' );
}

{
    my $request = Catalyst::Request::REST->new;
    $request->{_context} = 'MockContext';
    $request->headers( HTTP::Headers->new );
    $request->parameters( {} );
    $request->method('GET');
    $request->content_type('application/json');
    $request->headers->header(
        'Accept' =>
        # From Firefox 2.0 when it requests an html page
        'text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5',
    );

    is_deeply( $request->accepted_content_types,
               [ qw( application/json
                     text/xml application/xml application/xhtml+xml
                     image/png
                     text/html
                     text/plain
                     */*
                   ) ],
               'accept header is parsed properly, and content-type header has precedence over accept' );
    ok( ! $request->accept_only, 'accept_only is false' );
}

{
    my $request = Catalyst::Request::REST->new;
    $request->{_context} = 'MockContext';
    $request->headers( HTTP::Headers->new );
    $request->parameters( {} );
    $request->method('GET');
    $request->content_type('text/x-json');
    $request->headers->header(
        'Accept' => 'text/plain,text/x-json',
    );

    is_deeply( $request->accepted_content_types,
               [ qw( text/x-json
                     text/plain
                   ) ],
               'each type appears only once' );
}

{
    my $request = Catalyst::Request::REST->new;
    $request->{_context} = 'MockContext';
    $request->headers( HTTP::Headers->new );
    $request->parameters( {} );
    $request->method('GET');
    $request->content_type('application/json');
    $request->headers->header(
        'Accept' => 'text/plain,application/json',
    );

    is_deeply( $request->accepted_content_types,
               [ qw( application/json
                     text/plain
                   ) ],
               'each type appears only once' );
}

package MockContext;

sub prepare_body { }
