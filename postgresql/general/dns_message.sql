
/*------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	Function                                                                                                                                                      --
--	                                                                                                                                                              --
--	                                                                                                                                                              --
--	name:		dns_message                                                                                                                                       --
--	schema:		public                                                                                                                                            --
--	typ:		Function                                                                                                                                          --
--	cr.date:	24-11-2020                                                                                                                                        --
--	ed.date:	24-11-2020                                                                                                                                        --
--	impressionable_tables:                                                                                                                                        --
--				- 										                                                                                                          --
--	purpose: 	                                                                                                                                                  --
--				Show the dns_message out of functions.                                                      			                                          --
--	DNS-Net GIS group                                                                                                                                             --
--*/----------------------------------------------------------------------------------------------------------------------------------------------------------------


create or replace function dns_message(pretxt text default 'dns', txt text default '-') returns void as $$ 
begin
	raise notice '% : %' ,pretxt, txt;
end;
$$ language plpgsql; 
