
/*------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	Function                                                                                                                                                      --
--	                                                                                                                                                              --
--	                                                                                                                                                              --
--	name:		dns_get_alphabet_of_int                                                                                                                           --
--	schema:		public                                                                                                                                            --
--	typ:		Function                                                                                                                                          --
--	cr.date:	24-11-2020                                                                                                                                        --
--	ed.date:	24-11-2020                                                                                                                                        --
--	impressionable_tables:                                                                                                                                        --
--				- 										                                                                                                          --
--	purpose: 	                                                                                                                                                  --
--				-								                                                      			                                                  --
--	DNS-Net GIS group                                                                                                                                             --
--*/----------------------------------------------------------------------------------------------------------------------------------------------------------------

create or replace function dns_get_alphabet_of_int (val integer) returns varchar(1) as $$
begin
	return (select case 
		when val=1 then 'a'
		when val=2 then 'b'
		when val=3 then 'c'
		when val=4 then 'd'
		when val=5 then 'e'
		when val=6 then 'f'
		when val=7 then 'g'
		when val=8 then 'h'
		when val=9 then 'i'
		when val=10 then 'j'
		when val=11 then 'k'
		when val=12 then 'L'
		when val=13 then 'm'
		when val=14 then 'n'
		when val=15 then 'o'
		when val=16 then 'p'
		when val=17 then 'q'
		when val=18 then 'r'
		when val=19 then 's'
		when val=20 then 't'
		when val=21 then 'u'
		when val=22 then 'v'
		when val=23 then 'w'
		when val=24 then 'x'
		when val=25 then 'y'
		when val=26 then 'z'
		else '*' 
	end);
end;
$$ language plpgsql;

--select dns_get_alphabet_of_int(5)
