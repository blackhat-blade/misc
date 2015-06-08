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


maketree $root,
{
	bin:node => 
	{
		sh:leaf    => '',
		true:leaf  => '',
		false:leaf => '',
		echo:leaf  => '',	
	},
	sbin:node =>
	{
		init:leaf => '',
		halt:leaf => '',
		reboot:leaf => '',
	},
	usr:node =>
	{
		bin:node => 
		{
			perl:leaf => '',
		},
		lib:node =>
		{
		},
		src:node =>
		{
		}
	}
};

say $root->treedump;
