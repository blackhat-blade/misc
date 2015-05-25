#!/usr/bin/perl
use 5.012;
use warnings;

use Data::Dumper;

use Moose;

package graphitem;
use Moose;
has item => (is => 'ro');
has data => (is => 'ro', isa => "HashRef", default => sub { return {} });

package node;
use Moose;
extends 'graphitem';
has childs => (is => 'ro', isa => "HashRef", default => sub {return {} });

sub list{ return keys %{shift->childs} }

sub add 
{
	my ($self, $name, $o) = @_; 
	die "DUP" if $self->childs->{$name};

	$self->childs->{$name} =  $o->instancify($self,  $name);   
}

sub del
{
	my ($self, $name) = @_;
	delete $self->childs->{$name};
}

sub getall
{
	my $self = shift;

	return values %{$self->childs};
}

sub getsubtree
{
	my $self = shift;
	my @own  = $self->getall;

	return (@own, map {$_->getsubtree} @own);
}

sub instancify
{
	my ($self, $parent, $name) = @_;
	nodeinstance->new( node => $self, parent => $parent, name => $name );
}


package nodeinstance;
use Moose;
has node   => (is => 'ro', isa => 'node', required => 1, handles => [qw/list del add getall getsubtree/]);
has name   => (is => 'ro', isa => 'Str');
has parent => (is => 'ro', isa => 'Object');

sub env
{
	my ($self, $key) = @_;

	return $self->node->data->{$key} if exists $self->node->data->{$key};
	return undef unless $self->parent;
	return $self->parent->env($key)  if $self->parent->can('env');
	return $self->parent->data->{$key} if exists $self->node->data->{$key};
	 
}


package main;

#print Dumper (graphitem->new);
my $node1 = node->new(data => {node => "node1", foodata => 'foo'} );
my $node2 = node->new(data => {node => "node2", bardata => 'bar'} );
my $node3 = node->new(data => {node => "node3"} );
my $node4 = node->new(data => {node => "node4"} );
my $node5 = node->new(data => {node => "node5"} );

#print Dumper ( $node1, $node2);


#say "---" x 40;

#$node1->add('subnode1', $node2 );
#$node1->add('subnode2', $node3 );
#$node3->add('subsubnode1', $node4 );
#$node3->add('subsubnode2', $node5 );
$,= "\t";
#say  $_->data->{node}, $_->list for $node1,$node2,$node3,$node4,$node5;
#say  $_->env('foodata') for $node1,$node2,$node3,$node4,$node5;
#print Dumper ( $node1, $node2);



$node1->add('subnode1', $node2 );
$node1->add('subnode2', $node3 );
$node2->add('subsubnode1', $node4 );
$node4->add('subsubnode2', $node5 );



print Dumper($node1->getall);

say $_->name, $_->env('node'),  $_->env('foodata'), $_->env('bardata') for $node1->getsubtree;


