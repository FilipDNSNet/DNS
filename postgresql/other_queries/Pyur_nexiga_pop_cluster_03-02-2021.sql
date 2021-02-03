 
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
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	---   NE 
	
	





drop table ans ;
create table ans as
	select adr.fid, adr.geom , adr.dt_tech, adr.dt_down, adr.kd_tech, adr.kd_down, pol.id , py_tech, py_down, "lchh", anz_fa from adressen.adressen_nexiga_wgs84 adr join potentialanalysen.pop_cluster_analysestufe2 pol on  st_contains(pol.geom, st_transform(adr.geom, 25833))



alter table  potentialanalysen.pop_cluster_analysestufe2   add column ne_dt_dsl_16mbit       integer ;
alter table  potentialanalysen.pop_cluster_analysestufe2   add column ne_dt_vdsl_50mbit      integer ;
alter table  potentialanalysen.pop_cluster_analysestufe2   add column ne_dt_vdsl_100mbit     integer ;
alter table  potentialanalysen.pop_cluster_analysestufe2   add column ne_dt_vdsl_250mbit     integer ;
alter table  potentialanalysen.pop_cluster_analysestufe2   add column ne_dt_gf_1000mbit      integer ;
alter table  potentialanalysen.pop_cluster_analysestufe2   add column ne_dt_gf_500mbit       integer ;
alter table  potentialanalysen.pop_cluster_analysestufe2   add column ne_kd_100mbit          integer ;
alter table  potentialanalysen.pop_cluster_analysestufe2   add column ne_kd_200mbit          integer ;
alter table  potentialanalysen.pop_cluster_analysestufe2   add column ne_kd_400mbit          integer ;
alter table  potentialanalysen.pop_cluster_analysestufe2   add column ne_kd_500mbit          integer ;
alter table  potentialanalysen.pop_cluster_analysestufe2   add column ne_kd_1000mbit         integer ;
alter table  potentialanalysen.pop_cluster_analysestufe2   add column ne_py_20               integer ;   
alter table  potentialanalysen.pop_cluster_analysestufe2   add column ne_py_200              integer ;  
alter table  potentialanalysen.pop_cluster_analysestufe2   add column ne_py_400              integer ;  
alter table  potentialanalysen.pop_cluster_analysestufe2   add column ne_py_500              integer ;  
alter table  potentialanalysen.pop_cluster_analysestufe2   add column ne_py_1000             integer ;  



create table ans3 as
	select 
		sel.id
		, (select sum(coalesce("lchh"::int,0)+ coalesce(anz_fa::int,0))   from ans where ans.id=sel.id and dt_tech='1' and dt_down='16' ) ne_dt_dsl_16Mbit
		, (select sum(coalesce("lchh"::int,0)+ coalesce(anz_fa::int,0))  from ans where ans.id=sel.id and dt_tech='2' and dt_down='50' ) ne_dt_vdsl_50Mbit
		, (select sum(coalesce("lchh"::int,0)+ coalesce(anz_fa::int,0))  from ans where ans.id=sel.id and dt_tech='2' and dt_down='100' ) ne_dt_vdsl_100Mbit
		, (select sum(coalesce("lchh"::int,0)+ coalesce(anz_fa::int,0))  from ans where ans.id=sel.id and dt_tech='2' and dt_down='250' ) ne_dt_vdsl_250Mbit
		, (select sum(coalesce("lchh"::int,0)+ coalesce(anz_fa::int,0))  from ans where ans.id=sel.id and dt_tech='3' and dt_down='1000' ) ne_dt_gf_1000Mbit
		, (select sum(coalesce("lchh"::int,0)+ coalesce(anz_fa::int,0))  from ans where ans.id=sel.id and dt_tech='4' and dt_down='500' ) ne_dt_gf_500Mbit
		, (select sum(coalesce("lchh"::int,0)+ coalesce(anz_fa::int,0))  from ans where ans.id=sel.id and kd_tech='1' and kd_down='100' ) ne_kd_100Mbit
		, (select sum(coalesce("lchh"::int,0)+ coalesce(anz_fa::int,0))  from ans where ans.id=sel.id and kd_tech='1' and kd_down='200' ) ne_kd_200Mbit
		, (select sum(coalesce("lchh"::int,0)+ coalesce(anz_fa::int,0))  from ans where ans.id=sel.id and kd_tech='1' and kd_down='400' ) ne_kd_400Mbit
		, (select sum(coalesce("lchh"::int,0)+ coalesce(anz_fa::int,0))  from ans where ans.id=sel.id and kd_tech='1' and kd_down='500' ) ne_kd_500Mbit
		, (select sum(coalesce("lchh"::int,0)+ coalesce(anz_fa::int,0))  from ans where ans.id=sel.id and kd_tech='1' and kd_down='1000' ) ne_kd_1000Mbit
		, (select sum(coalesce("lchh"::int,0)+ coalesce(anz_fa::int,0))  from ans where ans.id=sel.id and py_down='20' ) ne_py_20
		, (select sum(coalesce("lchh"::int,0)+ coalesce(anz_fa::int,0))  from ans where ans.id=sel.id and py_down='200' ) ne_py_200
		, (select sum(coalesce("lchh"::int,0)+ coalesce(anz_fa::int,0))  from ans where ans.id=sel.id and py_down='400' ) ne_py_400
		, (select sum(coalesce("lchh"::int,0)+ coalesce(anz_fa::int,0))  from ans where ans.id=sel.id and py_down='500' ) ne_py_500
		, (select sum(coalesce("lchh"::int,0)+ coalesce(anz_fa::int,0))  from ans where ans.id=sel.id and py_down='1000' ) ne_py_1000
		from (
			select * from potentialanalysen.pop_cluster_analysestufe2                                                      
		) sel;	
		



update potentialanalysen.pop_cluster_analysestufe2 set
	ne_dt_dsl_16mbit   = ans3.ne_dt_dsl_16Mbit
	, ne_dt_vdsl_50mbit  = ans3.ne_dt_vdsl_50Mbit
	, ne_dt_vdsl_100mbit = ans3.ne_dt_vdsl_100Mbit
	, ne_dt_vdsl_250mbit = ans3.ne_dt_vdsl_250Mbit
	, ne_dt_gf_1000mbit  = ans3.ne_dt_gf_1000Mbit
	, ne_dt_gf_500mbit   = ans3.ne_dt_gf_500Mbit
	, ne_kd_100mbit      = ans3.ne_kd_100Mbit
	, ne_kd_200mbit      = ans3.ne_kd_200Mbit
	, ne_kd_400mbit      = ans3.ne_kd_400Mbit
	, ne_kd_500mbit      = ans3.ne_kd_500Mbit
	, ne_kd_1000mbit     = ans3.ne_kd_1000Mbit
	, ne_py_20           = ans3.ne_py_20
	, ne_py_200          = ans3.ne_py_200
	, ne_py_400          = ans3.ne_py_400
	, ne_py_500          = ans3.ne_py_500
	, ne_py_1000         = ans3.ne_py_1000
from ans3
where potentialanalysen.pop_cluster_analysestufe2.id=ans3.id;


select sum(coalesce("lchh"::int,0)+ coalesce(anz_fa::int,0)) from adressen.adressen_nexiga_wgs84 where   py_tech='1'; --597929
		

--   ---#TODO next: consider count*1.8 for houses that have NE value of null

--alter table potentialanalysen.pop_cluster_analysestufe2  add column ne_status text default 'NE_berechnet';
--
--
--
--create table ans4 as
--	select 
--		sel.id
--		, (select 1.8*count(*) else sum(coalesce("lchh"::int,0)+ coalesce(anz_fa::int,0)) from ans where ("lchh" is null and anz_fa is null ) and  ans.id=sel.id and dt_tech='1' and dt_down='16' ) ne_dt_dsl_16Mbit
--		, (select 1.8*count(*) else sum(coalesce("lchh"::int,0)+ coalesce(anz_fa::int,0)) from ans where ("lchh" is null and anz_fa is null ) and  ans.id=sel.id and dt_tech='2' and dt_down='50' ) ne_dt_vdsl_50Mbit
--		, (select 1.8*count(*) else sum(coalesce("lchh"::int,0)+ coalesce(anz_fa::int,0)) from ans where ("lchh" is null and anz_fa is null ) and  ans.id=sel.id and dt_tech='2' and dt_down='100' ) ne_dt_vdsl_100Mbit
--		, (select 1.8*count(*) else sum(coalesce("lchh"::int,0)+ coalesce(anz_fa::int,0)) from ans where ("lchh" is null and anz_fa is null ) and  ans.id=sel.id and dt_tech='2' and dt_down='250' ) ne_dt_vdsl_250Mbit
--		, (select 1.8*count(*) else sum(coalesce("lchh"::int,0)+ coalesce(anz_fa::int,0)) from ans where ("lchh" is null and anz_fa is null ) and  ans.id=sel.id and dt_tech='3' and dt_down='1000' ) ne_dt_gf_1000Mbit
--		, (select 1.8*count(*) else sum(coalesce("lchh"::int,0)+ coalesce(anz_fa::int,0)) from ans where ("lchh" is null and anz_fa is null ) and  ans.id=sel.id and dt_tech='4' and dt_down='500' ) ne_dt_gf_500Mbit
--		, (select 1.8*count(*) else sum(coalesce("lchh"::int,0)+ coalesce(anz_fa::int,0)) from ans where ("lchh" is null and anz_fa is null ) and  ans.id=sel.id and kd_tech='1' and kd_down='100' ) ne_kd_100Mbit
--		, (select 1.8*count(*) else sum(coalesce("lchh"::int,0)+ coalesce(anz_fa::int,0)) from ans where ("lchh" is null and anz_fa is null ) and  ans.id=sel.id and kd_tech='1' and kd_down='200' ) ne_kd_200Mbit
--		, (select 1.8*count(*) else sum(coalesce("lchh"::int,0)+ coalesce(anz_fa::int,0)) from ans where ("lchh" is null and anz_fa is null ) and  ans.id=sel.id and kd_tech='1' and kd_down='400' ) ne_kd_400Mbit
--		, (select 1.8*count(*) else sum(coalesce("lchh"::int,0)+ coalesce(anz_fa::int,0)) from ans where ("lchh" is null and anz_fa is null ) and  ans.id=sel.id and kd_tech='1' and kd_down='500' ) ne_kd_500Mbit
--		, (select 1.8*count(*) else sum(coalesce("lchh"::int,0)+ coalesce(anz_fa::int,0)) from ans where ("lchh" is null and anz_fa is null ) and  ans.id=sel.id and kd_tech='1' and kd_down='1000' ) ne_kd_1000Mbit
--		, (select 1.8*count(*) else sum(coalesce("lchh"::int,0)+ coalesce(anz_fa::int,0)) from ans where ("lchh" is null and anz_fa is null ) and  ans.id=sel.id and py_down='20' ) ne_py_20
--		, (select 1.8*count(*) else sum(coalesce("lchh"::int,0)+ coalesce(anz_fa::int,0)) from ans where ("lchh" is null and anz_fa is null ) and  ans.id=sel.id and py_down='200' ) ne_py_200
--		, (select 1.8*count(*) else sum(coalesce("lchh"::int,0)+ coalesce(anz_fa::int,0)) from ans where ("lchh" is null and anz_fa is null ) and  ans.id=sel.id and py_down='400' ) ne_py_400
--		, (select 1.8*count(*) else sum(coalesce("lchh"::int,0)+ coalesce(anz_fa::int,0)) from ans where ("lchh" is null and anz_fa is null ) and  ans.id=sel.id and py_down='500' ) ne_py_500
--		, (select 1.8*count(*) else sum(coalesce("lchh"::int,0)+ coalesce(anz_fa::int,0)) from ans where ("lchh" is null and anz_fa is null ) and  ans.id=sel.id and py_down='1000' ) ne_py_1000
--		from (
--			select * from potentialanalysen.pop_cluster_analysestufe2                                                      
--		) sel;
--


-- join the tables adressen.adressen and adressen.adressen_nexiga_wgs84
create table adressen.gis_nexiga_adressen as
	select
		adr.id,
		nex.fid nex_id,
		nex.plz||replace(replace(replace( replace(lower(replace(nex.str_name, ' ', '')) , 'straße', 'str') ,'strasse','str') ,'-','' ) || nex.hnr||coalesce(lower(nex.hnr_zs),'')  , '.','') nex_key,
		adr.plz|| replace(replace(replace(replace(lower(replace(adr.strasse, ' ', '')) , 'straße', 'str') ,'strasse','str') ,'-', '') || adr.hausnr||coalesce(lower(adr.adresszusatz),''), '.','')  adr_key
	from 
		adressen.adressen  adr 
		join
		adressen.adressen_nexiga_wgs84 nex 
		on (
				(nex.oi is not null and adr.alkis_id is not null and nex.oi=adr.alkis_id)
			or
				(
					(nex.oi is  null or adr.alkis_id is  null  )
				and
					nex.plz||replace(replace(replace( replace(lower(replace(nex.str_name, ' ', '')) , 'straße', 'str') ,'strasse','str') ,'-','' ) || nex.hnr||coalesce(lower(nex.hnr_zs),'')  , '.','') 
					=
					adr.plz|| replace(replace(replace(replace(lower(replace(adr.strasse, ' ', '')) , 'straße', 'str') ,'strasse','str') ,'-', '') || adr.hausnr||coalesce(lower(adr.adresszusatz),''), '.','') 
				and 
					st_distance(st_transform(nex.geom, 4326), adr.geom ,false) < 25
				)
			)
		