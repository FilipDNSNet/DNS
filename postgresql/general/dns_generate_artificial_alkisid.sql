

/*------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	Function                                                                                                                                                      --
--	                                                                                                                                                              --
--	                                                                                                                                                              --
--	name:		dns_generate_artificial_alkisid                                                                                                                   --
--	schema:		public                                                                                                                                            --
--	typ:		Function                                                                                                                                          --
--	cr.date:	13-01-2021                                                                                                                                        --
--	ed.date:	13-01-2021                                                                                                                                        --
--	impressionable_tables:                                                                                                                                        --
--				adressen.adressen						                                                                                                          --
--	purpose: 	                                                                                                                                                  --
--				Get the color corresponding to the given numebr and farbcode.                                                     			                      --
--	DNS-Net GIS group                                                                                                                                             --
--*/----------------------------------------------------------------------------------------------------------------------------------------------------------------




create or replace function dns_generate_artificial_alkisid() returns varchar(16) as $$
DECLARE
	ret varchar(16);
	counter integer:=0;
BEGIN
	-- This function is desinged to generate Artificial Alkis_id. When the new generated Adress has no Alkis_id
	-- then this Id is generated. It starts with "TEMP" follwoed by 12 digits. If the number is already used, then
	-- a new number is generated.
	select 'TEMP'||left((1e5+random()*1e6)::text,6)||left((1e5+random()*1e6)::text,6) into ret;
	--raise notice 'Here:  => % , %',ret,length(ret);
	WHILE exists (select from adressen.adressen where alkis_id=ret) LOOP
		select 'TEMP'||left((1e5+random()*1e6)::text,6)||left((1e5+random()*1e6)::text,6) into ret;
		--raise notice 'here';
		select counter+1 into counter;
		if counter>100 then
			select pop_error(E'DNS-net_Error \n Function dns_generate_artificial_alkisid() cannot 
				generate a unique alkisid in table adressen.adressen for adressess missing alkis_id.');
		end if;
	end LOOP;
	return ret;
END; $$ Language PLPGSQL;



update adressen.adressen set alkis_id=dns_generate_artificial_alkisid() where alkis_id is null ;

alter table adressen.adressen alter column alkis_id set default dns_generate_artificial_alkisid();

