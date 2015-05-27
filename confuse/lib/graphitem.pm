package graphitem;
use 5.014;

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
1;
