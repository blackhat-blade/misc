package graphinstance;
use Moose::Role;
use 5.012;

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
1;
