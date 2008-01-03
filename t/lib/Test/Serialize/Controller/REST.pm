package Test::Serialize::Controller::REST;

use warnings;
use strict;

use base qw/Catalyst::Controller::REST/;

__PACKAGE__->config(
    'namespace' => '',
    'stash_key' => 'rest',
    'map'       => {
        'text/html'          => 'YAML::HTML',
        'text/xml'           => 'XML::Simple',
        'text/x-yaml'        => 'YAML',
        'text/x-json'        => 'JSON',
        'text/x-data-dumper' => [ 'Data::Serializer', 'Data::Dumper' ],
        'text/x-data-denter' => [ 'Data::Serializer', 'Data::Denter' ],
        'text/x-data-taxi'   => [ 'Data::Serializer', 'Data::Taxi' ],
        'application/x-storable' => [ 'Data::Serializer', 'Storable' ],
        'application/x-freezethaw' =>
            [ 'Data::Serializer', 'FreezeThaw' ],
        'text/x-config-general' =>
            [ 'Data::Serializer', 'Config::General' ],
        'text/x-php-serialization' =>
             [ 'Data::Serializer', 'PHP::Serialization' ],
        'text/view'   => [ 'View', 'Simple' ],
        'text/broken' => 'Broken',
    },
);

sub monkey_put : Local : ActionClass('Deserialize') {
    my ( $self, $c ) = @_;
	if ( ref($c->req->data) eq "HASH" ) {
		$c->res->output( $c->req->data->{'sushi'} );
	} else {
		$c->res->output(1);
	}
}

sub monkey_get : Local : ActionClass('Serialize') {
    my ( $self, $c ) = @_;
    $c->stash->{'rest'} = { monkey => 'likes chicken!', };
}

1;

