#!/usr/bin/perl
use 5.012;
use warnings;

use Data::Dumper;
use lib './lib';
use graphitem;
use node;
use graphinstance;
use nodeinstance;
#use Moose;



package leaf;
use Moose;
extends 'graphitem';

has instanceclass => (is => 'ro', default => "leafinstance");
has content => (is => 'rw') ;


package leafinstance;
use Moose;
extends 'leaf';
with 'graphinstance';

package root;
use Moose;
extends 'node';

has root => (is => 'ro', default => sub {return shift}); 
sub parent {shift};
sub name   {''};
sub instantify {die};

package main;


my $root = root->new;

($\,$,) = ("\n", "\t");


my $node1 = $root->createsub('node1', 'node');
my $node2 = $root->createsub('node2', 'node');

$node1->createsub('leaf1', 'leaf');
$node1->createsub('leaf2', 'leaf');
$node1->createsub('node3', 'node')->createsub('subnode1','node');


say $root->treedump;
__END__
 
print 'name',   $root->name;
print 'parent', $root->parent;
print 'root',   $root->root;

say $root->treedump;

__END__

my $node1 = node->new(data => {node => "node1", foodata => 'foo'} );
my $node2 = node->new(data => {node => "node2", bardata => 'bar'} );
my $node3 = node->new(data => {node => "node3"} );
my $node4 = node->new(data => {node => "node4"} );
my $node5 = node->new(data => {node => "node5", bardata => 'other'} );

$,= "\t";

$node1->add('subnode1', $node2 );
$node1->add('subnode2', $node3 );
$node2->add('subsubnode1', $node4 );
$node4->add('3subnode1', $node5 );

my $leaf1 = leaf->new;

$node1->add('leaf1', $leaf1);
say Dumper($node1);

say $node1->treedump;

#say $node1->checkpath([qw/subnode1 subsubnode1 nothere/]);
#say $node1->checkpath([qw/subnode1 subsubnode1 /]);
#say $node1->check('subnode2');
#say $node1->check('subsubnode2');
