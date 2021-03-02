-- For a given database, schema and table, this function gives Edit access to that specific table.
-- DNS-GIS-Team
--01-03-2021

CREATE OR REPLACE function access.dns_set_privileges_edit(db text, sch text, tbl text, usr text) returns text AS $$
DECLARE
	---- This function is used to set the privileges for a user for each table with EDIT privileges according on 
	---- DNS_net_user-model desinged in 2021 by DNS-NET GIS group.
	msg text;
BEGIN
	EXECUTE('GRANT CONNECT ON DATABASE "'||db||'" TO "'||usr||'"');
	--EXECUTE('GRANT ALL ON SCHEMA "'||sch||'" TO "'||usr||'";');
	EXECUTE('GRANT USAGE ON SCHEMA "'||sch||'" TO "'||usr||'";');
	EXECUTE('GRANT SELECT, UPDATE, DELETE, INSERT, TRUNCATE ON TABLE "'||sch||'"."'||tbl||'" TO "'||usr||'";');
	EXECUTE('GRANT SELECT, USAGE ON ALL SEQUENCES IN SCHEMA "'||sch||'" TO "'||usr||'";');
	EXECUTE('GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO "'||usr||'";');
	SELECT E'\n=> Granted edit on table "'||sch||'"."'||tbl||'" to role "'||usr||'":'||
		E'\n\tGRANT CONNECT ON DATABASE "'||db||'" TO "'||usr||'"'||
		E'\n\tGRANT ALL ON SCHEMA "'||sch||'" TO "'||usr||'";'||
		E'\n\tGRANT SELECT, UPDATE, DELETE, INSERT, TRUNCATE ON TABLE "'||sch||'"."'||tbl||'" TO "'||usr||'";'||
		E'\n\tGRANT SELECT, USAGE ON ALL SEQUENCES IN SCHEMA "'||sch||'" TO "'||usr||'";'||
		E'\n\tGRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO "'||usr||'";' into msg;
	raise notice '%', msg;
	return 'Granted edit on table "'||sch||'"."'||tbl||'" to Role "'||usr||'" !';
END;
$$ LAnguage plpgsql;
-- comment:
COMMENT ON FUNCTION access.dns_set_privileges_edit(db text, sch text, tbl text, usr text) IS
	E'This function is used to set the privileges for a user for each table with EDIT privileges according on 
	DNS_net_user-model desinged in 2021 by DNS-NET GIS group.';
