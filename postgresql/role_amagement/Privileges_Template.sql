/*
The template for the definition of Privileges on a Database.
This code should be run on each database. database to give the privileges to the following roles(groups):
	gr_edior_<db_name>
	gr_<db_name>_viewer_<db_name>
	
with the following definitions:
	CREATE ROLE gr_<db_name>_editor WITH NOSUPERUSER NOCREATEDB NOLOGIN NOREPLICATION NOCREATEROLE;
	CREATE ROLE gr_<db_name>_viewer WITH NOSUPERUSER NOCREATEDB NOLOGIN NOREPLICATION NOCREATEROLE;
If the database already exists, it applies the privileges on the existin objects.
to check later :
	Foraign TABLES ??????
last Edit: 09-09-2020
Hamed
*/

/*  Replace the sting in this file  <db_name>  with the name of the database */
DO
$do$
BEGIN
   IF NOT EXISTS (
	  SELECT FROM pg_catalog.pg_roles  -- SELECT list can be empty for this
	  WHERE  rolname in ('gr_<db_name>_editor','gr_<db_name>_viewer' ) ) THEN
		CREATE ROLE gr_<db_name>_editor WITH NOSUPERUSER NOCREATEDB NOLOGIN NOREPLICATION NOCREATEROLE;
		CREATE ROLE gr_<db_name>_viewer WITH NOSUPERUSER NOCREATEDB NOLOGIN NOREPLICATION NOCREATEROLE;
   END IF;
END
$do$;


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
	/* User : gr_<db_name>_viewer*/
	EXECUTE 'GRANT CONNECT ON DATABASE "'||dbnam||'" TO gr_<db_name>_viewer;';
	EXECUTE 'GRANT SELECT ON ALL TABLES IN SCHEMA '|| schs || ' TO gr_<db_name>_viewer;';
	EXECUTE 'GRANT USAGE ON SCHEMA '||schs||' TO gr_<db_name>_viewer;';
	/* User : gr_<db_name>_editor*/
	EXECUTE 'GRANT CONNECT ON DATABASE "'||dbnam||'" TO gr_<db_name>_editor;';
	EXECUTE 'GRANT SELECT, UPDATE, DELETE, INSERT, TRUNCATE ON ALL TABLES IN SCHEMA '|| schs || ' TO gr_<db_name>_editor;';
	EXECUTE 'GRANT ALL ON SCHEMA '||schs||' TO gr_<db_name>_editor;';
	EXECUTE 'GRANT SELECT, USAGE ON ALL SEQUENCES IN SCHEMA '||schs||' TO gr_<db_name>_editor;';
	EXECUTE 'GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO gr_<db_name>_editor;';
	raise notice 'schs of the database %: %', dbnam, schs;
END$$;



-------------------------------------------------------------------------------------------------------------------------------
/*Triggers:	*/
DROP EVENT TRIGGER IF EXISTS dns_tr_newdomain;
DROP EVENT TRIGGER IF EXISTS dns_tr_newfunction;
DROP EVENT TRIGGER IF EXISTS dns_tr_newschema;
DROP EVENT TRIGGER IF EXISTS dns_tr_newsequence;
DROP EVENT TRIGGER IF EXISTS dns_tr_newtable;
DROP EVENT TRIGGER IF EXISTS dns_tr_newtype;
-------------------------------------------------------------------------------------------------------------------------------
--Schema : 
CREATE OR REPLACE FUNCTION dns_tr_newschema() RETURNS event_trigger AS $schemacreation$
DECLARE
	obj record;
BEGIN
	raise notice 'new schema was created!';
	FOR obj IN SELECT * FROM pg_event_trigger_ddl_commands()
	LOOP
		RAISE NOTICE 'tag:%   classid:%   obj.object_type:%   obj.schema_name:%,  object_identity:%',
					 tg_tag,
					 obj.classid,
					 obj.object_type,
					 obj.schema_name,
					 obj.object_identity;
		EXECUTE 'GRANT USAGE ON SCHEMA '||obj.object_identity||' TO gr_<db_name>_viewer;';
		EXECUTE 'GRANT ALL ON SCHEMA '||obj.object_identity||' TO gr_<db_name>_editor;';
	END LOOP;
END
$schemacreation$ LANGUAGE plpgsql;
COMMENT ON FUNCTION dns_tr_newschema IS E'Trigger function for Role mangement on the database <db_name> (Model 09-09-2020). \nDNS GIS-Team';


CREATE EVENT TRIGGER dns_tr_newschema ON ddl_command_end WHEN TAG IN ('CREATE SCHEMA') EXECUTE PROCEDURE dns_tr_newschema();
COMMENT ON EVENT TRIGGER  dns_tr_newschema IS E'Trigger for Role mangement on the database <db_name> (Model 09-09-2020). \nDNS GIS-Team';
-------------------------------------------------------------------------------------------------------------------------------
-- Tables:
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
		END IF;
	END LOOP;
END
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION dns_tr_newtable IS E'Trigger function for Role mangement on the database <db_name> (Model 09-09-2020). \nDNS GIS-Team';
CREATE EVENT TRIGGER dns_tr_newtable ON ddl_command_end WHEN TAG IN ('CREATE TABLE','CREATE VIEW' , 'CREATE TABLE AS', 'CREATE MATERIALIZEd VIEW'/*, 'CREATE FOREIGH TABLE'*/) EXECUTE PROCEDURE dns_tr_newtable();
COMMENT ON EVENT TRIGGER  dns_tr_newtable IS E'Trigger for Role mangement on the database <db_name> (Model 09-09-2020). \nDNS GIS-Team';
-------------------------------------------------------------------------------------------------------------------------------
-- sequences
CREATE OR REPLACE FUNCTION dns_tr_newsequence() RETURNS event_trigger AS $body$
DECLARE
	obj record;
BEGIN
	raise notice 'new Sequence was created!';
	FOR obj IN SELECT * FROM pg_event_trigger_ddl_commands()
	LOOP
		RAISE NOTICE 'tag:%   classid:%   obj.object_type:%   obj.schema_name:%,  object_identity:%',
					 tg_tag,
					 obj.classid,
					 obj.object_type,
					 obj.schema_name,
					 obj.object_identity;
		EXECUTE 'GRANT SELECT, USAGE ON SEQUENCE '||obj.object_identity||' TO gr_<db_name>_editor;';
		EXECUTE 'GRANT SELECT ON SEQUENCE '||obj.object_identity||' TO gr_<db_name>_viewer;';
	END LOOP;
END
$body$ LANGUAGE plpgsql;
COMMENT ON FUNCTION dns_tr_newsequence IS E'Trigger function for Role mangement on the database <db_name> (Model 09-09-2020). \nDNS GIS-Team';

CREATE EVENT TRIGGER dns_tr_newsequence ON ddl_command_end WHEN TAG IN ('CREATE SEQUENCE') EXECUTE PROCEDURE dns_tr_newsequence();
COMMENT ON EVENT TRIGGER  dns_tr_newsequence IS E'Trigger for Role mangement on the database <db_name> (Model 09-09-2020). \nDNS GIS-Team';
-------------------------------------------------------------------------------------------------------------------------------
-- functions
CREATE OR REPLACE FUNCTION dns_tr_newfunction() RETURNS event_trigger AS $body$
DECLARE
	obj record;
BEGIN
	raise notice 'new function was created!';
	FOR obj IN SELECT * FROM pg_event_trigger_ddl_commands()
	LOOP
		RAISE NOTICE 'tag:%   classid:%   obj.object_type:%   obj.schema_name:%,  object_identity:%',
					 tg_tag,
					 obj.classid,
					 obj.object_type,
					 obj.schema_name,
					 obj.object_identity;
		IF obj.schema_name = 'public' THEN 
			EXECUTE 'GRANT EXECUTE ON FUNCTION '||obj.object_identity||' TO gr_<db_name>_viewer;';
		END IF;
		EXECUTE 'GRANT EXECUTE ON FUNCTION '||obj.object_identity||' TO gr_<db_name>_editor;';
	END LOOP;
END
$body$ LANGUAGE plpgsql;
COMMENT ON FUNCTION dns_tr_newfunction IS E'Trigger function for Role mangement on the database <db_name> (Model 09-09-2020). \nDNS GIS-Team';

CREATE EVENT TRIGGER dns_tr_newfunction ON ddl_command_end WHEN TAG IN ('CREATE FUNCTION') EXECUTE PROCEDURE dns_tr_newfunction();
COMMENT ON EVENT TRIGGER  dns_tr_newfunction IS E'Trigger for Role mangement on the database <db_name> (Model 09-09-2020). \nDNS GIS-Team';
-------------------------------------------------------------------------------------------------------------------------------
-- Domain
CREATE OR REPLACE FUNCTION dns_tr_newdomain() RETURNS event_trigger AS $body$
DECLARE
	obj record;
BEGIN
	raise notice 'new domain was created!';
	FOR obj IN SELECT * FROM pg_event_trigger_ddl_commands()
	LOOP
		RAISE NOTICE 'tag:%   classid:%   obj.object_type:%   obj.schema_name:%,  object_identity:%',
					 tg_tag,
					 obj.classid,
					 obj.object_type,
					 obj.schema_name,
					 obj.object_identity;
		EXECUTE 'GRANT USAGE ON DOMAIN '||obj.object_identity||' TO public;';
	END LOOP;
END
$body$ LANGUAGE plpgsql;
COMMENT ON FUNCTION dns_tr_newdomain IS E'Trigger function for Role mangement on the database <db_name> (Model 09-09-2020). \nDNS GIS-Team';

CREATE EVENT TRIGGER dns_tr_newdomain ON ddl_command_end WHEN TAG IN ('CREATE DOMAIN') EXECUTE PROCEDURE dns_tr_newdomain();
COMMENT ON EVENT TRIGGER  dns_tr_newdomain IS E'Trigger for Role mangement on the database <db_name> (Model 09-09-2020). \nDNS GIS-Team';
-------------------------------------------------------------------------------------------------------------------------------
-- Types
CREATE OR REPLACE FUNCTION dns_tr_newtype() RETURNS event_trigger AS $body$
DECLARE
	obj record;
BEGIN
	raise notice 'new type was created!';
	FOR obj IN SELECT * FROM pg_event_trigger_ddl_commands()
	LOOP
		RAISE NOTICE 'tag:%   classid:%   obj.object_type:%   obj.schema_name:%,  object_identity:%',
					 tg_tag,
					 obj.classid,
					 obj.object_type,
					 obj.schema_name,
					 obj.object_identity;
		EXECUTE 'GRANT USAGE ON TYPE '||obj.object_identity||' TO public;';
	END LOOP;
END
$body$ LANGUAGE plpgsql;
COMMENT ON FUNCTION dns_tr_newtype IS E'Trigger function for Role mangement on the database <db_name> (Model 09-09-2020). \nDNS GIS-Team';

CREATE EVENT TRIGGER dns_tr_newtype ON ddl_command_end WHEN TAG IN ('CREATE TYPE') EXECUTE PROCEDURE dns_tr_newtype();
COMMENT ON EVENT TRIGGER  dns_tr_newtype IS E'Trigger for Role mangement on the database <db_name> (Model 09-09-2020). \nDNS GIS-Team';
