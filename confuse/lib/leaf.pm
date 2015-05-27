package leaf;
use Moose;
use graphitem;

extends 'graphitem';

has instanceclass => (is => 'ro', default => "leafinstance");
has content => (is => 'rw') ;
1;
