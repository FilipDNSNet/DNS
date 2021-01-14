
/*------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	Function                                                                                                                                                      --
--	                                                                                                                                                              --
--	                                                                                                                                                              --
--	name:		dns_getcolor                                                                                                                                      --
--	schema:		public                                                                                                                                            --
--	typ:		Function                                                                                                                                          --
--	cr.date:	24-11-2020                                                                                                                                        --
--	ed.date:	24-11-2020                                                                                                                                        --
--	impressionable_tables:                                                                                                                                        --
--				- 										                                                                                                          --
--	purpose: 	                                                                                                                                                  --
--				Get the color corresponding to the given numebr and farbcode.                                                     			                      --
--	DNS-Net GIS group                                                                                                                                             --
--*/----------------------------------------------------------------------------------------------------------------------------------------------------------------


create or replace function dns_getcolor(indx integer, std text DEFAULT 'DIN_VDE_0888') returns text as $$
	begin
		return (select farbe from _farbcode where std=standard and code=indx union all select NULL limit 1);
	End;
	$$ LANGUAGE PLPGSQL;