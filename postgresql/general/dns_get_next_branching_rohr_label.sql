
/*------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	Function                                                                                                                                                      --
--	                                                                                                                                                              --
--	                                                                                                                                                              --
--	name:		dns_get_next_branching_rohr_label                                                                                                                 --                     
--	schema:		public                                                                                                                                            --
--	typ:		Function                                                                                                                                          --
--	cr.date:	24-11-2020                                                                                                                                        --
--	ed.date:	24-11-2020                                                                                                                                        --
--	impressionable_tables:                                                                                                                                        --
--				- 										                                                                                                          --
--	purpose: 	                                                                                                                                                  --
--				-                                                      			                                                                                  --
--	DNS-Net GIS group                                                                                                                                             --
--*/----------------------------------------------------------------------------------------------------------------------------------------------------------------


create or replace function dns_get_next_branching_rohr_label (label text) returns text as $$
declare
	ret text;
	val text;
	temp text;
begin
	select right(label, 1) into temp;
	--if temp=any(ARRAY['-','/','_']) then
	--	select left(right(label, 2),1) into temp; 
	--end if;
	if temp= ANY(Array['0','1','2','3','4','5','6','7','8','9']) then
		select  label||'-a' into ret;
	elsif temp='a' Then
		select left(label, -1)||'b' into ret;
	elsif temp='b' Then
		select left(label, -1)||'c' into ret;
	elsif temp='c' Then
		select left(label, -1)||'d' into ret;
	elsif temp='d' Then
		select left(label, -1)||'e' into ret;	
	elsif temp='e' Then
		select left(label, -1)||'f' into ret;
	elsif temp='f' Then
		select left(label, -1)||'g' into ret;
	end if;
	return ret;
end;
$$ language plpgsql;
--select dns_get_next_branching_rohr_label('fsdfad/01-a');--  =>  fsdfad/01-b
