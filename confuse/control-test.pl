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
use pgconfig;

sub maketree
{
	my ($parent, $subtree) = @_;


	foreach my $key (keys %{$subtree})
	{
	        my $class = $subtree->{$key}->{class};
	        my $data  = $subtree->{$key}->{data};
	        my $sub  = $subtree->{$key}->{childs};

		maketree ($parent->createsub($key, $class), $sub) ;
	}
}




my $root = root->new;

($\,$,) = ("\n", "\t");


sub dir   (+%) {  return {class => 'node', data => shift }   }
sub file  ($)  {  return {class => 'leaf', data => shift }   }

maketree $root,
{
	db =>
	{
		class  =>  'node',
		childs =>
		{
			db3	=>
			{
				class => 'pgconfig',
				data  =>
				{
					log_connections => 1,
					log_destination => 'syslog',
				}
			}
		}, 
			
	},
};







say $root->treedump;
