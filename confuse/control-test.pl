#!/usr/bin/perl
use 5.012;
use warnings;

use Data::Dumper;

use Moose;

package graphitem;
use Moose;
has item => (is => 'ro');
has data => (is => 'ro', isa => "HashRef", default => sub { return {} });
has instanceclass => (is => 'ro', isa => 'Str');
has root => (is => 'ro', required => 1 );
sub instancify
{
	my ($self, $parent, $name) = @_;
	$self->instanceclass->meta->rebless_instance($self, parent => $parent, name  => $name);
	$self;
}

sub treedump
{
	my ($self,$level) = @_;
	my $buf = '';

	$level ||= 0;

	$buf .= " " x $level ; 
	$buf .= $self->can("name") ? $self->name : "(float)";
	
	if ($self->can('getall'))
	{
		$buf .= "/\n";
		$buf .= ($_->can('treedump') ?  $_->treedump($level + 1) : '') for $self->getall; 
	}
	else 
	{
		$buf .= "\n";
	}
	return $buf;
}

package node;
use Moose;
extends 'graphitem';
has childs => (is => 'ro', isa => "HashRef", default => sub {return {} });
has instanceclass => (is => 'ro', default => "nodeinstance");
sub list{ return keys %{shift->childs} }

sub add 
{
	my ($self, $name, $o) = @_; 
	die "DUP" if $self->childs->{$name};

	$self->childs->{$name} =  $o->instancify($self,  $name);   
}

sub get
{
	my ($self, $name) = @_;
	die "NOENT" unless exists $self->childs->{$name};
	return  $self->childs->{$name};
}

sub check
{
	my ($self, $name) = @_;
	return exists $self->childs->{$name};
}

sub checkpath
{
	my ($self, $path) = @_;
	return $self->getpath($path) && 1;
}

sub getpath
{
	my ($self, $path) = @_;
	my ($part, @rest) = (@{$path});

	return 0 unless $self->check($part);
	return $self->get($part) unless @rest;
	return $self->get($part)->getpath(\@rest);
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




package graphinstance;
use Moose::Role;

has name   => (is => 'ro', isa => 'Str');
has parent => (is => 'ro', isa => 'Object', required => 1);

sub env
{
	my ($self, $key) = @_;

	return $self->data->{$key} if exists $self->data->{$key};
	return undef unless $self->parent;
	return $self->parent->env($key)  if $self->parent->can('env');
	return $self->parent->data->{$key} if exists $self->data->{$key};
	 
}

package nodeinstance;
use Moose;
extends 'node';
with 'graphinstance';

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

print 'name',   $root->name;
print 'parent', $root->parent;
print 'root',   $root->root;

say $root->treedump;

#__END__

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
