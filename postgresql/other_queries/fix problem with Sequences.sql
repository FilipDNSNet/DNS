-- Apply the fix on sequence on exisitng sequences. The trigger for sequences should get run also on new table level.


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
		ELSIF obj.object_type='sequence' Then
				EXECUTE 'GRANT SELECT, USAGE ON SEQUENCE '||obj.object_identity||' TO gr_<db_name>_editor;';
				EXECUTE 'GRANT SELECT ON SEQUENCE '||obj.object_identity||' TO gr_<db_name>_viewer;';
		END IF;
	END LOOP;
END
$$ LANGUAGE plpgsql;





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


