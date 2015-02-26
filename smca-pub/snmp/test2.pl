#!/usr/bin/perl

use 5.014;
use warnings;

use Data::Dumper;

my $file   = shift;
my $module = shift;

my $data = do $file or die "oops: $!/$@";
my $mod;


die "no module given " unless $module;

die "module $module not found" unless $data->{$module};

$mod = $data->{$module};

print Dumper ($mod);
