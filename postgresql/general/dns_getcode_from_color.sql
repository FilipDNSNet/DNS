/*------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	Function                                                                                                                                                      --
--	                                                                                                                                                              --
--	                                                                                                                                                              --
--	name:		dns_getcode_from_color                                                                                                                            --
--	schema:		public                                                                                                                                            --
--	typ:		Function                                                                                                                                          --
--	cr.date:	25-03-2021                                                                                                                                        --
--	ed.date:	25-03-2021                                                                                                                                        --
--	impressionable_tables:                                                                                                                                        --
--				- 										                                                                                                          --
--	purpose: 	                                                                                                                                                  --
-- 			 from table '_farbcode' this table returns the code of the given color. The color is a string with standard abbreviation 							  --
-  				E.G: rot => 'rt'       dns_getcode_from_color('rt')   =>   1  																					  --
--	DNS-Net GIS group                                                                                                                                             --
--*/----------------------------------------------------------------------------------------------------------------------------------------------------------------



--drop function  if exists dns_getcode_from_color;


CREATE OR REPLACE FUNCTION dns_getcode_from_color(color text, standard_ text default 'DIN_VDE_0888') returns integer as $$
DECLARE
	-- from table '_farbcode' this table returns the code of the given color. The color is a string with standard abbreviation. E.G: rot => 'rt'
	flag boolean;
BEGIN
	SELECT EXISTS (	
		SELECT FROM information_schema.tables 
		WHERE  table_schema = 'public'
		AND    table_name   = '_farbcode'
		) INTO flag;
	IF flag Then
		return (select code from _farbcode where lower(farbe)=lower(color) and lower(_farbcode.standard)=lower(standard_));
	ELSE
		RETURN null;
	END IF;
END;
$$ LANGUAGE PLPGSQL;

