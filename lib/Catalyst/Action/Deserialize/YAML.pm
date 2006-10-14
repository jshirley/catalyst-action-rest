#
# Catlyst::Action::Deserialize::YAML.pm
# Created by: Adam Jacob, Marchex, <adam@marchex.com>
# Created on: 10/12/2006 03:00:32 PM PDT
#
# $Id$

package Catalyst::Action::Deserialize::YAML;

use strict;
use warnings;

use base 'Catalyst::Action';
use YAML::Syck;
use Catalyst::Request::REST;

sub execute {
    my $self = shift;
    my ( $controller, $c, $test ) = @_;
   
    my $nreq = bless($c->request, 'Catalyst::Request::REST');
    $c->request($nreq);
    if ($c->request->method eq "POST" || $c->request->method eq "PUT") {
        my $rdata = LoadFile($c->request->body);
        $c->request->data($rdata);
        $self->NEXT::execute( @_, );
    } else {
        $self->NEXT::execute( @_ );
    }
};

1;
