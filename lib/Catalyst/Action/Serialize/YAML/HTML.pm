#
# Catlyst::Action::Serialize::YAML::HTML.pm
# Created by: Adam Jacob, Marchex, <adam@hjksolutions.com>
# Created on: 10/12/2006 03:00:32 PM PDT
#
# $Id$

package Catalyst::Action::Serialize::YAML::HTML;

use strict;
use warnings;

use base 'Catalyst::Action';
use YAML::Syck;
use URI::Find;

sub execute {
    my $self = shift;
    my ( $controller, $c ) = @_;

    my $stash_key = (
            $controller->config->{'serialize'} ?
                $controller->config->{'serialize'}->{'stash_key'} :
                $controller->config->{'stash_key'} 
        ) || 'rest';
    my $app = $c->config->{'name'} || '';
    my $output = "<html>";
    $output .= "<title>" . $app . "</title>";
    $output .= "<body><pre>";
    my $text = Dump($c->stash->{$stash_key});
    # Straight from URI::Find
    my $finder = URI::Find->new(
                              sub {
                                  my($uri, $orig_uri) = @_;
                                  my $newuri;
                                  if ($uri =~ /\?/) {
                                      $newuri = $uri . "&content-type=text/html";
                                  } else {
                                      $newuri = $uri . "?content-type=text/html";
                                  }
                                  return qq|<a href="$newuri">$orig_uri</a>|;
                              });
    $finder->find(\$text);
    $output .= $text;
    $output .= "</pre>";
    $output .= "</body>";
    $output .= "</html>";
    $c->response->output( $output );
    return 1;
}

1;
