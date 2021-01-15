
/*------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	Function                                                                                                                                                      --
--	                                                                                                                                                              --
--	                                                                                                                                                              --
--	name:		dns_validate_new_abscluss_id                                                                                                                                         --
--	schema:		public                                                                                                                                            --
--	typ:		Function                                                                                                                                          --
--	cr.date:	24-11-2020                                                                                                                                        --
--	ed.date:	24-11-2020                                                                                                                                        --
--	impressionable_tables:                                                                                                                                        --
--				- 										                                                                                                          --
--	purpose: 	                                                                                                                                                  --
--				this function tests if a given id is already stored in the database with the given cluster id or not.	                                          --
--	DNS-Net GIS group                                                                                                                                             --
--*/----------------------------------------------------------------------------------------------------------------------------------------------------------------


create or replace function dns_validate_new_abscluss_id(new_id uuid,cluster integer) returns boolean as $$
declare
	-- this function tests if a given id is already stored in the database with the given cluster id or not.
	cnt integer;
	sch text;
begin
	if cluster is null then
		return False;
	end if;
	select schema_name from _cluster where id= cluster into sch;
	if sch is null or sch not in 
		(select s.nspname as table_schema	from pg_catalog.pg_namespace s 	join pg_catalog.pg_user u on u.usesysid = s.nspowner
			where nspname not in ('information_schema', 'pg_catalog')	  and nspname not like 'pg_toast%'	  and nspname not like 'pg_temp_%'	)
		then return False;
	end if;
	execute('select count(id) from '||sch||'.abschlusspunkte where id=$1;') using new_id into cnt;
	if cnt=1 THEN
		return true;
	ELSE
		return false;
	end if;
end;
$$ language plpgsql;