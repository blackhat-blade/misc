#!/usr/bin/perl

use 5.014;
use warnings;

use Digest::Whirlpool;
use Crypt::Rijndael;
use Getopt::Long;
use URI::URL;

my $uri;

my $scheme;
my $host;
my $port;
my $userinfo;
my $pathinfo;

my $date;

my $string;
my $version;

our $VERSION = 0;

our $rand =
[
	pack ("h*", 'c6475cf67fdf04dd658f10c00888acca'
		  . '3e5bbb6760502b210f7d0098d97d87c2'
		  . '43417e63bd2fd3e6a0452613950423b3'
		  . '0483456ee0fccce3484af3d5a1b6b3ae'),
];

#y
#y/q
#y/q/m
#y/q/m/d

sub enc
{
	my $in  = shift;
	my $i   = 0;
	my $out = '';
	while ($i < length $in)
	{
		$out .= chr ( ( ord (substr( $in, $i++, 1) ) % 93) + 33);
	}
	return $out;
}

GetOptions('scheme=s' => \$scheme,  "port=i" => \$port,  
           "user=s"   => \$userinfo,  'path=s' => \$pathinfo, date => \$date, 
           "host=s"   => \$host, "version" => \$version,   );

$uri = URI::URL->new;

$uri->scheme($scheme);
$uri->host($host);
$uri->port($port) 	  if $port;
$uri->userinfo($userinfo) if $userinfo;
$uri->path($pathinfo)     if $pathinfo;

$string = $uri->canonical;
#say "can = ", $string;




__END__
my $d = Digest::Whirlpool->new;
$d->add('https://test@example.com/');
 
print enc $d->digest;
