-- 27-01-2021
--task from Michael
-- analyse on adresse nexiga:


database dns_net_geodb;


create table ans as
	select adr.fid, adr.geom , adr.dt_tech, adr.dt_down, adr.kd_tech, adr.kd_down, pol.id from adressen.adressen_nexiga_wgs84 adr join potentialanalysen.pop_cluster_analysestufe2 pol on  st_contains(pol.geom, st_transform(adr.geom, 25833))

	
	
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
	from ans2
	where potentialanalysen.pop_cluster_analysestufe2.id=ans2.id



--------------             -------------------------------------------------------                                     part 2                -------------------------------------------------
-- add column flrst_eigentuemr_gml_id to the new temporary table "temp.adressen_michendorf_nuthetal"

database bb_alkis:

select * from temp.adressen_michendorf_nuthetal
alter table temp.adressen_michendorf_nuthetal add column flrst_eigentuemr integer
alter table temp.adressen_michendorf_nuthetal add column flrst_eigentuemr_gml_id text



create table ans as
	select adr.id adr_id, _ogc_fid_ from temp.adressen_michendorf_nuthetal adr join (select * from zusammenstellungen.dv_flurstueck_eigentuemer where _gemeinde_ like 'Michendorf%' or _gemeinde_ like 'Nuthetal%' )sel
		on adr.alkis_id = ANY(_weistauf_) 
		

update  temp.adressen_michendorf_nuthetal  set flrst_eigentuemr=ans._ogc_fid_
	from ans where ans.adr_id= temp.adressen_michendorf_nuthetal.id
	
update 	temp.adressen_michendorf_nuthetal  set  flrst_eigentuemr_gml_id= sel._gml_id
	from (select * from zusammenstellungen.dv_flurstueck_eigentuemer where _gemeinde_ like 'Michendorf%' or _gemeinde_ like 'Nuthetal%' ) sel
		where flrst_eigentuemr=sel._ogc_fid_



-- rename the columns:
alter table temp.adressen_michendorf_nuthetal add column flstck_gml_id varchar(16);
Update temp.adressen_michendorf_nuthetal set flstck_gml_id=flrst_eigentuemr_gml_id ;

alter table temp.adressen_michendorf_nuthetal  drop column flrst_eigentuemr;
alter table temp.adressen_michendorf_nuthetal drop column flrst_eigentuemr_gml_id;
drop table ans
