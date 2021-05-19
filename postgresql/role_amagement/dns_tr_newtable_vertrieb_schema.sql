create schema vertrieb;
COMMENT ON Schema vertrieb IS E'Editable Schema for Jürgen. Assigned by Michael Siegert. \n12-05-2021\nDNS GIS-Team';
grant all on schema vertrieb to juergen;




CREATE OR REPLACE FUNCTION dns_tr_newtable_vertrieb_schema() RETURNS event_trigger AS $$
DECLARE
	obj record;
	sequ text;
BEGIN
	FOR obj IN SELECT * FROM pg_event_trigger_ddl_commands()
	LOOP
		RAISE notice 'Privileges on "%" are granted to User "juergen"' ,obj.object_identity;
		--RAISE NOTICE 'tag:%   classid:%   obj.object_type:%   obj.schema_name:%,  object_identity:%',
		--			 tg_tag,
		--			 obj.classid,
		--			 obj.object_type,
		--			 obj.schema_name,
		--			 obj.object_identity;
		IF obj.schema_name='vertrieb' and obj.object_type in ('table', 'view', 'materialized view') THEN
			EXECUTE 'GRANT SELECT, UPDATE, DELETE, INSERT, TRUNCATE ON TABLE '||obj.object_identity||' TO juergen;';
		ELSIF obj.schema_name='vertrieb' and obj.object_type='sequence' Then
				EXECUTE 'GRANT SELECT, USAGE ON SEQUENCE '||obj.object_identity||' TO juergen;';
		END IF;
	END LOOP;
END
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION dns_tr_newtable_vertrieb_schema IS E'Trigger function for grant privileges on tables in schema "vertrieb" to Jürgen. \n12-05-2021\nDNS GIS-Team';
CREATE EVENT TRIGGER dns_tr_newtable_vertrieb_schema ON ddl_command_end WHEN TAG IN ('CREATE TABLE','CREATE VIEW' , 'CREATE TABLE AS', 'CREATE MATERIALIZEd VIEW'/*, 'CREATE FOREIGH TABLE'*/) EXECUTE PROCEDURE dns_tr_newtable_vertrieb_schema();
COMMENT ON EVENT TRIGGER  dns_tr_newtable_vertrieb_schema IS E'Trigger function for grant privileges on tables in schema "vertrieb" to Jürgen. \n12-05-2021\nDNS GIS-Team';




