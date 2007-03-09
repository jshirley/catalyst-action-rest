package Catalyst::Action::Serialize::View;
use strict;
use warnings;

use base 'Catalyst::Action';

sub execute {
    my $self = shift;
    my ( $controller, $c, $view ) = @_;
    my $stash_key = $controller->config->{'serialize'}->{'stash_key'}
      || 'rest';

    if ( !$c->view($view) ) {
        $c->log->error("Could not load $view, refusing to serialize");
        return 0;
    }

    return $c->view($view)->process($c);
}

1;
