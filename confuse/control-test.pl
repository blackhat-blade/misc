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
		if (ref $subtree->{$key})
		{
			maketree ($parent->createsub($key, 'node'), $subtree->{$key}) ;
		}
		else
		{
			$parent->createsub($key, 'leaf', content => $subtree->{$key});
		}
	}
}




my $root = root->new;

($\,$,) = ("\n", "\t");


maketree $root,
{
	bin => 
	{
		sh    => '',
		true  => '',
		false => '',
		echo  => '',	
	},
	sbin =>
	{
		init => '',
		halt => '',
		reboot => '',
	},
	usr =>
	{
		bin => 
		{
			perl => '',
		},
		lib =>
		{
		},
		src =>
		{
		}
	}
};

say $root->treedump;
