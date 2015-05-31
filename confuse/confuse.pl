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

sub pathpp
{
	my $path = shift;
	my @path;

	return '(undef)' unless $path;
	return "(invalid val='$path')" unless ref $path;

	@path = @{$path};

	return '/' if @path == 1 && $path[0] eq '';
	return '/' . join '/', @path;
	
}

sub filename_fixup 
{
	my ($file, @path);

	$file = shift;
	$file =~ s!^/!!;

        print "asked for file '$file'\n";

	@path = split /\//, $file;

	return [''] unless @path;
	return \@path;
}

sub getattr 
{
	my ($file) = filename_fixup(shift);

	print "getattr called with: ", pathpp($file), "\n";

	return -ENOENT() unless $root->checkpath($file);
	my $size = $root->getpath($file)->isa('leaf') ? length $root->getpath($file)->content : 0 ;
	my $type = $root->getpath($file)->isa('leaf') ? 0100 : 0040;
	my $mode = 0755;
	
	my $modes = ($type<<9) + $mode;
	my ($dev, $ino, $rdev, $blocks, $gid, $uid, $nlink, $blksize) = (0,0,0,1,0,0,1,1024);
	my ($atime, $ctime, $mtime);
	$atime = $ctime = $mtime = 0;
	return ($dev,$ino,$modes,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks);
}

sub getdir 
{
	my $path = filename_fixup(shift);

	print "getdir called for ", pathpp($path), "\n";

	return -ENOENT() unless $root->checkpath($path);
	return (map { $_->name  } $root->getpath($path)->getall )   ,0;
	
}

sub open
 {
	my $file = filename_fixup(shift);
	my ($flags, $fileinfo) = @_;
	my $fh;

	print("open called $file, $flags, ",Dumper($fileinfo), "\n");

	return -ENOENT() unless $root->checkpath($file);
	return -EISDIR() if $root->getpath($file)->isa('node');
 	$fh = [ $root->getpath($file)  ];
	print("open ok (handle $fh)\n");
	return (0, $fh);
}

sub read 
{
	my ($filename, $buf, $off, $fh) = @_;

	print "read from $fh ($filename), $buf \@ $off\n";

	return -ENOENT() unless $fh->[0]; 
	return -EINVAL() if $off >  length $fh->[0]->content;
	return 0 	 if $off == length $fh->[0]->content;

	print "retval = '",  substr( $fh->[0]->content, $off, $buf), "'\n";

	return substr( $fh->[0]->content, $off, $buf);
}

sub write
{
	my ($filename, $buf, $off, $fh) = @_;

	print "writing ", length $buf ," to $fh ($filename)  \@ $off\ncursize = ", length($fh->[0]->content) || 0, "\n";
	my $content = $fh->[0]->content;
	
	unless ($off || defined $content)
	{
		$fh->[0]->content($buf);
		return length $buf; 
	}

	if ($off > length $content )
	{
		$content .= chr(0) x ($off - length $content); 
	}

	substr ($content, $off, length($buf)) = $buf;
	$fh->[0]->content($content);
	
	length $buf;
}

sub truncate
{
	my ($filename, $offset) = @_;
	my ($leaf, $file);

	$file = filename_fixup($filename);
	print "truncation of $file ($filename) \@ $offset";

	return -ENOENT() unless $root->checkpath($file);
	$leaf = $root->getpath($file);
	return EINVAL()  if $offset > length $leaf->content;
	$leaf->content(substr $leaf->content, 0, $offset);
	return 0;
}
 
sub ftruncate
{
	my ($filename, $offset, $fh) = @_;
	my $leaf = $fh->[0];

	print "ftruncation of $fh \@ $offset";

	return EINVAL()  if $offset > length $leaf->content;
	$leaf->content(substr $leaf->content, 0, $offset);
	return 0;
}

sub create
{
	my ($path, $mask, $flags) = @_;
	my $realpath = filename_fixup($path);
	my $name     = pop @{$realpath};

	my $parentdir;
	my $sub;

	print "create of $path, called with mask = $mask, flags = $flags\n";

	$parentdir = $root->getpath($realpath);	
	$sub       = $parentdir->createsub( $name, 'leaf');

	return 0, [$sub];

}

sub statfs 
{
	return 255, 1, 1, 1, 1, 2
}


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

Fuse::main
(
	mountpoint 	=> $mountpoint,
	getattr 	=> "main::getattr",
	getdir 		=> "main::getdir",
	open   		=> "main::open",
	statfs 		=> "main::statfs",
	read   		=> "main::read",
	write		=> "main::write",
	truncate	=> "main::truncate",
	ftruncate	=> "main::ftruncate",
	create		=> "main::create",
	threaded 	=> 0
);
