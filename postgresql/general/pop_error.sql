
/*------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	Function                                                                                                                                                      --
--	                                                                                                                                                              --
--	                                                                                                                                                              --
--	name:		pop_error                                                                                                                                         --
--	schema:		public                                                                                                                                            --
--	typ:		Function                                                                                                                                          --
--	cr.date:	24-11-2020                                                                                                                                        --
--	ed.date:	24-11-2020                                                                                                                                        --
--	impressionable_tables:                                                                                                                                        --
--				- 										                                                                                                          --
--	purpose: 	                                                                                                                                                  --
--				Show the Errors out of functions.                                                      			                                                  --
--	DNS-Net GIS group                                                                                                                                             --
--*/----------------------------------------------------------------------------------------------------------------------------------------------------------------


create or replace function pop_error(error_message text default 'Error', hint_text text default '') returns void as $$
	BEGIN
		raise exception '%' ,error_message using hint = hint_text;
	END;
	$$language plpgsql;
