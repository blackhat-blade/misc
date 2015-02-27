#!/usr/bin/perl

use 5.014;
use warnings;
use lib "./perl_lib";
use Smca::Mgmt;

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

#print Dumper ($moduleData );

$moduleClassName = join '::', map {ucfirst lc } split '-', $moduleName;

say "moduleClassName = $moduleClassName"; 

$moduleClass = Moose::Meta::Class->create($moduleClassName);


for (qw/name description organization contact identity path language references/)
{
		$moduleClass->add_attribute($_, is => 'ro', init_arg => undef, default => $moduleData->{$_});
}

my $rvcName = join '::', $moduleClassName, 'Revision'; 
my $rvc     = Moose::Meta::Class->create($rvcName);

my $mr = sub 
{
		my		$c;
		my $date = shift;
		my $dsc  = shift;

		state $i = 0;
 
		$c = Moose::Meta::Class->create($rvcName . ++$i);
		$c->superclasses( $rvcName );
		$c->add_attribute(date => is => ro =>  init_arg => undef, default => $date);
		$c->add_attribute(description => is => ro =>  init_arg => undef, default => $dsc);
		return $c; 
};

my @revisionClasses = map { $mr->($_->{date}, $_->{description}) } 
                        sort { ( $a->{date} =~ s/\D//rg ) <=> ( $b->{date} =~ s/\D//rg ) } 
                          @{$moduleData->{revisions}};


$moduleClass->add_attribute('revisions', is => 'ro', 
                            isa      => "ArrayRef[${rvcName}]",
							default  => sub {[ map {$_->new_object} @revisionClasses ]},
							init_arg => undef );


my $typebaseclass = Moose::Meta::Class->create(join '::', $moduleClassName, 'Type');

my @types = keys %{$moduleData->{typedefs}};
my %types;

foreach my $type (@types)
{
		my $typedata  = $moduleData->{typedefs}->{$type};
		my $typeclass = Moose::Meta::Class->create(join '::', $moduleClassName, 'Type', $type);

		$typeclass->superclasses($typebaseclass->name);


		$types{$type} = $typeclass;
} 




print Dumper ($moduleClass->new_object );
print Dumper ($moduleClass );
