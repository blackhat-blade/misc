package node;
use graphitem;
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

	return $self if $part eq '';
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

sub createsub
{
	my ($self, $name, $class, @data) = @_;
	my $o;
	
	$o = $class->new(root => $self->root, @data);
	$self->add($name, $o);
	return $o;
}
1;
