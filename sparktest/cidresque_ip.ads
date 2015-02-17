with Interfaces;
use Interfaces;

package Cidresque_IP
with SPARK_Mode

is

   type OctetValue is new Unsigned_8;
   type OctetIndex is range 1 .. 4;
   type OctetArray is array (OctetIndex) of OctetValue;

   type Inet4num   is mod 2 ** 32;

   function toInet4num (OA : OctetArray) return Inet4num
	with Contract_Cases =>
       (
          True => True
			--OA(4) = 0 and OA(3) = 0 and OA(2) = 0 and OA(1) = 0      => toInet4num'Result = 0,
			--(OA(1) + OA(2) + OA(3) + OA(4)) >= 1 => toInet4num'Result >= 0
   	),
	Global => null,
	Depends => (toInet4num'Result => OA);


end Cidresque_IP;
