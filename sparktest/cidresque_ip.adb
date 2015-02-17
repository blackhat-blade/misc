package body Cidresque_IP
  with SPARK_Mode
is

	function toInet4num(OA : OctetArray) return Inet4num
   	is
      		octet1_tmp : constant  Unsigned_32 := Unsigned_32(OA(1));
      		octet2_tmp : Unsigned_32 := Unsigned_32(OA(2));
      		octet3_tmp : Unsigned_32 := Unsigned_32(OA(3));
      		octet4_tmp : Unsigned_32 := Unsigned_32(OA(4));
		tmp	   : Unsigned_32; 
	begin

--		tmp :=             octet4_tmp 	   or 
--			Shift_Left(octet3_tmp,  8) or 
--			Shift_Left(octet2_tmp, 16) or 
--			Shift_Left(octet1_tmp, 24);
		tmp := octet1_tmp +  octet2_tmp + octet3_tmp + octet4_tmp;
		return Inet4num(tmp);

	end toInet4num;

end Cidresque_IP;
