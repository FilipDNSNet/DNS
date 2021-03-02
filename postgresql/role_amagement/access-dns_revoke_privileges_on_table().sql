-- For a given database, schema and table, this function revokes access to that specific table.
-- DNS-GIS-Team
--01-03-2021

create or replace function access.dns_revoke_privileges_on_table(db text, sch text, tbl text, usr text) returns text as $$
DECLARE
	---- This function is used to revoke privileges on a specific Table from the iven user. 
	---- If the user is the wner of the given table, the ownership would be transfered to "postgres".
	---- 2021 DNS-NET GIS group.
	own text; 
	msg text:='';
BEGIN
	EXECUTE('SELECT tableowner from pg_tables where schemaname=$1 and tablename=$2;')using sch, tbl into own;
	IF own=usr THEN
		EXECUTE('ALTER TABLE "'||sch||'"."'||tbl||'" OWNER TO postgres;');
		Select E'\n\tChanged Ownership : ALTER TABLE "'||sch||'"."'||tbl||'" OWNER TO postgres;' into msg;
	END IF;
	EXECUTE('REVOKE ALL ON TABLE "'||sch||'"."'||tbl||'" FROM "'||usr||'";');
	select E'\n=> Revoke access on table "'||sch||'"."'||tbl||'" from Role "'||usr||'" :'
		||msg||E'\n\tRevoked: REVOKE ALL ON TABLE "'||sch||'"."'||tbl||'" FROM "'||usr||'" !' into msg;
	raise notice '%', msg;
	return 'Revoked access on table "'||sch||'"."'||tbl||'" from Role "'||usr||'" !';
END;
$$ language PLPGSQL;
COMMENT ON FUNCTION access.dns_revoke_privileges_on_table(db text, sch text, tbl text, usr text) IS
	E'This function is used to revoke privileges on a specific Table from the iven user. 
	\nIf the user is the wner of the given table, the ownership would be transfered to "postgres".
	\nDNS-NET GIS group (Feb. 2021)';
