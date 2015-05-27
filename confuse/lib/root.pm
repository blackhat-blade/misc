package root;
use Moose;
use node;
extends 'node';

has root => (is => 'ro', default => sub {return shift}); 
sub parent {shift};
sub name   {''};
sub instantify {die};

1;
