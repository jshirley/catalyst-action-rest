package Test::Catalyst::Action::REST::Controller::Deserialize;

use base 'Catalyst::Controller';

__PACKAGE__->config(
    'stash_key' => 'rest',
    'map'       => {
        'text/x-yaml'        => 'YAML',
        'text/x-data-dumper' => [ 'Data::Serializer', 'Data::Dumper' ],
        'text/broken'        => 'Broken',
    },
);


sub test :Local :ActionClass('Deserialize') {
    my ( $self, $c ) = @_;
    $c->res->output($c->req->data->{'kitty'});
}

1;
