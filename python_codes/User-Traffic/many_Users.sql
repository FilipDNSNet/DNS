select * from enum_status_nvt;

select * from adressen.adressen limit 5;

SELECT COUNT(*) from pg_stat_activity;


select *
from pg_stat_activity
where datname = 'dns_net_geodb' order by usename

enum_bun
select access.dns_set_privileges_edit('dns_net_geodb', 'adressen','adresse_abschluss', 'afshin' );



select  usename , count(usename) cnt from pg_stat_activity group by usename order by cnt;

SELECT pid, pg_terminate_backend(pid) 
 FROM pg_stat_activity where pid in 
 	(select pid from pg_stat_activity where  pid <> pg_backend_pid() AND usename='msiegert' );

-----------------





SELECT * FROM pg_stat_database order by datname;


select * from pg_stat_activity order by usename
select usename , count(usename) cnt from pg_stat_activity group by usename order by cnt

SELECT pg_cancel_backend(2817);
SELECT pg_terminate_backend(29488);

SELECT pg_terminate_backend(1907);





SELECT pg_terminate_backend(pg_stat_activity.procpid) 
 FROM pg_stat_get_activity(NULL::integer) 
 WHERE datid=(SELECT oid from pg_database where datname = 'your_database');