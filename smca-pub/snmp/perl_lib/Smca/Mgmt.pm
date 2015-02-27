use 5.014;
use warnings;


package Smca::Mgmt::Meta::Trait;
use Moose::Role;

has object_type => 
(
	is  =>    'ro',
	isa => 'Str',
	required => 1
);

has object_identifier =>
(
	is  =>   'ro',
	isa => 'Str',
	required => 1
);

after create => sub {my $in = $_[1]->meta; say "foo! created ", $in->object_identifier, " of ", $in->object_type};


package Smca::Mgmt::Meta;
use Moose;
extends 'Moose::Meta::Class';
with    'Smca::Mgmt::Meta::Trait';



#package;

#registry	module	basetype	type


1;
