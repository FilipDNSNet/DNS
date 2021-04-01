create schema if not exists prj_schoenow_and;

INSERT INTO _cluster(id,cluster_name, project_name, cluster_parent, onb_onkz, gemeindeschluessel, zubringerpunkt, version, beschreibung, crs_epsg, schema_name)
	values(15,'Schoenow', '628', 4, '3338','{12060020}', 'A_150','v_01', 'FTTx Test in Schoenow:  AND-Solution', '25833','prj_schoenow_and');


DELETE FROM comsof.comsof_metadata; -- it Also drops the tables with "Out_" and "in_" prifix from comsof.

---- Feeding Metadata
insert into comsof.comsof_metadata( 	datum,	 	bundesland,	 	_epsg_code, 			destination_cluster, 	beschreibung) 
							values( 	now(), 		'Brandenburg', 	25833,					15,						'Schönow_AND-Solutions');




create table prj_schoenow_and.report(
		id text,
		plz text,
		ort text,
		strasse text,
		nr text,
		kunde text,
		phone text,
		email text,
		vertrag text,
		gee text,
		storno text,
		ha text,
		termin text,
		bemerkung text,
		trasse text,
		kabel text,
		am_netz text,
		geschwenkt text,
		port text,
		kvz text,
		nvt text,
		splitter text,
		rohr text,
		farbe text,
		stoerung_bem text,
		sto_behoben text
	);
	
\copy prj_schoenow_and.report from 'C:\Users\Hamed Sayidi\Desktop\Schoenow\out.csv' WITh Delimiter ';' csv Header;

alter table prj_schoenow_and.report add column vid text;
alter table prj_schoenow_and.report add column oid bigserial;
alter table prj_schoenow_and.report add column ky text;
alter table prj_schoenow_and.report add column microduct_nr integer;
alter table prj_schoenow_and.report add constraint pk_prj_schoenow_and_report primary key(oid);
alter table prj_schoenow_and.report drop column kunde;
alter table prj_schoenow_and.report drop column email;
alter table prj_schoenow_and.report drop column phone;
create index inx_prj_schoenow_and_report_plz on prj_schoenow_and.report(plz);
create index inx_prj_schoenow_and_report_strasse on prj_schoenow_and.report(strasse);
create index inx_prj_schoenow_and_report_ort on prj_schoenow_and.report(ort);
create index inx_prj_schoenow_and_report_nr on prj_schoenow_and.report(nr);
create index inx_prj_schoenow_and_report_ky on prj_schoenow_and.report(ky);
create index inx_prj_schoenow_and_report_rohr on prj_schoenow_and.report(rohr);
create index inx_prj_schoenow_and_report_farbe on prj_schoenow_and.report(farbe);

update prj_schoenow_and.report set nvt=Null where nvt='ohne';
update prj_schoenow_and.report set vid=split_part(id,'.',1);
update prj_schoenow_and.report set microduct_nr=dns_getcode_from_color(case when split_part(farbe,'-',2)='' then farbe else split_part(farbe,'-',2)||'+' end);

select 
	null::bigint id,
	split_part(id,'.',1) vid,
	id _vid,
	plz,
	ort,
	strasse,
	nr,
	null::text ky,
	vertrag,
	gee,
	storno,
	ha,
	trasse,
	kabel,
	am_netz,
	geschwenkt,
	port,
	kvz,
	nvt,
	splitter,
	rohr,
	farbe,
	stoerung_bem,
	sto_behoben
	from prj_schoenow_and.report order by plz, ort, strasse, nr;
	
----------------------------------------------------------------------------------------------------------------------------------
--  adresse matching and update vid 







CREATE OR REPLACE FUNCTION dns_adress_mathc_key_generator( plz TEXT,strasse TEXT, nr TEXT, zusatz TEXT DEFAULT '' , ort TEXT DEFAULT '') RETURNS TEXT AS $$
DECLARE 
	-- thiss function receives the strasse , ... and generate the key that for th address that can be used for matching.
	-- example:
	----    select dns_adress_mathc_key_generator('00000','A-BStraße', '1', 'B','Schönow'); --> schönow00000abstr1b
	----    select dns_adress_mathc_key_generator('00000','A-BStraße','1'); --> 00000abstr1
	----    select dns_adress_mathc_key_generator('00000',null,'1'); --> 000001
	ret TEXT;
	ky_plz TEXT;
	ky_strasse TEXT;
	ky_nr TEXT;
	ky_ort TEXT;
	
BEGIN
	--'.',' ','_', '-', 'straße', 'strasse'
	
	select  coalesce(plz,'' ) into ky_plz;
	select 
		replace(
			replace(
				replace(
					replace(
						replace(
							replace(
								replace ( 
									lower( coalesce(strasse,'') ) 
									,'straße', 'str'
								)
								,'strasse', 'str'
							)
							,'-', ''
						)
						,'.', ''
					)
					,',' , ''
				)
				,'_', ''
			)
			,' ', ''
		) into ky_strasse;
	
	select 
		replace(
			replace(
				replace(
					replace(
						replace(
							lower(
								coalesce(nr,'') || coalesce(zusatz, '')
							)
							,'-', ''
						)
						,'.', ''
					)
					,',' , ''
				)
				,'_', ''
			)
			,' ', ''
		) into ky_nr;
	
	select 
		replace(
			replace(
				replace(
					replace(
						replace(
							lower(
								coalesce(ort,'')
							)
							,'-', ''
						)
						,'.', ''
					)
					,',' , ''
				)
				,'_', ''
			)
			,' ', ''
		) into ky_ort;
	
	return ky_ort || ky_plz || ky_strasse || ky_nr ;
		
	
END ;
$$ Language PLPGSQL;






update prj_schoenow_and.report set ky=dns_adress_mathc_key_generator(plz,strasse, nr);
alter table prj_schoenow_and.report add column ky_without_plz text;
update prj_schoenow_and.report set ky_without_plz=dns_adress_mathc_key_generator('',strasse, nr);






CREATE OR REPLACE FUNCTION dns_getcode_from_color(color text, standard text) return integer as $$
DECLARE
	flag boolean;
BEGIN
	SELECT EXISTS (	
		SELECT FROM information_schema.tables 
		WHERE  table_schema = 'public'
		AND    table_name   = '_farbcode'
		) INTO flag;
	if falg Then
		return (select code from _farbcode where lower(farbe)=lower(color) and lower(_farbcode.standard=standard));
	else
		RETURN null;
	END;
END;
$$ LANGUAGE PLPGSQL;



------------------------------------------------------------------------

create table t1 as 
	select * from adressen.adressen adr where adr.amtname = 'Bernau bei Berlin' or ortsteil='Schönow' or ortsteil='Schmetzdorf';
	
	
alter table t1 add column ky text;
create index inx_t1_id on t1(id);
create index inx_t1_vid on t1(vid);
create index inx_t1_alkisid on t1(alkis_id);
create index inx_t1_ky on t1(ky);
update t1 set ky=dns_adress_mathc_key_generator(plz,strasse,hausnr,adresszusatz);

alter table t1 add column ky_without_plz text;
create index inx_t1_ky_without_plz on t1(ky_without_plz);
update t1 set ky_without_plz=dns_adress_mathc_key_generator('',strasse,hausnr,adresszusatz);





------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	
-- mtching with adresses

select id from adressen.adressen where id in 


select t1.id , t1.vid, rep.vid from prj_schoenow_and.report rep  join t1 on (t1.ky=rep.ky or t1.vid=rep.vid) --1837

select distinct ky from prj_schoenow_and.report rep --1875 :total adresses

select t1.id , t1.vid, rep.vid from prj_schoenow_and.report rep  join t1 on (t1.ky=rep.ky or t1.vid=rep.vid) --1837 :matched adresses:	







-- insert aadresses as abschluss points:


insert into prj_schoenow_and.knoten (
		label_wert,
		typ,
		subtyp,
		label_prefix, -- N for NVT, H for Hausanschluss .....
		cluster)
	select
		distinct ky label_wert,   ---- <==> connection to prj_schoenow_and.report: adresses
		'Gebaeude' as  typ,
		'Abschlusspunkt' as subtyp,
		'H' as label_prefix,
		(select destination_cluster from comsof.comsof_metadata) as cluster
		from prj_schoenow_and.report ;

update prj_schoenow_and.knoten set bez=sel.vid from prj_schoenow_and.report sel where sel.ky=label_wert;
update prj_schoenow_and.knoten set bez=label_prefix||bez;		 
		
		

----------------------------------------------------------------------------------------
--                                        MANUAL   : hard coded
-----------   pop
insert into prj_schoenow_and.knoten (
		typ,
		subtyp,
		label_prefix, -- N for NVT, H for Hausanschluss .....
		label_wert,
		cluster)
	select
		'Gebaeude' as  typ,
		'POP' as subtyp,
		'P' as label_prefix,
		'01' as label_wert,
		(select destination_cluster from comsof.comsof_metadata) as cluster;

Update prj_schoenow_and.knoten set bez = label_prefix||label_wert where label_prefix='P';

---   KVZ:
insert into prj_schoenow_and.knoten (
		bez,
		typ,
		subtyp,
		label_prefix, -- N for NVT, H for Hausanschluss .....
		label_wert,
		cluster)
	select
		'KVZ01_1' bez,
		'Kabinet' as  typ,
		'KVZ' as subtyp,
		'K' as label_prefix,
		'01_1' as label_wert,
		(select destination_cluster from comsof.comsof_metadata) as cluster;

insert into prj_schoenow_and.knoten (
		bez,
		typ,
		subtyp,
		label_prefix, -- N for NVT, H for Hausanschluss .....
		label_wert,
		cluster)
	select
		'KVZ01_2' bez,
		'Kabinet' as  typ,
		'KVZ' as subtyp,
		'K' as label_prefix,
		'01_2' as label_wert,
		(select destination_cluster from comsof.comsof_metadata) as cluster;

		
---  
		
		
---  nvt and MFG

select distinct nvt from prj_schoenow_and.report
		
insert into prj_schoenow_and.knoten (
		label_wert,
		typ,
		subtyp,
		label_prefix, -- N for NVT, H for Hausanschluss .....
		cluster)
	select
		distinct nvt label_wert,   ---- <==> connection to prj_schoenow_and.report: adresses
		'Schacht' as  typ,
		'GF_NVT' as subtyp,
		'N01-' as label_prefix,
		(select destination_cluster from comsof.comsof_metadata) as cluster
		from prj_schoenow_and.report where nvt is not null ;		
		

update  prj_schoenow_and.knoten  set  bez=(
	select case when lower(label_wert) like 'mfg%' then label_wert else label_prefix||'01-'||right((label_wert::int+100000)::text ,3) end
) where label_prefix='N';





----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- abschlusspunkte

insert into prj_schoenow_and.abschlusspunkte (knoten_id, typ, cluster )
	select 
		id knoten_id,
		'Gf-HUEP' typ,
		(select destination_cluster from comsof.comsof_metadata) as cluster
	from prj_schoenow_and.knoten where subtyp='Abschlusspunkt';

---- Duplication in VID:
-- select ky , count(ky) cnt from (
-- 	select distinct ky , vid from prj_schoenow_and.report rep 
-- ) sel group by ky order by cnt desc
--	rep.ky='16321mittelstr77'
--		398573.1	
--		397895.1	
--		
--
--
--	'16321waldstr16'
--		397914.1
--		397913.1
--
--	'16321gerharthauptmannstr38'
--		398484.p1
--		398483.1
--
--	'16321bernauerallee1'
--		395795.1
--		395916.p4
--		395916.p3
--		395916.p2
--		395916.p1
--
--	'16321fritzreuterstr23'
--		398421.p1
--		398420.1
--
--------------
----  Fix temporary
--update prj_schoenow_and.report rep set vid= 397895	where id= '398573.1';
--
--update prj_schoenow_and.report rep set vid= 397913	where id= '397914.1';
--
--update prj_schoenow_and.report rep set vid= 395795	where id in ('395916.p4', '395916.p3', '395916.p2', '395916.p1');
--
--update prj_schoenow_and.report rep set vid= 398483	where id= '398484.p1';
--
--update prj_schoenow_and.report rep set vid= 398420	where id= '398421.p1';
--
---- Or DELETE: (NOT sure if we should delete)
-- delete 	from prj_schoenow_and.report rep where id= '398573.1';
-- 
-- delete 	from prj_schoenow_and.report rep where id= '397914.1';
-- 
-- delete 	from prj_schoenow_and.report rep  where id in ('395916.p4', '395916.p3', '395916.p2', '395916.p1');
-- 
-- delete 	from prj_schoenow_and.report rep where id= '398484.p1';
-- 
-- delete 	from prj_schoenow_and.report rep where id= '398421.p1';

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- adresse_abschluss
insert into prj_schoenow_and.adresse_abschluss (adresse_id,abschlusspunkte_id, cluster)
	select t1.id , ab.id abschluss_id, (select destination_cluster from comsof.comsof_metadata)
		from (select distinct ky, vid  from prj_schoenow_and.report) rep  
			join t1 on (t1.ky=rep.ky or t1.vid=rep.vid) --1722 :matched adresses:	
			join 
			prj_schoenow_and.knoten kn on rep.ky=kn.label_wert
			join 
			prj_schoenow_and.abschlusspunkte ab on ab.knoten_id=kn.id;

select * from prj_schoenow_and.adresse_abschluss; --1722


----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Rohr
insert into prj_schoenow_and.rohr(bez, typ, anzahl_microducts, mantel_farbe, planung_status, netzebene, cluster)
	select 	bez,
			'Rohrverband' typ,  
			substring( (regexp_split_to_array(bez, '[0-9]/'))[2] from '\s*[0-9]+')::int as anzahl_microducts, --anzahl_microducts
			--(regexp_split_to_array(bez, '[0-9]+x[0-9]+'))[2] as mantel_farbe ,-- mantel_farbe
			case when (regexp_split_to_array(bez, '[0-9]+x[0-9]+'))[2] ='' then null else (regexp_split_to_array(bez, '[0-9]+x[0-9]+'))[2] end as mantel_farbe ,-- mantel_farbe 
			--case when split_part((regexp_split_to_array(bez, '[0-9]+x[0-9]+'))[2],'/',2)='' then (regexp_split_to_array(bez, '[0-9]+x[0-9]+'))[2] else split_part((regexp_split_to_array(bez, '[0-9]+x[0-9]+'))[2],'/',2)||'+' end farbe_mantel,
			'Ausfuehrungsplanung' as plaung_status , -- plaung_status
			'Verteiler-Ebene' as netzebene, -- netzebene
			(select destination_cluster from comsof.comsof_metadata) as cluster-- cluster
		from (
			select  distinct replace(rohr,' ','') bez from prj_schoenow_and.report where rohr is not null and rohr not in  ('ohne', '????') --195
		) sel

-- We do not care about leer microucts and we do not impoprt them. 


--Microducts:
insert into prj_schoenow_and.microduct(bez, rohr_id, microduct_nr, knoten_anfang, bottom_agg_id, netzebene, cluster)
	select 
		replace(rohr,' ','')||'/'||microduct_nr::text bez,
		(select id from prj_schoenow_and.rohr where bez = replace(rohr,' ','')) as rohr_id,
		microduct_nr,
		(select id from prj_schoenow_and.knoten where label_wert=nvt) as knoten_andfang,
		vid as bottom_agg_id,
		'Verteiler-Ebene' as netzebene, -- netzebene
		(select destination_cluster from comsof.comsof_metadata) as cluster-- cluster
	from prj_schoenow_and.report  where rohr is not null and rohr not in  ('ohne', '????') and microduct_nr is not null order by bez, microduct_nr;


-- create virtual abzweigungen
insert into prj_schoenow_and.knoten (id, label_prefix, bez,  typ , subtyp , planung_status, foerdert_status, cluster)
	select  dns_netzwerk_uuid('knoten') , id as label_prefix, 'Abzweigung_virtual' as bezei,   'Lage', 'Lage, zugaenglich mit einem Kugelmarker', 'Ausfuehrungsplanung',Null , (select destination_cluster from comsof.comsof_metadata)  from prj_schoenow_and.microduct;
	
update 	prj_schoenow_and.microduct set knoten_ende=(select kn.id from prj_schoenow_and.knoten kn  where kn.label_prefix=prj_schoenow_and.microduct.id::text);






----------------------------------------------------------------------------------------------------------------------------------------------------------------------
----- Einzelrohr
insert into prj_schoenow_and.rohr(bez, typ, anzahl_microducts, mantel_farbe, mantel_label, planung_status, netzebene, cluster)
	select 	'ER-01'||nvt||'-'||vid as bez,
			'Einzelrohr' typ,  
			1 as anzahl_microducts, --anzahl_microducts
			'rs' as mantel_farbe ,-- mantel_farbe 
			vid as mantel_label,
			'Ausfuehrungsplanung' as plaung_status , -- plaung_status
			'Verteiler/Drop' as netzebene, -- netzebene
			(select destination_cluster from comsof.comsof_metadata) as cluster-- cluster
		from (
			select  nvt,  vid  from prj_schoenow_and.report where rohr is not null and rohr not in  ('ohne', '????') --1942
		) sel



-- insert into prj_schoenow_and.microduct(bez, rohr_id, microduct_nr, knoten_anfang, bottom_agg_id, netzebene, cluster)
-- 	select 
-- 		bez,
-- 		id rohr_id,
-- 		1,
-- 		(select knoten_ende from prj_schoenow_and.microduct mc where mc.id::text=mantel_label)  as knoten_andfang,
-- 		(select bottom_agg_id from prj_schoenow_and.microduct mc where mc.id::text=mantel_label) as bottom_agg_id,
-- 		--mantel_label as bottom_agg_id,
-- 		'Verteiler/Drop' as netzebene, -- netzebene
-- 		cluster-- cluster
--  	from prj_schoenow_and.rohr  where typ= 'Einzelrohr';
-- 


insert into prj_schoenow_and.microduct(bez, rohr_id, microduct_nr, knoten_anfang, knoten_ende, bottom_agg_id, netzebene, cluster)
	select 
		bez,
		id rohr_id,
		1,
		(select knoten_ende from prj_schoenow_and.microduct mc where mc.id::text=mantel_label)  as knoten_andfang,
		(select id from prj_schoenow_and.knoten kn where kn.bez='H'||(select bottom_agg_id from prj_schoenow_and.microduct mc where mc.id::text=mantel_label) limit 1) as knoten_ende,
		(select bottom_agg_id from prj_schoenow_and.microduct mc where mc.id::text=mantel_label) as bottom_agg_id,
		--mantel_label as bottom_agg_id,
		'Verteiler/Drop' as netzebene, -- netzebene
		cluster-- cluster
 	from prj_schoenow_and.rohr  where typ= 'Einzelrohr';



update prj_schoenow_and.microduct set bottom_agg_id=(select id::text from  prj_schoenow_and.knoten kn where kn.bez='H'||bottom_agg_id limit 1);


----------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Problems:
	-- limit 1    
	-- null vid  (create artificial vids)


select dns_get_rohr_verbindung(uuid('d0f00068-9306-4b38-acc0-416c7fb6c1d5'), 'prj_schoenow_and')--vid 395981
select dns_get_rohr_verbindung(uuid('d0f000c3-31db-4630-83d6-8afca7792b00'), 'prj_schoenow_and')--vid 395816
select dns_get_rohr_verbindung(uuid('d0f00046-5f52-4a8d-9f91-2cf17b2d606c'), 'prj_schoenow_and')-- vid 397853



-----------------  update Adresse_Abschluss




update adressen.adresse_abschluss set _abschluss_id = sel.abschlusspunkte_id , cluster=sel.cluster from (
		select adresse_id , abschlusspunkte_id, cluster from prj_schoenow_and.adresse_abschluss
	) sel where _adresse_id=sel.adresse_id;


select * from adressen.adresse_abschluss where _adresse_id in (
	select id from adressen.adressen adr where adr.amtname = 'Bernau bei Berlin' or ortsteil='Schönow' or ortsteil='Schmetzdorf'
	);






	