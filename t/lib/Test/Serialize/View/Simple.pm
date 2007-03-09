package Test::Serialize::View::Simple;

use base qw/Catalyst::View/;

sub process {
	my ($self, $c) = @_;
	
    $c->res->body("I am a simple view");
	return 1;
}

1;
