-- For a given database, schema and table, this function gives read access to that specific table.
-- if the user priviously has had edit privileges, after this function is run, he/she can only read the table.
-- DNS-GIS-Team
--01-03-2021

CREATE OR REPLACE function access.dns_set_privileges_read(db text, sch text, tbl text, usr text) returns text AS $$
DECLARE
	---- This function is used to set the privileges for a user for each table with READ privileges according on 
	---- DNS_net_user-model desinged in 2021 by DNS-NET GIS group.
	---- If the user priviously has had write privileges on the given table,it would be reduced to read-only.
	msg text;
BEGIN
	-- revoke write privileges if exists
	Execute('Select access.dns_revoke_privileges_on_table($1, $2, $3, $4);') using db , sch , tbl , usr ;
	EXECUTE('GRANT CONNECT ON DATABASE "'||db||'" TO "'||usr||'";');
	EXECUTE('GRANT USAGE ON SCHEMA "'||sch||'" TO "'||usr||'";');
	EXECUTE('GRANT SELECT ON TABLE "'||sch||'"."'||tbl||'" TO "'||usr||'";');
	SELECT E'\n=> Granted read_only on table "'||sch||'"."'||tbl||'" to role "'||usr||'":'||
		E'\n\tGRANT CONNECT ON DATABASE "'||db||'" TO "'||usr||'";'||
		E'\n\tGRANT USAGE ON SCHEMA "'||sch||'" TO "'||usr||'";'||
		E'\n\tGRANT SELECT ON TABLE "'||sch||'"."'||tbl||'" TO "'||usr||'";' into msg;
	raise notice '%', msg;
	return 'Granted read_only on table "'||sch||'"."'||tbl||'" to Role "'||usr||'" !';
END;
$$ LAnguage plpgsql;
-- comment:
COMMENT ON FUNCTION access.dns_set_privileges_read(db text, sch text, tbl text, usr text) IS
	E'This function is used to set the privileges for a user for each table with READ privileges according on 
	DNS_net_user-model desinged in 2021 by DNS-NET GIS group.
	\n\n => If the user priviously has had write privileges on the given table,it would be reduced to read-only.';