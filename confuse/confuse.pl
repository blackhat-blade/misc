#!/usr/bin/perl
use 5.012;
use warnings;

use Data::Dumper;

use Fuse qw(fuse_get_context);
use POSIX qw(ENOENT EISDIR EINVAL);

use lib './lib';

use graphitem;
use node;
use graphinstance;
use nodeinstance;
use leaf;
use leafinstance;
use root;

my $root = root->new;

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

sub filename_fixup 
{

	my ($file) = shift;
        print "asked for file '$file'\n";
	$file =~ s!^/!!;
	#return ['', split /\//, $file];

	my @path = split /\//, $file;
	@path = ('') unless @path;
	\@path;

}

sub e_getattr {
	my ($file) = filename_fixup(shift);

	print "get addr called with: ", Dumper($file), "\n";

	return -ENOENT() unless $root->checkpath($file);
	my $size = 0;
	my $type = $root->getpath($file)->isa('leaf') ? 0100 : 0040;
	my $mode = 0755;
	
	my $modes = ($type<<9) + $mode;
	my ($dev, $ino, $rdev, $blocks, $gid, $uid, $nlink, $blksize) = (0,0,0,1,0,0,1,1024);
	my ($atime, $ctime, $mtime);
	$atime = $ctime = $mtime = 0;#$files{$file}{ctime};
	return ($dev,$ino,$modes,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks);
}

sub e_getdir 
{
	my $path = filename_fixup(shift);

	print "getdir called for ", Dumper($path), "\n";

	
	#if (@{$path} == 1 && $path->[0] eq '')
	#{
	#	return $root->getall(), 0;
	#}

	return -ENOENT() unless $root->checkpath($path);
	return (map { $_->name  } $root->getpath($path)->getall )   ,0;
	
}

sub e_open
 {
	my $file = filename_fixup(shift);
	my ($flags, $fileinfo) = @_;
	my $fh;

	print("open called $file, $flags, $fileinfo\n");

	return -ENOENT() unless $root->checkpath($file);
	return -EISDIR() if $root->getpath($file)->isa('node');
 	$fh = [ $root->getpath($file)  ];
	print("open ok (handle $fh)\n");
	return (0, $fh);
}

sub e_read {
	# return an error numeric, or binary/text string.  (note: 0 means EOF, "0" will
	# give a byte (ascii "0") to the reading program)
	#my ($file) = filename_fixup(shift);
	my ($filename, $buf, $off, $fh) = @_;

	print "read from $fh ($filename), $buf \@ $off\n";
	#print "file handle:\n", Dumper($fh);

	return -ENOENT() unless $fh->[0]; 
	
	return -EINVAL() if $off >  length $fh->[0]->content;
	return 0 	 if $off == length $fh->[0]->content;

	print "content = ", $fh->[0]->content, "\n";
	return substr $fh->[0]->content, $off, $buf;

#	if(!exists($files{$file}{cont})) {
#		return -EINVAL() if $off > 0;
#		my $context = fuse_get_context();
#		return sprintf("pid=0x%08x uid=0x%08x gid=0x%08x\n",@$context{'pid','uid','gid'});
#	}
#	return -EINVAL() if $off > length($files{$file}{cont});
#	return 0 if $off == length($files{$file}{cont});
#	return substr($files{$file}{cont},$off,$buf);
	-EINVAL();
}

sub e_statfs { return 255, 1, 1, 1, 1, 2 }

my ($mountpoint) = "";
$mountpoint = shift(@ARGV) if @ARGV;

maketree $root,
{
	bin => 
	{
		sh    => 'a shell',
		true  => 'always returns 0',
		false => 'always returns a non zero value',
		echo  => 'echos its parameters',	
	},
	sbin =>
	{
		init => 'useless thing',
		halt => 'fixes all problems',
		reboot => 'same as halt but only temporary',
	},
	usr =>
	{
		bin => 
		{
			perl => 'all you need',
		},
		lib =>
		{
		},
		src =>
		{
		}
	}
};

#say $root->treedump;
Fuse::main(
	mountpoint=>$mountpoint,
	getattr=>"main::e_getattr",
	getdir =>"main::e_getdir",
	open   =>"main::e_open",
	statfs =>"main::e_statfs",
	read   =>"main::e_read",
	threaded=>0
);
