 
 -- given is a CSV file, which I copied on desktop
 \copy pyur from 'C:\Users\Hamed Sayidi\Desktop\ad\DNSNT210609_PYUR_Daten.csv' WITh Delimiter ';' csv Header; 

select * from adressen.adressen_nexiga_wgs84 where his is null;

Create table pyur (his varchar(254) , py_tech text, py_dat date, py_down text, py_up text, bemerkungen text);
create index inx_pyur on pyur(his);
alter table pyur add column id bigserial primary key


create table adressen.bk_adressen_nexiga_wgs84  as select * from adressen.adressen_nexiga_wgs84 ;
create table potentialanalysen.bk_pop_cluster_analysestufe2 as
	select  * from potentialanalysen.pop_cluster_analysestufe2;

alter table adressen.adressen_nexiga_wgs84 add  column py_tech text;
alter table adressen.adressen_nexiga_wgs84 add  column py_dat date;
alter table adressen.adressen_nexiga_wgs84 add  column py_down text;
 alter table adressen.adressen_nexiga_wgs84 add column  py_up text;
 alter table adressen.adressen_nexiga_wgs84 add column  py_bemerkungen text; 
 
 
 select py_tech from adressen.adressen_nexiga_wgs84
 
update adressen.adressen_nexiga_wgs84 set 
	py_tech=pyur.py_tech
	,py_dat=pyur.py_dat
	,py_down=pyur.py_down
	,py_up=pyur.py_up
	,py_bemerkungen=pyur.bemerkungen
FROM pyur  where pyur.his= adressen.adressen_nexiga_wgs84.his


-- afshin generated shape files from new clusters
insert into potentialanalysen.pop_cluster_analysestufe2(geom, agg_id, locked, homecount , forced_eq, future_cbl, path, layer)
	select st_force4d(geom), agg_id, locked, homecount , forced_eq, future_cbl, path,null as layer from "pop_clusters_25832ConvertedTo32"
	union all 
	select st_force4d(geom), agg_id, locked, homecount , forced_eq, future_cbl, path, layer from popcluster_25833


alter table potentialanalysen.pop_cluster_analysestufe2 add column py_20 integer;
alter table potentialanalysen.pop_cluster_analysestufe2 add column py_200 integer;
alter table potentialanalysen.pop_cluster_analysestufe2 add column py_400 integer;
alter table potentialanalysen.pop_cluster_analysestufe2 add column py_500 integer;
alter table potentialanalysen.pop_cluster_analysestufe2 add column py_1000 integer;



create table ans2 as
	select 
		sel.id
		, (select count(*) from ans where ans.id=sel.id and dt_tech='1' and dt_down='16' ) dt_dsl_16Mbit
		, (select count(*) from ans where ans.id=sel.id and dt_tech='2' and dt_down='50' ) dt_vdsl_50Mbit
		, (select count(*) from ans where ans.id=sel.id and dt_tech='2' and dt_down='100' ) dt_vdsl_100Mbit
		, (select count(*) from ans where ans.id=sel.id and dt_tech='2' and dt_down='250' ) dt_vdsl_250Mbit
		, (select count(*) from ans where ans.id=sel.id and dt_tech='3' and dt_down='1000' ) dt_gf_1000Mbit
		, (select count(*) from ans where ans.id=sel.id and dt_tech='4' and dt_down='500' ) dt_gf_500Mbit
		, (select count(*) from ans where ans.id=sel.id and kd_tech='1' and kd_down='100' ) kd_100Mbit
		, (select count(*) from ans where ans.id=sel.id and kd_tech='1' and kd_down='200' ) kd_200Mbit
		, (select count(*) from ans where ans.id=sel.id and kd_tech='1' and kd_down='400' ) kd_400Mbit
		, (select count(*) from ans where ans.id=sel.id and kd_tech='1' and kd_down='500' ) kd_500Mbit
		, (select count(*) from ans where ans.id=sel.id and kd_tech='1' and kd_down='1000' ) kd_1000Mbit
		, (select count(*) from ans where ans.id=sel.id and py_down='20' ) py_20
		, (select count(*) from ans where ans.id=sel.id and py_down='200' ) py_200
		, (select count(*) from ans where ans.id=sel.id and py_down='400' ) py_400
		, (select count(*) from ans where ans.id=sel.id and py_down='500' ) py_500
		, (select count(*) from ans where ans.id=sel.id and py_down='1000' ) py_1000
		from (
			select * from potentialanalysen.pop_cluster_analysestufe2                                                      
		) sel;



update potentialanalysen.pop_cluster_analysestufe2 set
		"dt_dsl_16Mbit"=ans2.dt_dsl_16Mbit
		, "dt_vdsl_50Mbit"=ans2.dt_vdsl_50Mbit
		, "dt_vdsl_100MBit"=ans2.dt_vdsl_100Mbit
		, "dt_vdsl_250MBit"=ans2.dt_vdsl_250Mbit
		, "dt_gf_1000MBit"=ans2.dt_gf_1000Mbit
		, "dt_gf_500Mbit"=ans2.dt_gf_500Mbit
		, "kd_100Mbit"=ans2.kd_100Mbit
		, "kd_200MBit"=ans2.kd_200Mbit
		, "kd_400MBit"=ans2.kd_400Mbit
		, "kd_500MBit"=ans2.kd_500Mbit
		, "kd_1000MBit"=ans2.kd_1000Mbit
		, py_20 =ans2.py_20
		, py_200 =ans2.py_200
		, py_400 =ans2.py_400
		, py_500 =ans2.py_500
		, py_1000 =ans2.py_1000
	from ans2
	where potentialanalysen.pop_cluster_analysestufe2.id=ans2.id