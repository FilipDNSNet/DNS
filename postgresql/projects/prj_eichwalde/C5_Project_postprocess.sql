/*This script is run after the data from comsof is imported to Model_A.
it has some sample values for some columns, e.g. labels.

Prerequisite:
	- C4_Project_intermediate_2_Model_A.sql
	
15-10-2020*/


/*feeding the labels of the knoten*/
update prj_test_eichwalde.knoten  set label_prefix = 
	CASE WHEN subtyp IN ('POP', 'Backbone-Ubergabepunkt') then 'P'
		WHEN subtyp='Mini-POP/MFG' then 'M'
		WHEN subtyp='GF_NVT' then 'N'
		WHEN subtyp='KVZ' then 'C'
		WHEN subtyp='Abschlusspunkt' then 'H'
		WHEN subtyp='Ziehschacht / Schacht an grossen Knotenpunkten' then 'S'
		ELSE 'L' END || (select onb_onkz from _cluster where id= cluster) ||'/' ;

update prj_test_eichwalde.knoten t set label_wert=(select label_2 from(
	select id, CASE WHEN label_prefix like 'P%' THEN right((100000+num)::text,2)
					WHEN label_prefix like 'M%' THEN right((100000+num)::text,2)
					WHEN label_prefix like 'N%' THEN right((100000+num)::text,3)
					WHEN label_prefix like 'C%' THEN right((100000+num)::text,3)
					WHEN label_prefix like 'H%' THEN right((100000+num)::text,5)
					WHEN label_prefix like 'S%' THEN right((100000+num)::text,4)
					WHEN label_prefix like 'L%' THEN right((1000000+num)::text,6)
				END AS label_2
	from (SELECT id, label_prefix , row_number() OVER (PARTITION BY label_prefix) as num  from prj_test_eichwalde.knoten) sel
	)	as sel2 where t.id=sel2.id
) ;
update prj_test_eichwalde.knoten set bez=label_prefix||label_wert;


/*Update Rohr Farbe*/
update prj_test_eichwalde.rohr set mantel_farbe='sw' where typ='Rohrverband' and anzahl_microducts=24;
update prj_test_eichwalde.rohr set mantel_farbe='or' where typ='Rohrverband' and anzahl_microducts=12;
update prj_test_eichwalde.rohr set mantel_farbe='gn' where typ='Rohrverband' and anzahl_microducts=4;
update prj_test_eichwalde.rohr set mantel_farbe='rs' where typ='Einzelrohr';




 /*update produkt info*/
update prj_test_eichwalde.kabel set produkt_id = (select produkt from pr_kabel where id=1) where anzahl_fasern=144 and netzebene = 'Haupt-Ebene';
update prj_test_eichwalde.kabel set produkt_id = (select produkt from pr_kabel where id=2) where anzahl_fasern=48 and netzebene in ( 'Verteiler-Ebene', 'Verteiler/Drop');
update prj_test_eichwalde.kabel set produkt_id = (select produkt from pr_kabel where id=3) where anzahl_fasern=24 and netzebene in ( 'Verteiler-Ebene', 'Verteiler/Drop');
update prj_test_eichwalde.kabel set produkt_id = (select produkt from pr_kabel where id=4) where anzahl_fasern=12 and netzebene in ( 'Verteiler-Ebene', 'Verteiler/Drop');

update prj_test_eichwalde.rohr set produkt_id= (select produkt from pr_rohr where id=1) where anzahl_microducts = 4 and netzebene='Haupt-Ebene';
update prj_test_eichwalde.rohr set produkt_id= (select produkt from pr_rohr where id=2) where anzahl_microducts = 24 and netzebene in ('Verteiler-Ebene', 'Haupt-Verteiler-Ebene', 'Verteiler/Drop');
update prj_test_eichwalde.rohr set produkt_id= (select produkt from pr_rohr where id=3) where anzahl_microducts = 12 and netzebene in ('Verteiler-Ebene', 'Haupt-Verteiler-Ebene', 'Verteiler/Drop');
update prj_test_eichwalde.rohr set produkt_id= (select produkt from pr_rohr where id=4) where anzahl_microducts = 1 and netzebene in ('Verteiler-Ebene', 'Haupt-Verteiler-Ebene', 'Verteiler/Drop');

update prj_test_eichwalde.knoten set produkt_id = 'FTTH Abschlu??box AP (unbest??ckt) Typ M' where subtyp = 'Abschlusspunkt';
update prj_test_eichwalde.connection_module set produkt_id = 'FTTH Abschlu??box AP (unbest??ckt) Typ M' where netzebene_ziel = 'In-House-Ebene' ;
update prj_test_eichwalde.connection_unit set produkt_id = 'FTTH Abschlu??box AP (unbest??ckt) Typ M' where conn_module_id in (select id from prj_test_eichwalde.connection_module where produkt_id = 'FTTH Abschlu??box AP (unbest??ckt) Typ M') ;
update prj_test_eichwalde.connection_element set produkt_id = 'FTTH Abschlu??box AP (unbest??ckt) Typ M' where conn_unit_id in (select id from prj_test_eichwalde.connection_unit where produkt_id = 'FTTH Abschlu??box AP (unbest??ckt) Typ M') ;



update  prj_test_eichwalde.rohr set bez = (select nam from 
	(select id, case when typ='Rohrverband' then 'MRV' when typ='Einzelrohr' then'ER' end||(select onb_onkz from _cluster where cluster =_cluster.id)||'/'|| right((100000+row_number() over (order by id))::text,5) nam from prj_test_eichwalde.rohr) sel
	where sel.id= prj_test_eichwalde.rohr.id);

update prj_test_eichwalde.microduct set bez = (select bez from prj_test_eichwalde.rohr r where r.id=rohr_id )||'/'||right((microduct_nr+100)::text,2);


*************************************************
with recursive tr AS(
select id, rohr_id from prj_test_eichwalde.microduct where rohr_id=uuid('d1f20016-6bc3-48b3-a90d-117809eff86f')
union
select m.id, m.rohr_id  from prj_test_eichwalde.microduct m inner join tr on tr.id=m.stammt_von
)
select * from tr





-- Rohr and its child:

-- with recursive tr AS(
-- 	select id, rohr_id, stammt_von , NULL::int rohr_father from comsof.microduct where rohr_uuid=uuid('d1f20016-6bc3-48b3-a90d-117809eff86f')
-- union
-- 	select m.id, m.rohr_id, m.stammt_von, tr.rohr_id from comsof.microduct m inner join tr on tr.id=m.stammt_von
-- )
-- select distinct rohr_id, rohr_father from tr
-- 
-- 
-- with recursive tr AS(
-- 	select id, rohr_id, stammt_von , NULL::int rohr_father from comsof.microduct where knoten_anfang_uuid=uuid('d0f0002f-95c6-4f5f-83f7-4bf5ee5e744c')
-- union
-- 	select m.id, m.rohr_id, m.stammt_von, tr.rohr_id from comsof.microduct m inner join tr on tr.id=m.stammt_von
-- )
-- select distinct rohr_id, rohr_father from tr order by rohr_father