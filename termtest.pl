#!/usr/bin/perl

use 5.012;
use warnings;
use Time::HiRes qw'usleep';


sub p {print @_}

sub W() { "\e[1A"  }
sub S() { "\e[1B"  }
sub A() { "\e[1D"  }
sub D() { "\e[1C"  }

#sub e { "\033",@_  }
#sub l { '[', @_}

#sub M($$) { "\e[#;#H" =~ s!#!shift!gre, @_ }


my $i = 0;
$| = 1;
p "\e[2J\e[?6l";


#p M 2,2 , 'test';
 
p "\e[2;2H", 
  
 ,"\e[30;0H\e[7m12345\e[0m\e[3;29r\e[?6h\e[;H";

while ( usleep 200000 )
{
	p S, join ' ', (localtime())[2,1,0],"\e[1000D";	
}

__END__
my ($x,$y);

for ($x = 0; $x < 180; $x += 5)
{
	for ($y = 0; $y < 40; $y += 5)
	{
		p M $y, $x, 'X'; 
	}
}

__END__
while ( 1 )
{
	++$i;
	#p "\e[3;8"
	#p e l "3;8H$i", e l "1B", join ( ' ', (localtime)[2,1,0] );
	#p 'foo';
	sleep 1;
	
}
