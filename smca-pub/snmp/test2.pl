#!/usr/bin/perl

use 5.014;
use warnings;

use Data::Dumper;

use Moose;
use Moose::Meta::Class;
use Moose::Meta::Attribute;


my $file       = shift;
my $moduleName = shift;

my $data = do $file or die "oops: $!/$@";

my $moduleData;
my $moduleClassName;
my $moduleClass;



die "no module given " unless $moduleName;

die "module $moduleName not found" unless $data->{$moduleName};

$moduleData = $data->{$moduleName};

print Dumper ($moduleData );

$moduleClassName = join '::', map {ucfirst lc } split '-', $moduleName;

say "moduleClassName = $moduleClassName"; 

$moduleClass = Moose::Meta::Class->create($moduleClassName);


for (qw/name description organization contact identity path language/)
{
		$moduleClass->add_attribute($_, is => 'ro', init_arg => undef, default => $moduleData->{$_});
}

my $rvcName = join '::', $moduleClassName, 'Revision'; 
my $rvc = Moose::Meta::Class->create($rvcName);

my $mr = sub 
{
		my		$c;
		my $i = shift;
		my $date = shift;
		my $dsc  = shift;

		$c = Moose::Meta::Class->create($rvcName . $i);
		$c->superclasses( $rvc );
		$c->add_attribute(date => is => ro =>  init_arg => undef, default => $date);
		$c->add_attribute(description => is => ro =>  init_arg => undef, default => $dsc);
		return $c; 
};








print Dumper ($moduleClass->new_object );
