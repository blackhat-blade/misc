#!/usr/bin/perl

use 5.014;
use warnings;

use Data::Dumper;

use Moose::Meta::Class;

my $file       = shift;
my $moduleName = shift;

my $data = do $file or die "oops: $!/$@";

my $moduleData;
my $moduleClassName;
my $moduleClass;



die "no module given " unless $moduleName;

die "module $moduleName not found" unless $data->{$moduleName};

$moduleData = $data->{$moduleName};

#print Dumper ($moduleData );

$moduleClassName = join '::', map {ucfirst lc } split '-', $moduleName;

say "moduleClassName = $moduleClassName"; 

$moduleClass = Moose::Meta::Class->create($moduleClassName);

print Dumper ($moduleClass );
