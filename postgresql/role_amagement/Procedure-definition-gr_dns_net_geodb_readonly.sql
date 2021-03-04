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



---- as we said, we used thw privious strategy on ther databases. 
--- Therefore, we needed to fix a bug on all of them.

-- correction:
CREATE OR REPLACE FUNCTION dns_tr_newtable() RETURNS event_trigger AS $$
DECLARE
	obj record;
	sequ text;
BEGIN
	raise notice 'new Table was created!';
	FOR obj IN SELECT * FROM pg_event_trigger_ddl_commands()
	LOOP
		RAISE NOTICE 'tag:%   classid:%   obj.object_type:%   obj.schema_name:%,  object_identity:%',
					 tg_tag,
					 obj.classid,
					 obj.object_type,
					 obj.schema_name,
					 obj.object_identity;
		IF obj.object_type in ('table', 'view', 'materialized view') THEN
			EXECUTE 'GRANT SELECT ON TABLE '||obj.object_identity||' TO gr_<db_name>_viewer;';
			EXECUTE 'GRANT SELECT, UPDATE, DELETE, INSERT, TRUNCATE ON TABLE '||obj.object_identity||' TO gr_<db_name>_editor;';
		ELSIF obj.object_type='sequence' Then---- new
				EXECUTE 'GRANT SELECT, USAGE ON SEQUENCE '||obj.object_identity||' TO gr_<db_name>_editor;';---- new
				EXECUTE 'GRANT SELECT ON SEQUENCE '||obj.object_identity||' TO gr_<db_name>_viewer;';---- new
		END IF;
	END LOOP;
END
$$ LANGUAGE plpgsql;



--correction on existing sequences: (for capital letterof schema, it might not work)
DO $$
DECLARE
	dbnam text; /* The name of database*/
	sch text; /* Temporary value*/
	schs text; /* The names of schemas*/
BEGIN
	SELECT current_database() INTO dbnam;
	FOR sch IN 
		select schema_name from information_schema.schemata
			where schema_name <> 'information_schema' and schema_name !~ E'^pg_'  
	LOOP
		IF schs is null then
			SELECT sch into schs;
		else
			SELECT concat(schs ,', ', sch) into schs;
		end if;
	END LOOP;
	EXECUTE 'GRANT SELECT, USAGE ON ALL SEQUENCES IN SCHEMA '||schs||' TO gr_<db_name>_editor;';
	EXECUTE 'GRANT SELECT ON ALL SEQUENCES IN SCHEMA '||schs||' TO gr_<db_name>_viewer;';
	raise notice 'schs of the database %: %', dbnam, schs;
END$$;



