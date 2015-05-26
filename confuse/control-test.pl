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

	say "self = ", ($self->can('name') ? $self->name : '(floating)');
	say "part = ", $part;
	say "rest = ", join (" ", @rest);
	say $self->treedump, "\n";
	

	return 0 unless $self->check($part);
	return $self->get($part) unless @rest;
	return $self->get($part)->getpath(\@rest);
#	return $self->get(@rest) if     @rest == 0;
#	return $self->getpath(\@rest);
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
	$buf .= "\n";
	$buf .= $_->treedump($level + 1) for $self->getall; 

	return $buf;
 
}


package nodeinstance;
use Moose;
extends 'node';
has name   => (is => 'ro', isa => 'Str');
has parent => (is => 'ro', isa => 'Object');

sub env
{
	my ($self, $key) = @_;

	return $self->data->{$key} if exists $self->data->{$key};
	return undef unless $self->parent;
	return $self->parent->env($key)  if $self->parent->can('env');
	return $self->parent->data->{$key} if exists $self->data->{$key};
	 
}


package main;

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

#say $node1->treedump;

#say $node1->checkpath([qw/subnode1 subsubnode1 nothere/]);
say $node1->checkpath([qw/subnode1 subsubnode1 /]);
#say $node1->check('subnode2');
#say $node1->check('subsubnode2');
