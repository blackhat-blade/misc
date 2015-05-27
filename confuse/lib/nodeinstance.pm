package nodeinstance;
use Moose;
use node;
use graphinstance;

extends 'node';
with 'graphinstance';
1;
