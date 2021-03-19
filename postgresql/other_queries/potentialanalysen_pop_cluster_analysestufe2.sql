
--------------         create table : potentialanalysen.pop_cluster_analysestufe2    ------------------------------------------------------------------------------------------------------------------------------------


--17.03.2021  after manual changes on the polygons


-- drop table if exists potentialanalysen.pop_cluster_analysestufe2;
create table potentialanalysen.pop_cluster_analysestufe2 (
	id serial primary key
	, ninox_nr integer
	, geom geometry(MultiPOLYGON, 4326)
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
	
	--,geom_m geometry(geometry, 4326)
	);
create unique index uix_pop_cluster_analysestufe2_ninox_nr on potentialanalysen.pop_cluster_analysestufe2 (ninox_nr);
Create index inx_pop_cluster_analysestufe2_geom on potentialanalysen.pop_cluster_analysestufe2 using GIST(geom);
--Create index inx_pop_cluster_analysestufe2_geom_m on potentialanalysen.pop_cluster_analysestufe2 using GIST(geom_m);

--------------         feed "potentialanalysen.pop_cluster_analysestufe2" from shapefiles    ------------------------------------------------------------------------------------------------------------------------------------
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
	Execute('	insert into potentialanalysen.pop_cluster_analysestufe2  (ninox_nr, geom,   homecount )
		select (right($1,-2))::int, st_multi(st_union(st_transform(geom,4326))) ,      sum(homecount) homecount 
		  from shp."'||t||'";') using t; 
   
--	Execute('	insert into potentialanalysen.pop_cluster_analysestufe2  (ninox_nr, geom, agg_id,  locked, homecount, forced_eq, future_cbl)
--		select (right($1,-2))::int,st_transform(st_geometryn(geom,1),4326) , agg_id,  locked, homecount, forced_eq, future_cbl  from shp."'||t||'";') using t;
  end loop;
end;
$$ language plpgsql;



--------------         udapte some columns of potentialanalysen.pop_cluster_analysestufe2     ------------------------------------------------------------------------------------------------------------------------------------

drop table if exists ans ;
create table ans as
	select adr.fid, adr.geom , adr.dt_tech, adr.dt_down, adr.kd_tech, adr.kd_down , py_tech, py_down, lchh, anz_fa , pol.id , adr.ne_schaetzung
	from adressen.adressen_nexiga_wgs84 adr join potentialanalysen.pop_cluster_analysestufe2 pol 
		on  st_contains(pol.geom, st_transform(adr.geom, 4326));

create index inx_ans_temp_id on ans(id);

--alter table potentialanalysen.pop_cluster_analysestufe2 drop column geom_m;

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
		from  potentialanalysen.pop_cluster_analysestufe2 sel;                                                   

update potentialanalysen.pop_cluster_analysestufe2 set
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
	where potentialanalysen.pop_cluster_analysestufe2.id=ans2.id;
	
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
--		from  potentialanalysen.pop_cluster_analysestufe2 sel;	

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
		from  potentialanalysen.pop_cluster_analysestufe2 sel;	

update potentialanalysen.pop_cluster_analysestufe2 set
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
	where potentialanalysen.pop_cluster_analysestufe2.id=ans3.id;

--------------         delete temporary objects:      ------------------------------------------------------------------------------------------------------------------------------------
drop table ans;
drop table ans2;
drop table ans3;
drop schema shp cascade;



