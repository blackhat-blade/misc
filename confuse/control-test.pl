#!/usr/bin/perl
use 5.012;
use warnings;

use Data::Dumper;
use lib './lib';

use graphitem;
use node;
use graphinstance;
use nodeinstance;
use leaf;
use leafinstance;
use root;

sub maketree
{
	my ($parent, $subtree) = @_;

	foreach my $key (keys %{$subtree})
	{
		my ($name, $class) = split /:/, $key;
		
		maketree ($parent->createsub($name, $class), $subtree->{$key}) ;
		
	}
}




my $root = root->new;

($\,$,) = ("\n", "\t");


sub dir   (+%) {  return {class => 'node', data => shift }   }
sub file  ($)  {  return {class => 'leaf', data => shift }   }

maketree $root,
{
	bin => dir
	{
	},
	opt => dir
	{
	}

};

say $root->treedump;
