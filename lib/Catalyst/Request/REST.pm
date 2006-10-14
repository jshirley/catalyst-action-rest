#
# REST.pm
# Created by: Adam Jacob, Marchex, <adam@marchex.com>
# Created on: 10/13/2006 03:54:33 PM PDT
#
# $Id: $

package Catalyst::Request::REST;

use strict;
use warnings;

use base 'Catalyst::Request';

__PACKAGE__->mk_accessors(qw(data));

1;

