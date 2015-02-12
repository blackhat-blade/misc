#!/usr/bin/perl

use 5.014;
use warnings;

use Digest::Whirlpool;





sub enc
{
	
	my $in = shift;
	my $i  = 0;
	my $out = '';
	while ($i < length $in)
	{

		$out .= chr ( ( ord (substr( $in, $i++, 1) ) % 93) + 33);
	}
	return $out;
}

my $d = Digest::Whirlpool->new;
$d->add('https://test@example.com/201505');
 
print enc $d->digest;
