/*This script is run after the data from comsof is imported to Model_A.
it has some sample values for some columns, e.g. labels.

Prerequisite:
	- C3_Project_intemediate Feeding.sql
	
17-03-2021*/


-- knoten label prefix:
update comsof.knoten set label_prefix=
	case
		when subtyp='Backbone-Uebergabepunkt' Then 'P'
		when subtyp='POP' THEN 'P'
		when subtyp='Mini-POP/MFG' THEN 'M'
		when subtyp='GF_NVT' THEN 'N'
		when subtyp='KVZ' THEN 'N'
		when subtyp='Abschlusspunkt' THEN 'H'
		when subtyp='Ziehschacht / Schacht an grossen Knotenpunkten' THEN 'S'
	end || (select onb_onkz from _cluster where id = (select distinct cluster from comsof.knoten))::text;

-- knoten vid for anschluss punkte:
update comsof.knoten kn set label_wert=  '01.'||sel.vid::text 
from (
		select ind.vid, addab.abschlusspunkte_uuid, ab.knoten_uuid from comsof.in_demandpoints ind join comsof.adresse_abschluss  addab on addab.adresse_id=uuid(ind._id) join comsof.abschlusspunkte ab on ab.uuid=addab.abschlusspunkte_uuid
	) sel
where sel.knoten_uuid = kn.uuid;

--fro nvt and pop annd schacht => manually
update comsof.knoten set bez= label_prefix||'/'||label_wert
	where  label_prefix is not null and typ is not null;







update comsof.knoten set bez='M33200/02' where subtyp='POP';





	--								update comsof.knoten set bez prefix and wert where subtyp='GF_NVT'   => manually 




--
--update comsof.knoten set label_prefix='H33200/'||sel.knot_source_label_wert from (
--	select sel_4.* , (select label_wert from comsof.knoten where uuid=sel_4.knoten_id_module_anf) knot_source_label_wert from (
--		select sel_3.*, (select knoten_uuid from comsof.connection_module where uuid=sel_3.con_modul_anf ) knoten_id_module_anf  from(
--			select sel_2.*, (select uuid from comsof.kabel  where conn_module_ende_uuid=sel_2.con_modul_end) kabel_id, (select conn_module_anfang_uuid from comsof.kabel  where conn_module_ende_uuid=sel_2.con_modul_end) con_modul_anf from(
--				select sel_1.* , (select uuid from comsof.connection_module where knoten_uuid= sel_1.uuid) con_modul_end from(
--					select *  from comsof.knoten where subtyp='Abschlusspunkt'
--				) sel_1
--			) sel_2
--		)sel_3
--	) sel_4
--)sel where sel. uuid=comsof.knoten.uuid;
--
--update comsof.knoten set label_wert= sel.vid from(
--	select ad_ab.adresse_id, ad_ab.abschlusspunkte_uuid, adr.vid,  ab.knoten_uuid from 
--		(select adresse_id,  abschlusspunkte_uuid from comsof.adresse_abschluss) ad_ab
--		join
--		(select id, vid from adressen.adressen ) adr
--			on adr.id=ad_ab.adresse_id
--		join
--		comsof.abschlusspunkte ab
--			on ab.uuid=ad_ab.abschlusspunkte_uuid
--) sel where sel.knoten_uuid= comsof.knoten .uuid;
--
--update comsof.knoten set bez= label_prefix||'.'||label_wert
--	where subtyp='Abschlusspunkt';
--





















/*Update Rohr Farbe*/
update comsof.rohr set mantel_farbe='sw' where typ='Rohrverband' and anzahl_microducts=24;
update comsof.rohr set mantel_farbe='or' where typ='Rohrverband' and anzahl_microducts=12;
update comsof.rohr set mantel_farbe='gn' where typ='Rohrverband' and anzahl_microducts=4;
update comsof.rohr set mantel_farbe='rs' where typ='Einzelrohr';




 /*update produkt info*/
update comsof.kabel set produkt_id = (select produkt from pr_kabel where id=1) where anzahl_fasern=144 and netzebene = 'Haupt-Ebene';
update comsof.kabel set produkt_id = (select produkt from pr_kabel where id=2) where anzahl_fasern=48 and netzebene in ( 'Verteiler-Ebene', 'Verteiler/Drop');
update comsof.kabel set produkt_id = (select produkt from pr_kabel where id=3) where anzahl_fasern=24 and netzebene in ( 'Verteiler-Ebene', 'Verteiler/Drop');
update comsof.kabel set produkt_id = (select produkt from pr_kabel where id=4) where anzahl_fasern=12 and netzebene in ( 'Verteiler-Ebene', 'Verteiler/Drop');

update comsof.rohr set produkt_id= (select produkt from pr_rohr where id=1) where anzahl_microducts = 4 and netzebene='Haupt-Ebene';
update comsof.rohr set produkt_id= (select produkt from pr_rohr where id=2) where anzahl_microducts = 24 and netzebene in ('Verteiler-Ebene', 'Haupt-Verteiler-Ebene', 'Verteiler/Drop');
update comsof.rohr set produkt_id= (select produkt from pr_rohr where id=3) where anzahl_microducts = 12 and netzebene in ('Verteiler-Ebene', 'Haupt-Verteiler-Ebene', 'Verteiler/Drop');
update comsof.rohr set produkt_id= (select produkt from pr_rohr where id=4) where anzahl_microducts = 1 and netzebene in ('Verteiler-Ebene', 'Haupt-Verteiler-Ebene', 'Verteiler/Drop');

update comsof.knoten set produkt_id = 'FTTH Abschlußbox AP (unbestückt) Typ M' where subtyp = 'Abschlusspunkt';
update comsof.connection_module set produkt_id = 'FTTH Abschlußbox AP (unbestückt) Typ M' where netzebene_ziel = 'In-House-Ebene' ;
update comsof.connection_unit set produkt_id = 'FTTH Abschlußbox AP (unbestückt) Typ M' where conn_module_id in (select id from comsof.connection_module where produkt_id = 'FTTH Abschlußbox AP (unbestückt) Typ M') ;
update comsof.connection_element set produkt_id = 'FTTH Abschlußbox AP (unbestückt) Typ M' where conn_unit_id in (select id from comsof.connection_unit where produkt_id = 'FTTH Abschlußbox AP (unbestückt) Typ M') ;



update  comsof.rohr set bez = (select nam from 
	(select id, case when typ='Rohrverband' then 'MRV' when typ='Einzelrohr' then'ER' end||(select onb_onkz from _cluster where cluster =_cluster.id)||'/'|| right((100000+row_number() over (order by id))::text,5) nam from comsof.rohr) sel
	where sel.id= comsof.rohr.id);

update comsof.microduct set bez = (select bez from comsof.rohr r where r.id=rohr_id )||'/'||right((microduct_nr+100)::text,2);






TO DO Microduct Bez



*************************************************
with recursive tr AS(
select id, rohr_id from comsof.microduct where rohr_id=uuid('d1f20016-6bc3-48b3-a90d-117809eff86f')
union
select m.id, m.rohr_id  from comsof.microduct m inner join tr on tr.id=m.stammt_von
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