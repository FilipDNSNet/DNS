create Schema if not exists access;
comment on schema access is 'This schema contains the admin contents and functions. DNS-Net GIS Team (Feb 2021)';

revoke all on schema public from public;
grant usage on schema public to public;
revoke ALL on schema access from public;
revoke all on schema bk from public;


CREATE ROLE gr_dns_net_geodb_readonly WITH NOSUPERUSER NOCREATEDB NOLOGIN NOREPLICATION NOCREATEROLE; --View most of schemas. It cannot view at least schema "access"

--- => the difference with gr_dns_net_geodb_viewer is that "gr_dns_net_geodb_viewer" can see all of the tables, but "gr_dns_net_geodb_readonly" can see customizable list of tables.


DO $$
DECLARE
	---- Give all of the tables readabel for gr_dns_net_geodb_readonly
	tbl text;
	sch text;
	db text;
	ret text;
BEGIN
	select 'dns_net_geodb' into db;
	for sch in 
		(select schema_name from INFORMATION_SCHEMA.schemata 
			where schema_name not in ( 'pg_toast', 'pg_temp_1', 'pg_toast_temp_1', 'pg_catalog', 'information_schema','access', 'bk') order by schema_name )
	loop
		for tbl in (select table_name from INFORMATION_SCHEMA.tables where table_schema=sch) loop
			select access.dns_set_privileges_read(db,sch, tbl, 'gr_dns_net_geodb_readonly') into ret;
		end loop;
	end loop;
END
$$ Language plpgsql;
