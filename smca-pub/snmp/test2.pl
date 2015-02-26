#!/usr/bin/perl

use 5.014;
use warnings;

use Data::Dumper;

my $file = 'mib/pg.stat.activity.dmp.pl';
my $data = do $file or die "oops: $@";

print Dumper ($data);
