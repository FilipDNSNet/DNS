 
 -- given is a CSV file, which I copied on desktop

select * from adressen.adressen_nexiga_wgs84 where his is null;

Create table pyur (his varchar(254) , py_tech text, py_dat date, py_down text, py_up text, bemerkungen text);
create index inx_pyur on pyur(his);
alter table pyur add column id bigserial primary key;

 \copy pyur from 'C:\Users\Hamed Sayidi\Desktop\ad\DNSNT210609_PYUR_Daten.csv' WITh Delimiter ';' csv Header; 
 
 

 

--------------         prepare adressen.adressen_nexiga_wgs84    ------------------------------------------------------------------------------------------------------------------------------------

----make backup:
--create table adressen.bk_adressen_nexiga_wgs84  as select * from adressen.adressen_nexiga_wgs84 ;

alter table adressen.adressen_nexiga_wgs84 add column py_tech text;
alter table adressen.adressen_nexiga_wgs84 add column py_dat date;
alter table adressen.adressen_nexiga_wgs84 add column py_down text;
alter table adressen.adressen_nexiga_wgs84 add column  py_up text;
alter table adressen.adressen_nexiga_wgs84 add column  py_bemerkungen text; 
 
update adressen.adressen_nexiga_wgs84 set 
	py_tech=pyur.py_tech
	,py_dat=pyur.py_dat
	,py_down=pyur.py_down
	,py_up=pyur.py_up
	,py_bemerkungen=pyur.bemerkungen
FROM pyur  where pyur.his= adressen.adressen_nexiga_wgs84.his

ALTER TABLE adressen.adressen_nexiga_wgs84 add column ne_schaetzung float;	
				
UPDATE adressen.adressen_nexiga_wgs84 set ne_schaetzung=case when (lchh is  not null or anz_fa is not null) then
						coalesce(lchh::int,0)+ coalesce(anz_fa::int,0)
					else
						1.8
					end;


--------------         create table : potentialanalysen.pop_clusters_stf_2    ------------------------------------------------------------------------------------------------------------------------------------

-- drop table if exists potentialanalysen.pop_clusters_stf_2;
create table potentialanalysen.pop_clusters_stf_2 (
	id serial primary key
	, ninox_nr integer
	, geom geometry(POLYGON, 4326)
	, agg_id text[]	--agg_id integer[]
	, locked varchar(1)[]
	, homecount integer
	, forced_eq varchar(254)[]
	, future_cbl text[]	--future_cbl integer[]
	
	, dt_dsl_16mbit integer
	, dt_vdsl_50mbit integer
	, dt_vdsl_100mbit integer
	, dt_vdsl_250mbit integer
	, dt_gf_1000mbit integer
	, dt_gf_500mbit integer
	, kd_100mbit integer
	, kd_200mbit integer
	, kd_400mbit integer
	, kd_500mbit integer
	, kd_1000mbit integer
		
	, py_20 integer
	, py_200 integer
	, py_400 integer
	, py_500 integer
	, py_1000 integer
	
	, ne_dt_dsl_16mbit integer 
	, ne_dt_vdsl_50mbit integer 
	, ne_dt_vdsl_100mbit integer 
	, ne_dt_vdsl_250mbit integer 
	, ne_dt_gf_1000mbit integer 
	, ne_dt_gf_500mbit integer 
	, ne_kd_100mbit integer 
	, ne_kd_200mbit integer 
	, ne_kd_400mbit integer 
	, ne_kd_500mbit integer 
	, ne_kd_1000mbit integer 
	, ne_py_20 integer 
	, ne_py_200 integer 
	, ne_py_400 integer 
	, ne_py_500 integer 
	, ne_py_1000 integer 
	
	, total_adr integer
	, total_ne	integer
	, total_ne_schaetzung float
	
	,geom_m geometry(geometry, 4326)
	);
create unique index uix_pop_clusters_stf_2_ninox_nr on potentialanalysen.pop_clusters_stf_2 (ninox_nr);
Create index inx_pop_clusters_stf_2_geom on potentialanalysen.pop_clusters_stf_2 using GIST(geom);
Create index inx_pop_clusters_stf_2_geom_m on potentialanalysen.pop_clusters_stf_2 using GIST(geom_m);

--------------         feed "potentialanalysen.pop_clusters_stf_2" from shapefiles    ------------------------------------------------------------------------------------------------------------------------------------
--create teomporary schema : shp
create schema if not exists shp;
---- The new shape file for each pop-cluster is generated to shapefiles in a folder By Felix and Afshin.
---- These shapes are then imported to shema "shp"
---- Shape files has the name as follows
----	xx<ninox_nr>.shp
----	xx12
----	xx265
----	 => import them in schema shp

do $$
declare
   t text;
begin
  for t in (SELECT distinct table_name FROM information_schema.columns where table_schema='shp' and lower(table_name) like 'xx%' order by  table_name) loop
	Execute('	insert into potentialanalysen.pop_clusters_stf_2  (ninox_nr, geom, agg_id,   homecount, forced_eq, future_cbl, geom_m)
		select (right($1,-2))::int, st_convexhull(st_union(st_transform(st_geometryn(geom,1),4326))) ,    array_agg(agg_id),  sum(homecount) homecount 
		, array_agg(forced_eq) , array_agg(future_cbl), st_union(st_transform(geom,4326))   from shp."'||t||'";') using t; 
   
--	Execute('	insert into potentialanalysen.pop_clusters_stf_2  (ninox_nr, geom, agg_id,  locked, homecount, forced_eq, future_cbl)
--		select (right($1,-2))::int,st_transform(st_geometryn(geom,1),4326) , agg_id,  locked, homecount, forced_eq, future_cbl  from shp."'||t||'";') using t;
  end loop;
end;
$$ language plpgsql;



--------------         udapte some columns of potentialanalysen.pop_clusters_stf_2     ------------------------------------------------------------------------------------------------------------------------------------

drop table if exists ans ;
create table ans as
	select adr.fid, adr.geom , adr.dt_tech, adr.dt_down, adr.kd_tech, adr.kd_down , py_tech, py_down, lchh, anz_fa , pol.id , adr.ne_schaetzung
	from adressen.adressen_nexiga_wgs84 adr join potentialanalysen.pop_clusters_stf_2 pol 
		on  st_contains(pol.geom_m, st_transform(adr.geom, 4326));

create index inx_ans_temp_id on ans(id);

alter table potentialanalysen.pop_clusters_stf_2 drop column geom_m;

drop table if exists ans2 ;	
create table ans2 as
	select 
		sel.id
		, (select count(*) from ans where ans.id=sel.id and dt_tech='1' and dt_down='16' ) dt_dsl_16mbit
		, (select count(*) from ans where ans.id=sel.id and dt_tech='2' and dt_down='50' ) dt_vdsl_50mbit
		, (select count(*) from ans where ans.id=sel.id and dt_tech='2' and dt_down='100' ) dt_vdsl_100mbit
		, (select count(*) from ans where ans.id=sel.id and dt_tech='2' and dt_down='250' ) dt_vdsl_250mbit
		, (select count(*) from ans where ans.id=sel.id and dt_tech='3' and dt_down='1000' ) dt_gf_1000mbit
		, (select count(*) from ans where ans.id=sel.id and dt_tech='4' and dt_down='500' ) dt_gf_500mbit
		, (select count(*) from ans where ans.id=sel.id and kd_tech='1' and kd_down='100' ) kd_100mbit
		, (select count(*) from ans where ans.id=sel.id and kd_tech='1' and kd_down='200' ) kd_200mbit
		, (select count(*) from ans where ans.id=sel.id and kd_tech='1' and kd_down='400' ) kd_400mbit
		, (select count(*) from ans where ans.id=sel.id and kd_tech='1' and kd_down='500' ) kd_500mbit
		, (select count(*) from ans where ans.id=sel.id and kd_tech='1' and kd_down='1000' ) kd_1000mbit
		, (select count(*) from ans where ans.id=sel.id and py_down='20' ) py_20
		, (select count(*) from ans where ans.id=sel.id and py_down='200' ) py_200
		, (select count(*) from ans where ans.id=sel.id and py_down='400' ) py_400
		, (select count(*) from ans where ans.id=sel.id and py_down='500' ) py_500
		, (select count(*) from ans where ans.id=sel.id and py_down='1000' ) py_1000
		, (select count(*) from ans where ans.id=sel.id) total_adr
		, (select sum(coalesce(lchh::int,0)+ coalesce(anz_fa::int,0)) from ans where ans.id=sel.id) total_ne
		, (select sum(ne_schaetzung) from ans where ans.id=sel.id) total_ne_schaetzung
		from  potentialanalysen.pop_clusters_stf_2 sel;                                                   

update potentialanalysen.pop_clusters_stf_2 set
		dt_dsl_16mbit=ans2.dt_dsl_16mbit
		, dt_vdsl_50mbit=ans2.dt_vdsl_50mbit
		, dt_vdsl_100mbit=ans2.dt_vdsl_100mbit
		, dt_vdsl_250mbit=ans2.dt_vdsl_250mbit
		, dt_gf_1000mbit=ans2.dt_gf_1000mbit
		, dt_gf_500mbit=ans2.dt_gf_500mbit
		, kd_100mbit=ans2.kd_100mbit
		, kd_200mbit=ans2.kd_200mbit
		, kd_400mbit=ans2.kd_400mbit
		, kd_500mbit=ans2.kd_500mbit
		, kd_1000mbit=ans2.kd_1000mbit
		, py_20 =ans2.py_20
		, py_200 =ans2.py_200
		, py_400 =ans2.py_400
		, py_500 =ans2.py_500
		, py_1000 =ans2.py_1000
		, total_adr= ans2.total_adr
		, total_ne= ans2.total_ne
		, total_ne_schaetzung= round(ans2.total_ne_schaetzung::numeric, 1)
	from ans2
	where potentialanalysen.pop_clusters_stf_2.id=ans2.id;
	
----    Ne VALUES   
drop table if exists ans3 ;

---- with real NE
--create table ans3 as
--	select 
--		sel.id
--		, (select sum(coalesce(lchh::int,0)+ coalesce(anz_fa::int,0))   from ans where ans.id=sel.id and dt_tech='1' and dt_down='16' ) ne_dt_dsl_16mbit
--		, (select sum(coalesce(lchh::int,0)+ coalesce(anz_fa::int,0))  from ans where ans.id=sel.id and dt_tech='2' and dt_down='50' ) ne_dt_vdsl_50mbit
--		, (select sum(coalesce(lchh::int,0)+ coalesce(anz_fa::int,0))  from ans where ans.id=sel.id and dt_tech='2' and dt_down='100' ) ne_dt_vdsl_100mbit
--		, (select sum(coalesce(lchh::int,0)+ coalesce(anz_fa::int,0))  from ans where ans.id=sel.id and dt_tech='2' and dt_down='250' ) ne_dt_vdsl_250mbit
--		, (select sum(coalesce(lchh::int,0)+ coalesce(anz_fa::int,0))  from ans where ans.id=sel.id and dt_tech='3' and dt_down='1000' ) ne_dt_gf_1000mbit
--		, (select sum(coalesce(lchh::int,0)+ coalesce(anz_fa::int,0))  from ans where ans.id=sel.id and dt_tech='4' and dt_down='500' ) ne_dt_gf_500mbit
--		, (select sum(coalesce(lchh::int,0)+ coalesce(anz_fa::int,0))  from ans where ans.id=sel.id and kd_tech='1' and kd_down='100' ) ne_kd_100mbit
--		, (select sum(coalesce(lchh::int,0)+ coalesce(anz_fa::int,0))  from ans where ans.id=sel.id and kd_tech='1' and kd_down='200' ) ne_kd_200mbit
--		, (select sum(coalesce(lchh::int,0)+ coalesce(anz_fa::int,0))  from ans where ans.id=sel.id and kd_tech='1' and kd_down='400' ) ne_kd_400mbit
--		, (select sum(coalesce(lchh::int,0)+ coalesce(anz_fa::int,0))  from ans where ans.id=sel.id and kd_tech='1' and kd_down='500' ) ne_kd_500mbit
--		, (select sum(coalesce(lchh::int,0)+ coalesce(anz_fa::int,0))  from ans where ans.id=sel.id and kd_tech='1' and kd_down='1000' ) ne_kd_1000mbit
--		, (select sum(coalesce(lchh::int,0)+ coalesce(anz_fa::int,0))  from ans where ans.id=sel.id and py_down='20' ) ne_py_20
--		, (select sum(coalesce(lchh::int,0)+ coalesce(anz_fa::int,0))  from ans where ans.id=sel.id and py_down='200' ) ne_py_200
--		, (select sum(coalesce(lchh::int,0)+ coalesce(anz_fa::int,0))  from ans where ans.id=sel.id and py_down='400' ) ne_py_400
--		, (select sum(coalesce(lchh::int,0)+ coalesce(anz_fa::int,0))  from ans where ans.id=sel.id and py_down='500' ) ne_py_500
--		, (select sum(coalesce(lchh::int,0)+ coalesce(anz_fa::int,0))  from ans where ans.id=sel.id and py_down='1000' ) ne_py_1000
--		from  potentialanalysen.pop_clusters_stf_2 sel;	

---- with approximate NE   (for buildings with no Ne-Info, we consider 1.8)
create table ans3 as
	select 
		sel.id
		, (select sum(ne_schaetzung)  from ans where ans.id=sel.id and dt_tech='1' and dt_down='16' ) ne_dt_dsl_16mbit
		, (select sum(ne_schaetzung)  from ans where ans.id=sel.id and dt_tech='2' and dt_down='50' ) ne_dt_vdsl_50mbit
		, (select sum(ne_schaetzung)  from ans where ans.id=sel.id and dt_tech='2' and dt_down='100' ) ne_dt_vdsl_100mbit
		, (select sum(ne_schaetzung)  from ans where ans.id=sel.id and dt_tech='2' and dt_down='250' ) ne_dt_vdsl_250mbit
		, (select sum(ne_schaetzung)  from ans where ans.id=sel.id and dt_tech='3' and dt_down='1000' ) ne_dt_gf_1000mbit
		, (select sum(ne_schaetzung)  from ans where ans.id=sel.id and dt_tech='4' and dt_down='500' ) ne_dt_gf_500mbit
		, (select sum(ne_schaetzung)  from ans where ans.id=sel.id and kd_tech='1' and kd_down='100' ) ne_kd_100mbit
		, (select sum(ne_schaetzung)  from ans where ans.id=sel.id and kd_tech='1' and kd_down='200' ) ne_kd_200mbit
		, (select sum(ne_schaetzung)  from ans where ans.id=sel.id and kd_tech='1' and kd_down='400' ) ne_kd_400mbit
		, (select sum(ne_schaetzung)  from ans where ans.id=sel.id and kd_tech='1' and kd_down='500' ) ne_kd_500mbit
		, (select sum(ne_schaetzung)  from ans where ans.id=sel.id and kd_tech='1' and kd_down='1000' ) ne_kd_1000mbit
		, (select sum(ne_schaetzung)  from ans where ans.id=sel.id and py_down='20' ) ne_py_20
		, (select sum(ne_schaetzung)  from ans where ans.id=sel.id and py_down='200' ) ne_py_200
		, (select sum(ne_schaetzung)  from ans where ans.id=sel.id and py_down='400' ) ne_py_400
		, (select sum(ne_schaetzung)  from ans where ans.id=sel.id and py_down='500' ) ne_py_500
		, (select sum(ne_schaetzung)  from ans where ans.id=sel.id and py_down='1000' ) ne_py_1000
		from  potentialanalysen.pop_clusters_stf_2 sel;	

update potentialanalysen.pop_clusters_stf_2 set
		ne_dt_dsl_16mbit = ans3.ne_dt_dsl_16Mbit
		, ne_dt_vdsl_50mbit= ans3.ne_dt_vdsl_50Mbit
		, ne_dt_vdsl_100mbit = ans3.ne_dt_vdsl_100Mbit
		, ne_dt_vdsl_250mbit = ans3.ne_dt_vdsl_250Mbit
		, ne_dt_gf_1000mbit= ans3.ne_dt_gf_1000Mbit
		, ne_dt_gf_500mbit = ans3.ne_dt_gf_500Mbit
		, ne_kd_100mbit= ans3.ne_kd_100Mbit
		, ne_kd_200mbit= ans3.ne_kd_200Mbit
		, ne_kd_400mbit= ans3.ne_kd_400Mbit
		, ne_kd_500mbit= ans3.ne_kd_500Mbit
		, ne_kd_1000mbit = ans3.ne_kd_1000Mbit
		, ne_py_20 = ans3.ne_py_20
		, ne_py_200= ans3.ne_py_200
		, ne_py_400= ans3.ne_py_400
		, ne_py_500= ans3.ne_py_500
		, ne_py_1000 = ans3.ne_py_1000
	from ans3
	where potentialanalysen.pop_clusters_stf_2.id=ans3.id;

--------------         delete temporary objects:      ------------------------------------------------------------------------------------------------------------------------------------
drop table ans;
drop table ans2;
drop table ans3;
drop schema shp cascade;





----- older version. we were using "potentialanalysen.pop_cluster_analysestufe2". 
------Then we decided to create a new table "potentialanalysen.pop_clusters_stf_2"
--
--
--------------------------                      On 3-02-2021
--
----make backup:
--create table potentialanalysen.bk_pop_cluster_analysestufe2 as
--	select  * from potentialanalysen.pop_cluster_analysestufe2;
--
---- Afshin generated shape files from new clusters
--insert into potentialanalysen.pop_cluster_analysestufe2(geom, agg_id, locked, homecount , forced_eq, future_cbl, path, layer)
--	select st_force4d(geom), agg_id, locked, homecount , forced_eq, future_cbl, path,null as layer from "pop_clusters_25832ConvertedTo32"
--	union all 
--	select st_force4d(geom), agg_id, locked, homecount , forced_eq, future_cbl, path, layer from popcluster_25833
--
--alter table potentialanalysen.pop_cluster_analysestufe2 add column py_20 integer;
--alter table potentialanalysen.pop_cluster_analysestufe2 add column py_200 integer;
--alter table potentialanalysen.pop_cluster_analysestufe2 add column py_400 integer;
--alter table potentialanalysen.pop_cluster_analysestufe2 add column py_500 integer;
--alter table potentialanalysen.pop_cluster_analysestufe2 add column py_1000 integer;
--
--create table ans2 as
--	select 
--		sel.id
--		, (select count(*) from ans where ans.id=sel.id and dt_tech='1' and dt_down='16' ) dt_dsl_16Mbit
--		, (select count(*) from ans where ans.id=sel.id and dt_tech='2' and dt_down='50' ) dt_vdsl_50Mbit
--		, (select count(*) from ans where ans.id=sel.id and dt_tech='2' and dt_down='100' ) dt_vdsl_100Mbit
--		, (select count(*) from ans where ans.id=sel.id and dt_tech='2' and dt_down='250' ) dt_vdsl_250Mbit
--		, (select count(*) from ans where ans.id=sel.id and dt_tech='3' and dt_down='1000' ) dt_gf_1000Mbit
--		, (select count(*) from ans where ans.id=sel.id and dt_tech='4' and dt_down='500' ) dt_gf_500Mbit
--		, (select count(*) from ans where ans.id=sel.id and kd_tech='1' and kd_down='100' ) kd_100Mbit
--		, (select count(*) from ans where ans.id=sel.id and kd_tech='1' and kd_down='200' ) kd_200Mbit
--		, (select count(*) from ans where ans.id=sel.id and kd_tech='1' and kd_down='400' ) kd_400Mbit
--		, (select count(*) from ans where ans.id=sel.id and kd_tech='1' and kd_down='500' ) kd_500Mbit
--		, (select count(*) from ans where ans.id=sel.id and kd_tech='1' and kd_down='1000' ) kd_1000Mbit
--		, (select count(*) from ans where ans.id=sel.id and py_down='20' ) py_20
--		, (select count(*) from ans where ans.id=sel.id and py_down='200' ) py_200
--		, (select count(*) from ans where ans.id=sel.id and py_down='400' ) py_400
--		, (select count(*) from ans where ans.id=sel.id and py_down='500' ) py_500
--		, (select count(*) from ans where ans.id=sel.id and py_down='1000' ) py_1000
--		from (
--			select * from potentialanalysen.pop_cluster_analysestufe2                                                      
--		) sel;
--
--update potentialanalysen.pop_cluster_analysestufe2 set
--		"dt_dsl_16Mbit"=ans2.dt_dsl_16Mbit
--		, "dt_vdsl_50Mbit"=ans2.dt_vdsl_50Mbit
--		, "dt_vdsl_100MBit"=ans2.dt_vdsl_100Mbit
--		, "dt_vdsl_250MBit"=ans2.dt_vdsl_250Mbit
--		, "dt_gf_1000MBit"=ans2.dt_gf_1000Mbit
--		, "dt_gf_500Mbit"=ans2.dt_gf_500Mbit
--		, "kd_100Mbit"=ans2.kd_100Mbit
--		, "kd_200MBit"=ans2.kd_200Mbit
--		, "kd_400MBit"=ans2.kd_400Mbit
--		, "kd_500MBit"=ans2.kd_500Mbit
--		, "kd_1000MBit"=ans2.kd_1000Mbit
--		, py_20 =ans2.py_20
--		, py_200 =ans2.py_200
--		, py_400 =ans2.py_400
--		, py_500 =ans2.py_500
--		, py_1000 =ans2.py_1000
--	from ans2
--	where potentialanalysen.pop_cluster_analysestufe2.id=ans2.id
--
--	---   NE 
--
--drop table ans ;
--create table ans as
--	select adr.fid, adr.geom , adr.dt_tech, adr.dt_down, adr.kd_tech, adr.kd_down, pol.id , py_tech, py_down, "lchh", anz_fa from adressen.adressen_nexiga_wgs84 adr join potentialanalysen.pop_cluster_analysestufe2 pol on  st_contains(pol.geom, st_transform(adr.geom, 25833))
--
--alter table  potentialanalysen.pop_cluster_analysestufe2   add column ne_dt_dsl_16mbit       integer ;
--alter table  potentialanalysen.pop_cluster_analysestufe2   add column ne_dt_vdsl_50mbit      integer ;
--alter table  potentialanalysen.pop_cluster_analysestufe2   add column ne_dt_vdsl_100mbit     integer ;
--alter table  potentialanalysen.pop_cluster_analysestufe2   add column ne_dt_vdsl_250mbit     integer ;
--alter table  potentialanalysen.pop_cluster_analysestufe2   add column ne_dt_gf_1000mbit      integer ;
--alter table  potentialanalysen.pop_cluster_analysestufe2   add column ne_dt_gf_500mbit       integer ;
--alter table  potentialanalysen.pop_cluster_analysestufe2   add column ne_kd_100mbit          integer ;
--alter table  potentialanalysen.pop_cluster_analysestufe2   add column ne_kd_200mbit          integer ;
--alter table  potentialanalysen.pop_cluster_analysestufe2   add column ne_kd_400mbit          integer ;
--alter table  potentialanalysen.pop_cluster_analysestufe2   add column ne_kd_500mbit          integer ;
--alter table  potentialanalysen.pop_cluster_analysestufe2   add column ne_kd_1000mbit         integer ;
--alter table  potentialanalysen.pop_cluster_analysestufe2   add column ne_py_20               integer ;   
--alter table  potentialanalysen.pop_cluster_analysestufe2   add column ne_py_200              integer ;  
--alter table  potentialanalysen.pop_cluster_analysestufe2   add column ne_py_400              integer ;  
--alter table  potentialanalysen.pop_cluster_analysestufe2   add column ne_py_500              integer ;  
--alter table  potentialanalysen.pop_cluster_analysestufe2   add column ne_py_1000             integer ;  
--
--create table ans3 as
--	select 
--		sel.id
--		, (select sum(coalesce("lchh"::int,0)+ coalesce(anz_fa::int,0))   from ans where ans.id=sel.id and dt_tech='1' and dt_down='16' ) ne_dt_dsl_16Mbit
--		, (select sum(coalesce("lchh"::int,0)+ coalesce(anz_fa::int,0))  from ans where ans.id=sel.id and dt_tech='2' and dt_down='50' ) ne_dt_vdsl_50Mbit
--		, (select sum(coalesce("lchh"::int,0)+ coalesce(anz_fa::int,0))  from ans where ans.id=sel.id and dt_tech='2' and dt_down='100' ) ne_dt_vdsl_100Mbit
--		, (select sum(coalesce("lchh"::int,0)+ coalesce(anz_fa::int,0))  from ans where ans.id=sel.id and dt_tech='2' and dt_down='250' ) ne_dt_vdsl_250Mbit
--		, (select sum(coalesce("lchh"::int,0)+ coalesce(anz_fa::int,0))  from ans where ans.id=sel.id and dt_tech='3' and dt_down='1000' ) ne_dt_gf_1000Mbit
--		, (select sum(coalesce("lchh"::int,0)+ coalesce(anz_fa::int,0))  from ans where ans.id=sel.id and dt_tech='4' and dt_down='500' ) ne_dt_gf_500Mbit
--		, (select sum(coalesce("lchh"::int,0)+ coalesce(anz_fa::int,0))  from ans where ans.id=sel.id and kd_tech='1' and kd_down='100' ) ne_kd_100Mbit
--		, (select sum(coalesce("lchh"::int,0)+ coalesce(anz_fa::int,0))  from ans where ans.id=sel.id and kd_tech='1' and kd_down='200' ) ne_kd_200Mbit
--		, (select sum(coalesce("lchh"::int,0)+ coalesce(anz_fa::int,0))  from ans where ans.id=sel.id and kd_tech='1' and kd_down='400' ) ne_kd_400Mbit
--		, (select sum(coalesce("lchh"::int,0)+ coalesce(anz_fa::int,0))  from ans where ans.id=sel.id and kd_tech='1' and kd_down='500' ) ne_kd_500Mbit
--		, (select sum(coalesce("lchh"::int,0)+ coalesce(anz_fa::int,0))  from ans where ans.id=sel.id and kd_tech='1' and kd_down='1000' ) ne_kd_1000Mbit
--		, (select sum(coalesce("lchh"::int,0)+ coalesce(anz_fa::int,0))  from ans where ans.id=sel.id and py_down='20' ) ne_py_20
--		, (select sum(coalesce("lchh"::int,0)+ coalesce(anz_fa::int,0))  from ans where ans.id=sel.id and py_down='200' ) ne_py_200
--		, (select sum(coalesce("lchh"::int,0)+ coalesce(anz_fa::int,0))  from ans where ans.id=sel.id and py_down='400' ) ne_py_400
--		, (select sum(coalesce("lchh"::int,0)+ coalesce(anz_fa::int,0))  from ans where ans.id=sel.id and py_down='500' ) ne_py_500
--		, (select sum(coalesce("lchh"::int,0)+ coalesce(anz_fa::int,0))  from ans where ans.id=sel.id and py_down='1000' ) ne_py_1000
--		from (
--			select * from potentialanalysen.pop_cluster_analysestufe2                                                      
--		) sel;	
--		
--update potentialanalysen.pop_cluster_analysestufe2 set
--	ne_dt_dsl_16mbit   = ans3.ne_dt_dsl_16Mbit
--	, ne_dt_vdsl_50mbit  = ans3.ne_dt_vdsl_50Mbit
--	, ne_dt_vdsl_100mbit = ans3.ne_dt_vdsl_100Mbit
--	, ne_dt_vdsl_250mbit = ans3.ne_dt_vdsl_250Mbit
--	, ne_dt_gf_1000mbit  = ans3.ne_dt_gf_1000Mbit
--	, ne_dt_gf_500mbit   = ans3.ne_dt_gf_500Mbit
--	, ne_kd_100mbit      = ans3.ne_kd_100Mbit
--	, ne_kd_200mbit      = ans3.ne_kd_200Mbit
--	, ne_kd_400mbit      = ans3.ne_kd_400Mbit
--	, ne_kd_500mbit      = ans3.ne_kd_500Mbit
--	, ne_kd_1000mbit     = ans3.ne_kd_1000Mbit
--	, ne_py_20           = ans3.ne_py_20
--	, ne_py_200          = ans3.ne_py_200
--	, ne_py_400          = ans3.ne_py_400
--	, ne_py_500          = ans3.ne_py_500
--	, ne_py_1000         = ans3.ne_py_1000
--from ans3
--where potentialanalysen.pop_cluster_analysestufe2.id=ans3.id;
--
--select sum(coalesce("lchh"::int,0)+ coalesce(anz_fa::int,0)) from adressen.adressen_nexiga_wgs84 where   py_tech='1'; --597929
--		
--
--
--
----------------------------------------------------------------------------------------------------------------------------------------------------
--------- join the tables adressen.adressen and adressen.adressen_nexiga_wgs84   DID not Work.!!!!   Too long
-------create table adressen.gis_nexiga_adressen as
-------	select
-------		adr.id,
-------		nex.fid nex_id,
-------		nex.plz||replace(replace(replace( replace(lower(replace(nex.str_name, ' ', '')) , 'straße', 'str') ,'strasse','str') ,'-','' ) || nex.hnr||coalesce(lower(nex.hnr_zs),'')  , '.','') nex_key,
-------		adr.plz|| replace(replace(replace(replace(lower(replace(adr.strasse, ' ', '')) , 'straße', 'str') ,'strasse','str') ,'-', '') || adr.hausnr||coalesce(lower(adr.adresszusatz),''), '.','')  adr_key
-------	from 
-------		adressen.adressen  adr 
-------		join
-------		adressen.adressen_nexiga_wgs84 nex 
-------		on (
-------				(nex.oi is not null and adr.alkis_id is not null and nex.oi=adr.alkis_id)
-------			or
-------				(
-------					(nex.oi is  null or adr.alkis_id is  null  )
-------				and
-------					nex.plz||replace(replace(replace( replace(lower(replace(nex.str_name, ' ', '')) , 'straße', 'str') ,'strasse','str') ,'-','' ) || nex.hnr||coalesce(lower(nex.hnr_zs),'')  , '.','') 
-------					=
-------					adr.plz|| replace(replace(replace(replace(lower(replace(adr.strasse, ' ', '')) , 'straße', 'str') ,'strasse','str') ,'-', '') || adr.hausnr||coalesce(lower(adr.adresszusatz),''), '.','') 
-------				and 
-------					st_distance(st_transform(nex.geom, 4326), adr.geom ,false) < 25
-------				)
-------			);

		