/*
This SQL code is to feed the intermediate tables from comsof

prerequisit:
	-C2_Project_intermediate_Tables.sql
	
DNS GIS-Group
16-10-2020
*/

/*  ########################        Haus anschluss            ###################################################################################################################################################################   */
/*the id of the "knotäuse" is the id of "OUT_ACCESSSTRUCTURE"*/
insert into comsof.knoten (id, geom , typ , subtyp , planung_status, foerdert_status, cluster) select id, geom , 'Gebaeude', 'Abschlusspunkt', 'Grobplanung',null , (select destination_cluster from comsof.comsof_metadata)  from comsof.out_accessstructures where type='Building';

/*import the amtlichen daten in a table with the structure of adresse. we called it  here "a.amtlichedaresse"
for this purpose, we filtered the amtlichen daten from our database "adressen" for Eichwalde. Then we import
the filtered building into  "a.amtlichedaresse" */

--insert into comsof.adresse(
--		uuid, alkis_id, geom, typ, gemeinde_name, gemeinde_schluessel, amtname, kreis, kreis_nr, ort, ortsteil, ortsteil_nr, plz, strasse, psn, strassenschluessel, hausnr, adresszusatz, funktion, funktion_kategorie, anzahl_wohneinheit, anzahl_gewerbeeinheit, anzahl_nutzeinheit, aufnahmedatum, x,y,wgs84_lat,wgs84_lon
--		)  select
--		uuid(id), alkis_id, geom, typ, gemeinde_name, gemeinde_schluessel, amtname, kreis, kreis_nr, ort, ortsteil, ortsteil_nr, plz, strasse, psn, strassenschluessel, hausnr, adresszusatz, funktion, funktion_kategorie, anzahl_wohneinheit, anzahl_gewerbeeinheit, anzahl_nutzeinheit, aufnahmedatum, x,y,wgs84_lat,wgs84_lon
--		from comsof.amtlicheadresse;

-- ##Here we had changes
with sel as (select ge.id knot_id, uuid knot_uuid ,comsof.in_demandpoints.id fid, ge.geom from comsof.knoten ge join comsof.in_demandpoints on st_equals(ge.geom, comsof.in_demandpoints .geom)) 
	insert into comsof.abschlusspunkte (id,geom,  knoten_id, knoten_uuid,typ,  einbauort , homeconnect_status, cluster)  select fid , geom, knot_id ,knot_uuid , 'Gf-HUEP', Null, Null , (select destination_cluster from comsof.comsof_metadata) from sel ;
	/* ==>  The id of "a.abschlusspunkte" is the same with  the fid of "in_demandpoints" . because we need to match it with amtlichen daten*/


-- -- when we do not have our uuid form in_dimandpoints:
-- drop table if exists comsof.temp;
-- create /*temporary*/ table comsof.temp as 
-- 	with adresse as (select * from adressen.adressen where bundesland=(select bundesland from comsof.comsof_metadata))
-- 		,sel1 as (select abschluss.fid  abschluss_id , abschluss.geom abschluss_geom,  lower(abschluss.plz||abschluss.strasse ||abschluss.hausnummer|| case when abschluss.hausnumm_1 is null then '' else abschluss.hausnumm_1 end  )abschluss_key from comsof.in_demandpoints abschluss)
-- 		,sel2 as (select  adresse.id  adresse_id , lower ( adresse.plz|| adresse.psn||adresse.hausnr|| case when adresse.adresszusatz is null then '' else adresse.adresszusatz end)adresse_key from adresse adresse)
-- 		select * from sel1 full outer join sel2 on sel1.abschluss_key=sel2.adresse_key  where abschluss_id is not null and adresse_id is not Null;
-- 	
-- 
-- 
-- insert into comsof.adresse_abschluss(abschlusspunkte_id, adresse_id, cluster)  select    abschluss_id, adresse_id, (select destination_cluster from comsof.comsof_metadata) from comsof.temp;
-- /* ==>  The id of "a.abschlusspunkte" is the same with  the fid of "in_demandpoints" . because we need to match it with amtlichen daten*/
-- 
-- update comsof.adresse_abschluss  aa  set abschlusspunkte_uuid=(select uuid from comsof.abschlusspunkte ab where ab.id=aa.abschlusspunkte_id)
-- 


insert into comsof.adresse_abschluss (adresse_id, abschlusspunkte_id, abschlusspunkte_uuid, cluster)
	select uuid(ind._id) adr_uuid , ab.id ab_id, ab.uuid ab_uuid ,  ab.cluster from comsof.abschlusspunkte ab join comsof.in_demandpoints ind on st_equals(ind.geom, ab.geom)





insert into comsof.connection_module(id, typ, produkt_id, knoten_id, netzebene_quelle,netzebene_ziel, eigentum_status, foerdert_status, cluster) 
	select eq_id, 'Switch / Plugin', NULL, id, 'Verteiler-Ebene','In-House-Ebene', 'Eigentum', 'Eigenausbau',(select destination_cluster from comsof.comsof_metadata) from comsof.out_accessstructures where type = 'Building';
with sel as( select connmodule.id, knot.uuid  knot_uuid from  comsof.connection_module connmodule join comsof.knoten knot on knot.id=connmodule.knoten_id )
	update comsof.connection_module set knoten_uuid=(select knot_uuid from sel where sel.id=comsof.connection_module .id); 


/*The id of the "connection_unit" is the eq_id of the "out_closure" */
insert into comsof.connection_unit (id, conn_module_id,	produkt_id, letzten_datum_mod, cluster)
	select  eq_id , enc_eqp_id ,Null , Null, (select destination_cluster from comsof.comsof_metadata) from comsof.out_closures where layer='Demand';
with sel as (select conmod.id elem_id, connmodule.uuid from comsof.connection_module connmodule  join comsof.connection_unit conmod on conmod.conn_module_id = connmodule.id)
	update comsof.connection_unit set conn_module_uuid = (select sel.uuid from sel where sel.elem_id=comsof.connection_unit.id);

/* The id of the "connection_Element" is
	For hausanschluss or POP is the same as the id of the "connection_unit" (i.e. the eq_id of the "outer_closure" ) 
	For splitter is the splice_id of the  "outer_splitter"*/
insert into  comsof.connection_element( id,	conn_unit_id,	produkt_id,	typ, subtyp, installation_ziele,	installation_spalte , label,	 mehrdetail, cluster )
	select eq_id, eq_id, null, 'Passive', 'Switch / Plugin', Null, Null, Null, null,(select destination_cluster from comsof.comsof_metadata) from comsof.out_closures where layer='Demand'; /*only for Haus anschluss*/	
with sel as (select elem.id elem_id, unit.uuid from comsof.connection_element elem join comsof.connection_unit unit on unit.id= elem.conn_unit_id)
	update comsof.connection_element set conn_unit_uuid=(select uuid from sel where sel.elem_id= comsof.connection_element.id ) ;

/*  ########################        POP / centraloffices            ###################################################################################################################################################################   */
insert into comsof.knoten (id, geom , typ , subtyp , planung_status, foerdert_status, cluster )
	select id, geom , 'Gebaeude', 'POP', 'Grobplanung',Null , (select destination_cluster from comsof.comsof_metadata)  from comsof.out_accessstructures where type='CentralOffice';

/*the id of the "connection_module" is eq_id of the "OUT_ACCESSSTRUCTURE"*/
insert into comsof.connection_module(id, typ, produkt_id, knoten_id, netzebene_quelle,netzebene_ziel, eigentum_status, foerdert_status, cluster)
	select eq_id, 'Switch / Plugin', NULL, id, 'Backbone-Ebene','Haupt-Ebene', 'Eigentum', Null, (select destination_cluster from comsof.comsof_metadata) from comsof.out_accessstructures where type = 'CentralOffice';
with sel as( select connmodule.id, knot.uuid  knot_uuid from  comsof.connection_module connmodule join comsof.knoten knot on knot.id=connmodule.knoten_id )
	update comsof.connection_module set knoten_uuid=(select knot_uuid from sel where sel.id=comsof.connection_module .id)  where  comsof.connection_module.knoten_uuid is null;
	
/*The id of the "connection_unit" is the eq_id of the "out_closure" */
insert into comsof.connection_unit (id, conn_module_id,	produkt_id, letzten_datum_mod, cluster)
	select  eq_id , enc_eqp_id ,Null , Null, (select destination_cluster from comsof.comsof_metadata) from comsof.out_closures where layer='Feeder';
with sel as (select conmod.id elem_id, connmodule.uuid from comsof.connection_module connmodule  join comsof.connection_unit conmod on conmod.conn_module_id = connmodule.id)
	update comsof.connection_unit set conn_module_uuid = (select sel.uuid from sel where sel.elem_id=comsof.connection_unit.id) where conn_module_uuid is null;


/* The id of the "connection_Element" is
	For hausanschluss or POP is the same as the id of the "connection_unit" (i.e. the eq_id of the "outer_closure" ) 
	For splitter is the splice_id of the  "outer_splitter"*/
insert into  comsof.connection_element( id,	conn_unit_id,	produkt_id,	typ, subtyp, installation_ziele,	installation_spalte , label,	 mehrdetail, cluster )
	select eq_id, eq_id, null, 'Active', 'Switch / Plugin', Null, Null, Null, null, (select destination_cluster from comsof.comsof_metadata) from comsof.out_closures where layer='Feeder'; /*only for POP*/
with sel as (select elem.id elem_id, unit.uuid from comsof.connection_element elem join comsof.connection_unit unit on unit.id= elem.conn_unit_id)
	update comsof.connection_element set conn_unit_uuid=(select uuid from sel where sel.elem_id= comsof.connection_element.id ) where conn_unit_uuid is null;

/*  ########################        schacht              ####################################################################################################################################################################################   */
/*Ziehschacht : */
insert into comsof.knoten (id, geom , typ , subtyp , planung_status, foerdert_status, cluster)
	select id, geom , 'Schacht', 'Ziehschacht / Schacht an grossen Knotenpunkten', 'Grobplanung',Null , (select destination_cluster from comsof.comsof_metadata)  from comsof.out_accessstructures where type='HandHole';
/*Verteilerschacht :*/
insert into comsof.knoten (id, geom , typ , subtyp , planung_status, foerdert_status, cluster)
	select id, geom , 'Schacht', 'GF_NVT', 'Grobplanung','Eigenausbau' , (select destination_cluster from comsof.comsof_metadata) from comsof.out_accessstructures where type='HandHole' and eq_id in (select enc_eqp_id from comsof.out_closures) ;
	
/*the id of the "connection_module" is eq_id of the "OUT_ACCESSSTRUCTURE"*/     /*Verteilerschacht :*/
insert into comsof.connection_module(id, typ, produkt_id, knoten_id, netzebene_quelle,netzebene_ziel, eigentum_status, foerdert_status, cluster) 
	select eq_id, 'Muffe', NULL, id, 'Hauptebene','Verteilerebene', 'Eigentum', Null,(select destination_cluster from comsof.comsof_metadata) from comsof.out_accessstructures where type = 'HandHole' and eq_id in (select enc_eqp_id from comsof.out_closures);
with sel as( select connmodule.id, knot.uuid  knot_uuid from  comsof.connection_module connmodule join comsof.knoten knot on knot.id=connmodule.knoten_id )
	update comsof.connection_module set knoten_uuid=(select knot_uuid from sel where sel.id=comsof.connection_module .id)  where  comsof.connection_module.knoten_uuid is null;

/*The id of the "connection_unit" is the eq_id of the "out_closure" */     /*Verteilerschacht :*/
insert into comsof.connection_unit (id, conn_module_id,	produkt_id, letzten_datum_mod, cluster)
	select  eq_id , enc_eqp_id ,Null , Null, (select destination_cluster from comsof.comsof_metadata) from comsof.out_closures where layer='Distribution' and enc_eqp_id in (select id from comsof.connection_module where typ='Muffe');
with sel as (select conmod.id elem_id, connmodule.uuid from comsof.connection_module connmodule  join comsof.connection_unit conmod on conmod.conn_module_id = connmodule.id)
	update comsof.connection_unit set conn_module_uuid = (select sel.uuid from sel where sel.elem_id=comsof.connection_unit.id) where conn_module_uuid is null;

/* The id of the "connection_Element" is
	For hausanschluss or POP is the same as the id of the "connection_unit" (i.e. the eq_id of the "outer_closure" ) 
	For splitter is the splice_id of the  "out_splitter"*/      /*Verteilerschacht :*/
insert into  comsof.connection_element( id,	conn_unit_id,	produkt_id,	typ, subtyp, installation_ziele,	installation_spalte , label,	 mehrdetail, cluster)
	select splice_id, eq_id, null, 'Passive', 'Splitter', Null, Null, Null, null, (select destination_cluster from comsof.comsof_metadata) from comsof.out_splitters where enc_eqp_id in (select id from comsof.connection_unit); 
with sel as (select elem.id elem_id, unit.uuid from comsof.connection_element elem join comsof.connection_unit unit on unit.id= elem.conn_unit_id)
	update comsof.connection_element set conn_unit_uuid=(select uuid from sel where sel.elem_id= comsof.connection_element.id ) where conn_unit_uuid is null;

/*  ########################        Trassen/Rohren-abzweigungen              ################################################################################################################################################################### */
/* knotäuse :  make Pop to Mini-POP if exists, and insert NVTs*/
update comsof.knoten set subtyp='Mini-POP/MFG' where id  in (select id from comsof.out_accessstructures where type='Cabinet' and virtual='F' ) and typ='POP' ;

insert into comsof.knoten (id, geom , typ , subtyp , planung_status, foerdert_status, cluster)
	select id, geom , 'Kabinet', 'GF_NVT', 'Grobplanung','Eigenausbau' , (select destination_cluster from comsof.comsof_metadata)  from comsof.out_accessstructures where type='Cabinet' and virtual='F' and id not in (select id from comsof.knoten) ;

/*the id of the "connection_module" is eq_id of the "OUT_ACCESSSTRUCTURE"*/
insert into comsof.connection_module(id, typ, produkt_id, knoten_id, netzebene_quelle,netzebene_ziel, eigentum_status, foerdert_status, cluster) 
	select eq_id, 'Board', NULL, id, 'Haupt-Ebene','Verteiler-Ebene', 'Eigentum', 'Eigenausbau', (select destination_cluster from comsof.comsof_metadata) from comsof.out_accessstructures where  type='Cabinet' and virtual='F';
with sel as( select connmodule.id, knot.uuid  knot_uuid from  comsof.connection_module connmodule join comsof.knoten knot on knot.id=connmodule.knoten_id )
	update comsof.connection_module set knoten_uuid=(select knot_uuid from sel where sel.id=comsof.connection_module .id)  where  comsof.connection_module.knoten_uuid is null;

/*The id of the "connection_unit" is the eq_id of the "out_closure" */
insert into comsof.connection_unit (id, conn_module_id,	produkt_id, letzten_datum_mod, cluster)
	select  eq_id , enc_eqp_id ,Null , Null, (select destination_cluster from comsof.comsof_metadata) from comsof.out_closures where layer='Distribution';	
with sel as (select conmod.id elem_id, connmodule.uuid from comsof.connection_module connmodule  join comsof.connection_unit conmod on conmod.conn_module_id = connmodule.id)
	update comsof.connection_unit set conn_module_uuid = (select sel.uuid from sel where sel.elem_id=comsof.connection_unit.id) where conn_module_uuid is null;

/* The id of the "connection_Element" is
	For hausanschluss or POP is the same as the id of the "connection_unit" (i.e. the eq_id of the "outer_closure" ) 
	For splitter is the splice_id of the  "outer_splitter"*/
insert into  comsof.connection_element(id,	conn_unit_id,	produkt_id,	typ, subtyp, installation_ziele,	installation_spalte , label,	 mehrdetail, cluster)
	select splice_id, enc_eqp_id , null, 'Passive', 'Splitter', Null, Null, Null, null,(select destination_cluster from comsof.comsof_metadata) from comsof.out_splitters; /*only for splitter*/
with sel as (select elem.id elem_id, unit.uuid from comsof.connection_element elem join comsof.connection_unit unit on unit.id= elem.conn_unit_id)
	update comsof.connection_element set conn_unit_uuid=(select uuid from sel where sel.elem_id= comsof.connection_element.id ) where conn_unit_uuid is null;	






/*##########################################################################################################################################################################################################################################################################################################*/
/*############     kable / Faser             ########################################################################################################################################################################################################################################################*/
alter table comsof.kabel alter column anzahl_fasern drop not null;
with sel as (
	select fas.id, fas.geom,fas.cable_id,fas.p_cl_eq_id, fas.c_cl_eq_id, comsof.out_closures.eq_id par_closure_eq, comsof.out_closures.enc_eqp_id connmodule_anfang from comsof.out_feedercableentries fas join comsof.out_closures  on  comsof.out_closures.eq_id=fas.p_cl_eq_id )
	,sel2 as (select sel.id, sel.geom, st_length(sel.geom) leng,max(st_length(sel.geom) ) over (partition by sel.cable_id) max_leng, sel.cable_id, sel.connmodule_anfang, comsof.out_closures.enc_eqp_id connmodule_ende  from sel join comsof.out_closures on comsof.out_closures.eq_id=sel.c_cl_eq_id)
	,sel3 as (select distinct cable_id, st_linemerge(geom), Null produkt, 'Kabel' typ, 'Haupt-Ebene', connmodule_anfang, connmodule_ende, 'Grobplanung', 'Eigenausbau', 'Eigentum' , 'HP : Home-Pass', leng, (select destination_cluster from comsof.comsof_metadata) from sel2 where leng = max_leng)
	insert into comsof.kabel (id, geom, produkt_id, typ, netzebene, conn_module_anfang, conn_module_ende, planung_status, foerdert_status,eigentum_status,   homeconnect_status, length, cluster) select * from sel3;	
with sel as (select k.id, ck.cablegran cnt from comsof.out_feedercables ck join  comsof.kabel k  on ck.cable_id= k.id)
	update comsof.kabel set anzahl_fasern=(select cnt from sel where sel.id=comsof.kabel.id ) where comsof.kabel.netzebene='Haupt-Ebene';
	
with sel as (
	select fas.id, fas.geom,fas.cable_id,fas.p_cl_eq_id, fas.c_cl_eq_id, comsof.out_closures.eq_id par_closure_eq, comsof.out_closures.enc_eqp_id connmodule_anfang from comsof.out_distributioncableentries fas join comsof.out_closures  on  comsof.out_closures.eq_id=fas.p_cl_eq_id )
	,sel2 as (select sel.id, sel.geom, st_length(sel.geom) leng,max(st_length(sel.geom) ) over (partition by sel.cable_id) max_leng, sel.cable_id, sel.connmodule_anfang, comsof.out_closures.enc_eqp_id connmodule_ende  from sel join comsof.out_closures on comsof.out_closures.eq_id=sel.c_cl_eq_id)
	,sel3 as (select distinct cable_id, st_linemerge(geom), Null produkt, 'Kabel' typ, 'Verteiler/Drop', connmodule_anfang, connmodule_ende, 'Grobplanung', 'Eigenausbau', 'Eigentum' , 'HP : Home-Pass', leng, (select destination_cluster from comsof.comsof_metadata) from sel2 where leng = max_leng)
	insert into comsof.kabel (id, geom, produkt_id, typ, netzebene, conn_module_anfang, conn_module_ende, planung_status, foerdert_status,eigentum_status,   homeconnect_status, length, cluster) select * from sel3; 
with sel as (select k.id, ck.cablegran cnt from comsof.out_distributioncables ck join  comsof.kabel k  on ck.cable_id= k.id)
	update comsof.kabel set anzahl_fasern=(select sel.cnt from sel where sel.id=comsof.kabel.id ) where  comsof.kabel.netzebene='Verteiler/Drop';
/*update kabel, the uuid of connection modules*/
with sel as (select  k.id kid,  module.uuid   from comsof.kabel k join comsof.connection_module module on module.id=k.conn_module_anfang)
	update comsof.kabel set conn_module_anfang_uuid= (select sel.uuid from sel where  sel.kid= comsof.kabel.id );
with sel as (select  k.id kid,  module.uuid   from comsof.kabel k join comsof.connection_module module on module.id=k.conn_module_ende)
	update comsof.kabel set conn_module_ende_uuid= (select sel.uuid from sel where  sel.kid= comsof.kabel.id );		

alter table comsof.kabel alter column anzahl_fasern set not null;

/* Fasern: */

Drop table if exists comsof.temp_faser;
Create table comsof.temp_faser (like comsof.out_feedercableentries);
Alter table comsof.temp_faser drop column entry_id;
Alter table comsof.temp_faser add constraint pk_tempfaser primary key(id);
CREATE INDEX inx_temp_faser_geom ON comsof.temp_faser USING GIST(geom);
CREATE INDEX inx_temp_faser_child_id ON comsof.temp_faser(child_id);
CREATE INDEX inx_temp_faser_parent_id ON comsof.temp_faser(parent_id);
Insert into comsof.temp_faser select  entry_id, geom , cable_id, fib_index, child_id, parent_id, c_cl_eq_id,p_cl_eq_id,bot_agg_id, top_agg_id from comsof.out_feedercableentries;
Insert into comsof.temp_faser select  entry_id, geom , cable_id, fib_index, child_id, parent_id, c_cl_eq_id,p_cl_eq_id,bot_agg_id, top_agg_id from comsof.out_distributioncableentries;

insert into comsof.faser (id, geom, kabel_id, netzebene,buendeln_nr , faser_label ,conn_element_anfang, anf_elem_output_nr, anfang_typ,anfang_label, conn_element_ende, end_elem_input_nr ,ende_typ, ende_label,length, cluster)
	select id, st_linemerge(geom), cable_id, 'Haupt-Ebene',1 beundeln, Null fs_label, p_cl_eq_id, Null elem_out_nr, Null anfang_typ, Null label_anf, c_cl_eq_id, null elem_in_nr,
	Null ende_typ, Null label_ende, Null length, (select destination_cluster from comsof.comsof_metadata) clust from comsof.temp_faser;
/*update faser netzebene*/
with sel as (select f.id fid , k.netzebene from comsof.faser f join comsof.kabel k on k.id= f.kabel_id)
	update comsof.faser set netzebene = (select sel.netzebene from sel where sel.fid=comsof.faser.id);

with sel as (select f.id fid , k.uuid from comsof.faser f join comsof.kabel k on f.kabel_id=k.id)
	update comsof.faser set kabel_uuid = (select sel.uuid from sel where sel.fid=comsof.faser.id);

with sel as (select f.id fid , e.uuid from comsof.faser f join comsof.connection_element e on f.conn_element_anfang=e.id)
	update comsof.faser set conn_element_anfang_uuid = (select sel.uuid from sel where sel.fid=comsof.faser.id);
with sel as (select f.id fid , e.uuid from comsof.faser f join comsof.connection_element e on f.conn_element_ende=e.id)
	update comsof.faser set conn_element_ende_uuid = (select sel.uuid from sel where sel.fid=comsof.faser.id);
	

/*############     knotäuse: Rohrabzweigung             ########################################################################################################################################################################################################################################################*/
/* Select the points in "out_acessstructures" with the  type of accessstreucture that the id is not alresedy imported to "knoten"*/
insert into comsof.knoten (id, geom , typ , subtyp , planung_status, foerdert_status, cluster)
	select distinct id, geom, 'Lage', 'Lage, zugaenglich mit einem Kugelmarker', 'Grobplanung',Null , (select destination_cluster from comsof.comsof_metadata)  from comsof.out_accessstructures where type='AccessStructure' and id not in (select id from comsof.knoten);



/*############     Rohre           ########################################################################################################################################################################################################################################################*/
insert into comsof.rohr (id,		geom,	typ,	produkt_id,	planung_status,	foerdert_status,	netzebene,	homeconnect_status,	anzahl_microducts ,cluster)
	select duct_id , st_linemerge(geom), 'Rohrverband' typ,Null produkt, 'Grobplanung' planung_status , Null foerdert,  'Haupt-Ebene' ebene, 'HP : Home-Pass' hc, capacity, (select destination_cluster from comsof.comsof_metadata) clust from comsof.out_feederduct where capacity>1 and st_length(geom)!=0
	union all
	select duct_id , st_linemerge(geom), 'Einzelrohr' typ,Null produkt,  'Grobplanung' planung_status , Null foerdert,  'Haupt-Ebene' ebene, 'HP : Home-Pass' hc, capacity,(select destination_cluster from comsof.comsof_metadata) clust from comsof.out_feederduct where capacity=1 and st_length(geom)!=0
	union all
	select duct_id , st_linemerge(geom), 'Rohrverband' typ,Null produkt,  'Grobplanung' planung_status , Null foerdert,  'Verteiler-Ebene' ebene, 'HP : Home-Pass' hc, capacity,(select destination_cluster from comsof.comsof_metadata) clust from comsof.out_distributionduct where capacity>1 and st_length(geom)!=0
	union all
	select duct_id , st_linemerge(geom), 'Einzelrohr' typ,Null produkt, 'Grobplanung' planung_status , Null foerdert,  'Verteiler-Ebene' ebene, 'HP : Home-Pass' hc, capacity,(select destination_cluster from comsof.comsof_metadata) clust from comsof.out_distributionduct where capacity=1 and st_length(geom)!=0
	union all
	select duct_id , st_linemerge(geom), 'Rohrverband' typ,Null produkt, 'Grobplanung' planung_status , Null foerdert,  'Verteiler-Ebene' ebene, 'HC : Home-Connect' hc, capacity,(select destination_cluster from comsof.comsof_metadata) clust from comsof.out_dropduct where capacity>1 and st_length(geom)!=0
	union all
	select duct_id , st_linemerge(geom), 'Einzelrohr' typ,Null produkt,  'Grobplanung' planung_status , Null foerdert,  'Verteiler/Drop' ebene,Null  hc, capacity,(select destination_cluster from comsof.comsof_metadata) clust from comsof.out_dropduct where capacity=1 and st_length(geom)!=0	
	
	
/*############     Microducts           ##############################################################################################################################################################################################################################################*/
drop table if exists comsof.temp_microduct;
create table comsof.temp_microduct (
	id serial,
	geom geometry('LINESTRING',25833),
	rohr_id integer,
	micro_nr integer,
	point_anf geometry('POINT',25833),
	anfang_location numeric,
	point_end geometry('POINT',25833),
	ende_location numeric,
	knot_anf integer,
	knot_ende integer,
	stammt_von integer,
	kabel_id integer,
	kabel_geom geometry('LINESTRING',25833),
	bottom_agg_id text,
	zweig integer,
	cluster integer,
	constraint pk_temp_microduct primary key (id)
);
create index inxfk_comsof_temp_microduct_rohr on comsof.temp_microduct(rohr_id);
create index inxfk_comsof_temp_microduct_knot_anf on comsof.temp_microduct(knot_anf);
create index inxfk_comsof_temp_microduct_knot_ende on comsof.temp_microduct(knot_ende);
create index inxfk_comsof_temp_microduct_kabel on comsof.temp_microduct(kabel_id);
CREATE INDEX inx_comsof_temp_microduct_geom ON comsof.temp_microduct USING GIST(geom);
CREATE INDEX inx_comsof_temp_microduct_kabel_geom ON comsof.temp_microduct USING GIST(kabel_geom);
CREATE INDEX inx_comsof_temp_microduct_point_anf ON comsof.temp_microduct USING GIST(point_anf);
CREATE INDEX inx_comsof_temp_microduct_point_end ON comsof.temp_microduct USING GIST(point_end);


Do  $$
declare
	itr integer;
	cap integer;
	duct integer;
begin
	/*haupt ducts*/
	For duct in select duct_id from comsof.out_feederduct LOOP
		itr := 1;
		execute( 'select capacity from comsof.out_feederduct where duct_id=$1 and st_length(geom)!=0') into cap using duct;
		while itr<=cap loop
			execute('insert into comsof.temp_microduct(rohr_id, micro_nr ) values ($1 , $2)') using duct, itr; 
			itr := itr+1;
		end loop;
	end loop;
	/*distribution ducts*/
	For duct in select duct_id from comsof.out_distributionduct LOOP
		itr := 1;
		execute( 'select capacity from comsof.out_distributionduct where duct_id=$1 and st_length(geom)!=0') into cap using duct;
		while itr<=cap loop
			execute('insert into comsof.temp_microduct(rohr_id, micro_nr ) values ($1 , $2)') using duct, itr; 
			itr := itr+1;
		end loop;
	end loop;
	/*drop ducts*/
	For duct in select duct_id from comsof.out_dropduct LOOP
		itr := 1;
		execute( 'select capacity from comsof.out_dropduct where duct_id=$1 and st_length(geom)!=0') into cap using duct;
		while itr<=cap loop
			execute('insert into comsof.temp_microduct(rohr_id, micro_nr ) values ($1 , $2)') using duct, itr; 
			itr := itr+1;
		end loop;
	end loop;
END$$;

with sel as (select mic.id id, ab.geom, mic.micro_id,mic.cable_id , ab.duct_id from comsof.out_feedercablesdetail mic join comsof.out_feederductpieces ab on ab.piece_id=mic.piece_id where st_length(ab.geom)!=0)
	,sel2 as (select st_linemerge(st_union(geom)) geom,cable_id, duct_id, micro_id  from sel group by duct_id, cable_id, micro_id order by cable_id, duct_id, micro_id)
	,sel3 as (select geom, st_startpoint(geom) anfang, st_endpoint(geom) ende,cable_id, duct_id, micro_id from sel2)
	update comsof.temp_microduct set geom=sel3.geom, kabel_id=sel3.cable_id, point_anf= sel3.anfang, point_end=sel3.ende from sel3 where rohr_id=sel3.duct_id and micro_nr=(sel3.micro_id+1); /*used microducts*/

with sel as (select mic.id id, ab.geom, mic.micro_id,mic.cable_id , ab.duct_id from comsof.out_distributioncablesdetail mic join comsof.out_distributionductpieces ab on ab.piece_id=mic.piece_id where st_length(ab.geom)!=0)
	,sel2 as (select st_linemerge(st_union(geom)) geom,cable_id, duct_id, micro_id  from sel group by duct_id, cable_id, micro_id order by cable_id, duct_id, micro_id)
	,sel3 as (select geom, st_startpoint(geom) anfang, st_endpoint(geom) ende,cable_id, duct_id, micro_id from sel2)
	update comsof.temp_microduct set geom=sel3.geom, kabel_id=sel3.cable_id, point_anf= sel3.anfang, point_end=sel3.ende from sel3 where rohr_id=sel3.duct_id and micro_nr=(sel3.micro_id+1); /*used microducts*/	

with sel as (select mic.id id, ab.geom, mic.micro_id,mic.cable_id , ab.duct_id from comsof.out_dropcablesdetail mic join comsof.out_dropductpieces ab on ab.piece_id=mic.piece_id where st_length(ab.geom)!=0)
	,sel2 as (select st_linemerge(st_union(geom)) geom,cable_id, duct_id, micro_id  from sel group by duct_id, cable_id, micro_id order by cable_id, duct_id, micro_id)
	,sel3 as (select geom, st_startpoint(geom) anfang, st_endpoint(geom) ende,cable_id, duct_id, micro_id from sel2)
	update comsof.temp_microduct set geom=sel3.geom, kabel_id=sel3.cable_id, point_anf= sel3.anfang, point_end=sel3.ende from sel3 where rohr_id=sel3.duct_id and micro_nr=(sel3.micro_id+1); /*used microducts*/	

update comsof.temp_microduct set kabel_geom=(select geom from comsof.kabel where comsof.kabel.id=comsof.temp_microduct.kabel_id);	
update comsof.temp_microduct set anfang_location=ST_LineLocatePoint(kabel_geom, point_anf) , ende_location=ST_LineLocatePoint(kabel_geom, point_end);
update comsof.temp_microduct set 
	knot_anf=(select case 
		when anfang_location>=ende_location Then
			(select id from comsof.knoten where st_intersects(comsof.knoten.geom, comsof.temp_microduct.point_anf))
		else
			(select id from comsof.knoten where st_intersects(comsof.knoten.geom, comsof.temp_microduct.point_end))
		end)
	,knot_ende=(select case 
		when anfang_location>=ende_location Then
			(select id from comsof.knoten where st_intersects(comsof.knoten.geom, comsof.temp_microduct.point_end))
		else
			(select id from comsof.knoten where st_intersects(comsof.knoten.geom, comsof.temp_microduct.point_anf))
		end);
/*For the reserved microducts, not to have Null values for knot_anf and geom*/
update comsof.temp_microduct set knot_anf= (select knot_anf from comsof.temp_microduct sel  where sel.rohr_id=comsof.temp_microduct.rohr_id  and sel.knot_anf is not null limit 1) where comsof.temp_microduct.knot_anf is null;
update comsof.temp_microduct set geom= (select geom from comsof.rohr where comsof.rohr.id=comsof.temp_microduct.rohr_id) where comsof.temp_microduct.geom is null ;	

update comsof.temp_microduct set cluster=(select destination_cluster from comsof.comsof_metadata);

----update comsof.temp_microduct set  stammt_von= (select id from comsof.temp_microduct sel where comsof.temp_microduct.kabel_id=sel.kabel_id and comsof.temp_microduct.knot_anf=sel.knot_ende order by micro_nr asc limit 1);
-- to do later: fix it in general case
/*Now for the cases that a cable goes through the same rohr more than one time. (fix anfang and ende)*/
with sel as(
	select * , case when micro_nr=max then lag(id,1) over (order by rohr_id ,micro_nr asc) else stammt_von end von from (
		select *,  max(micro_nr) over (partition by rohr_id)  from (
			select id, rohr_id, micro_nr , stammt_von ,  knot_anf g_anf , knot_ende g_end from comsof.temp_microduct where id in (
				select ids from(
					select unnest(ids) ids ,kabel_id, rohr_id ,cnt from (
						select array_agg(id) ids, kabel_id, rohr_id ,count(*)  cnt from comsof.temp_microduct group by kabel_id, rohr_id  order by cnt desc 
						) sel1 where sel1.kabel_id is not null and cnt>1
				) sel2
			) order by rohr_id, micro_nr
		)sel3 
	)sel4
	) update comsof.temp_microduct set knot_anf=(select g_end from sel where sel.id=comsof.temp_microduct.id) , knot_ende=(select g_anf from sel where sel.id=comsof.temp_microduct.id)/*, stammt_von=(select von from sel where sel.id=comsof.temp_microduct.id)*/ where id in (select id from sel);	

--update comsof.temp_microduct set  stammt_von= (select id from comsof.temp_microduct sel where comsof.temp_microduct.kabel_id=sel.kabel_id and comsof.temp_microduct.knot_anf=sel.knot_ende order by micro_nr asc limit 1);	


--fix anfang and ende for the microducts that are in the same rohrverband
with sel as(
	select * , case when micro_nr=max then lag(id,1) over (order by rohr_id ,micro_nr asc) else stammt_von end von from (
		select *,  max(micro_nr) over (partition by rohr_id)  from (
			select id, rohr_id, micro_nr , stammt_von ,  knot_anf g_anf , knot_ende g_end from comsof.temp_microduct where id in (
				select ids from(
					select unnest(ids) ids ,kabel_id, rohr_id ,cnt from (
						select array_agg(id) ids, kabel_id, rohr_id ,count(*)  cnt from comsof.temp_microduct group by kabel_id, rohr_id  order by cnt desc 
						) sel1 where sel1.kabel_id is not null and cnt>1
				) sel2
			) order by rohr_id, micro_nr
		)sel3 
	)sel4
	) 
	update comsof.temp_microduct set 
		knot_anf=(select case when sel.micro_nr=sel.max  then g_end else g_anf end from sel where sel.id=comsof.temp_microduct.id ) 
		, knot_ende=(select case when sel.micro_nr=sel.max  then g_anf else g_end end from sel where sel.id=comsof.temp_microduct.id )
		--, stammt_von=(select von from sel where sel.id=comsof.temp_microduct.id ) 
	where id in (select id from sel);	

-- update stammt_von
update comsof.temp_microduct  m set  
	stammt_von= (select id from comsof.temp_microduct sel where m.kabel_id=sel.kabel_id and m.knot_anf=sel.knot_ende 
								and not (sel.rohr_id=m.rohr_id and sel.micro_nr>m.micro_nr) order by micro_nr asc limit 1) where stammt_von is  null;

--EICHWALDE--  
--EICHWALDE--  
--EICHWALDE--  /*
--EICHWALDE--  	TO CHANGE LATER
--EICHWALDE--  */
--EICHWALDE--  -- manual changes :(
--EICHWALDE--  -- 81 82   145, 146
--EICHWALDE--  update comsof.temp_microduct set knot_anf=580, knot_ende=172 , stammt_von=265 where id=185;
--EICHWALDE--  update comsof.temp_microduct set stammt_von=185 where id=145;
--EICHWALDE--  update comsof.temp_microduct set stammt_von=281 where id=174;
--EICHWALDE--  update comsof.temp_microduct set stammt_von=82 where id=245;
--EICHWALDE--  
--EICHWALDE--  -- 305, 307
--EICHWALDE--  update comsof.temp_microduct set stammt_von=307 where id=303;
--EICHWALDE--  
--EICHWALDE--  -- 249, 250
--EICHWALDE--  update comsof.temp_microduct set stammt_von=250 where id=261;
--EICHWALDE--  
--EICHWALDE--  -- 229, 230
--EICHWALDE--  update comsof.temp_microduct set stammt_von=230 where id=226;
--EICHWALDE--  
--EICHWALDE--  -- 221, 22
--EICHWALDE--  update comsof.temp_microduct set stammt_von=222 where id=129;
--EICHWALDE--  
--EICHWALDE--  -- 217, 219
--EICHWALDE--  update comsof.temp_microduct set stammt_von=219 where id=105;
--EICHWALDE--  
--EICHWALDE--  -- 169, 170
--EICHWALDE--  update comsof.temp_microduct set stammt_von=170 where id=294;
--EICHWALDE--  
--EICHWALDE--  -- 153 , 154
--EICHWALDE--  update comsof.temp_microduct set stammt_von=154 where id=258;
--EICHWALDE--  
--EICHWALDE--  --  97, 98
--EICHWALDE--  update comsof.temp_microduct set stammt_von=98 where id=134;
--EICHWALDE--  
--EICHWALDE--  
--EICHWALDE--  -- 77, 78 
--EICHWALDE--  update comsof.temp_microduct set stammt_von=78 where id=158;
--EICHWALDE--  
--EICHWALDE--  
--EICHWALDE--  --  69 , 70
--EICHWALDE--  update comsof.temp_microduct set stammt_von=70 where id=6;
--EICHWALDE--  
--EICHWALDE--  --  9,10
--EICHWALDE--  update comsof.temp_microduct set stammt_von=10 where id=121;
--EICHWALDE--  
--EICHWALDE--  
-- update zweig

-----check:
------  select * from comsof.temp_microduct   where id in (39,    305,307  ,303) --anfang 4021
------  select * from comsof.temp_microduct   where id in (278,  249,250,   261) --anfang 582
------  select * from comsof.temp_microduct   where id in (109,   229,230   ,226)--anfang 5483
------  select * from comsof.temp_microduct   where id in (50,   221,222   , 129)--anfang 3387
------  select * from comsof.temp_microduct   where id in (207,   217,219     ,105)--anfang 1505
------  select * from comsof.temp_microduct   where id in (85,   169,170   , 294)--anfang 2027
------  select * from comsof.temp_microduct   where id in (190,   153,154    ,258)--anfang 188
------  select * from comsof.temp_microduct   where id in (265, 185 ,     145,146,   281, 174)  -- anfang 172
------  select * from comsof.temp_microduct   where id in (61,   97,98,   134) --anfang 1735
------  select * from comsof.temp_microduct   where id in (81,82,   245)-- anfabng 831
------  select * from comsof.temp_microduct   where id in (77,78,  158)-- anfang 5097
------  select * from comsof.temp_microduct   where id in (89,   69,70,  6)-- anfang 979
------  select * from comsof.temp_microduct   where id in (242,  9,10   ,121)	-- anfang 5415



/*  ###   Feed Microducts  ##################*/
insert into comsof.microduct (id,geom, rohr_id, microduct_nr, knoten_anfang, knoten_ende, stammt_von, kabel_id, bottom_agg_id, zweig, cluster, netzebene)
	select id, geom, rohr_id, micro_nr, knot_anf, knot_ende, stammt_von, kabel_id, bottom_agg_id, zweig, cluster, 'Haupt-Ebene' from comsof.temp_microduct;

/*update netzebene*/
with sel as (select m.id, r.netzebene from comsof.microduct m join comsof.rohr r on r.id=m.rohr_id)
	update comsof.microduct set netzebene=(select netzebene from sel where sel.id=comsof.microduct.id);

/* update uuids */
with sel as (select m.id, r.uuid from comsof.microduct m join comsof.rohr r on r.id=m.rohr_id)
	update comsof.microduct set rohr_uuid=(select uuid from sel where sel.id=comsof.microduct.id);
with sel as (select m.id, g.uuid from comsof.microduct m join comsof.knoten g on g.id=m.knoten_anfang)
	update comsof.microduct set knoten_anfang_uuid=(select uuid from sel where sel.id=comsof.microduct.id);
with sel as (select m.id, g.uuid from comsof.microduct m join comsof.knoten g on g.id=m.knoten_ende)
	update comsof.microduct set knoten_ende_uuid=(select uuid from sel where sel.id=comsof.microduct.id);
with sel as (select m.id, k.uuid from comsof.microduct m join comsof.kabel k on k.id=m.kabel_id)
	update comsof.microduct set kabel_uuid=(select uuid from sel where sel.id=comsof.microduct.id);
with sel as (select m.id, r.uuid from comsof.microduct m join comsof.microduct r on r.id=m.stammt_von)
	update comsof.microduct set stammt_von_uuid=(select uuid from sel where sel.id=comsof.microduct.id);

-- Update conn_unit_anfang/ende
with kabel as(
	select sel.id id, sel.conn_module_anfang_uuid , (select knoten_uuid from comsof.connection_module where id=sel.conn_module_anfang) knoten_anfang
		,sel.conn_module_ende_uuid, (select knoten_uuid from comsof.connection_module where id=sel.conn_module_ende) knoten_ende
	from (select * from comsof.kabel) sel)
	, sel2 as (select mic.id microduct_id, knoten_anfang_uuid micro_knoten_anf , knoten_ende_uuid micro_knoten_ende, kabel.knoten_anfang kabel_knoten_anfang,  kabel.conn_module_anfang_uuid kabel_module_anfang, kabel.knoten_ende kabel_knoten_ende,  kabel.conn_module_ende_uuid kabel_module_ende from comsof.microduct mic join kabel on mic.kabel_id= kabel.id)
	--select * from sel2
	,sel3 as(select microduct_id
			,case when micro_knoten_anf=kabel_knoten_anfang then kabel_module_anfang when micro_knoten_anf=kabel_knoten_ende then kabel_module_ende else Null end mod_anf
			,case when micro_knoten_ende=kabel_knoten_anfang then kabel_module_anfang when micro_knoten_ende=kabel_knoten_ende then kabel_module_ende else Null end mod_ende
	from sel2)
	update comsof.microduct set conn_module_anfang_uuid = (select mod_anf from sel3 where microduct_id=id), conn_module_ende_uuid = (select mod_ende from sel3 where microduct_id=id);




---- Update bottom_Agg_id	
with recursive tr AS(
		select id, rohr_id, microduct_nr, stammt_von_uuid , knoten_ende knot_ende_as_botton_aggid, (select subtyp from comsof.knoten  where id=knoten_ende) ende from comsof.microduct where knoten_ende in (select id from comsof.knoten where subtyp in ('POP', 'Mini-POP/MFG', 'GF_NVT', 'KVZ', 'Abschlusspunkt','Ziehschacht / Schacht an grossen Knotenpunkten' ) ) 
	union
		select m.id, m.rohr_id, m.microduct_nr,m.stammt_von_uuid , tr.knot_ende_as_botton_aggid ,tr.ende from comsof.microduct m inner join tr on m.uuid=tr.stammt_von_uuid and m.knoten_ende NOT in (select id from comsof.knoten where subtyp in ('POP', 'Mini-POP/MFG', 'GF_NVT', 'KVZ', 'Abschlusspunkt','Ziehschacht / Schacht an grossen Knotenpunkten' ) ) 
	)--select id, count(id )cnt from tr group by id order by cnt desc	 --the frequency of all should be 1
	update comsof.microduct set bottom_agg_id=(select knot_ende_as_botton_aggid::text from tr where tr.id=comsof.microduct.id);-- the smae number of the microduct that have kabel inside
	
	

-- get the rohr top_agg_id
----- with recursive tr AS(
----- 		select id, rohr_id, bottom_agg_id , knoten_anfang as top_agg_id from comsof.microduct where knoten_anfang in (select id from comsof.knoten where subtyp in ('POP', 'Mini-POP/MFG', 'GF_NVT', 'KVZ', 'Ziehschacht / Schacht an grossen Knotenpunkten' )) and bottom_agg_id is not null --and stammt_von is null
----- 	union
----- 		select m.id, m.rohr_id, m.bottom_agg_id, tr.top_agg_id from comsof.microduct m inner join tr on m.bottom_agg_id=tr.bottom_agg_id 
----- 	) 
----- 	--select * from tr order by top_agg_id, rohr_id
----- 	,sel2 as ( select distinct rohr_id, top_agg_id from tr order by rohr_id)
----- 	select rohr_id, count(rohr_id )cnt from sel2 group by rohr_id order by cnt desc	
----- 	update comsof.rohr r set top_agg_id= (select top_agg_id from sel2 where sel2.rohr_id=r.id) 
----- 	
----- 	--select id from comsof.rohr r where r.id not in (select rohr_id from tr) 
----- 	--select rohr_id, count(rohr_id )cnt from tr group by rohr_id order by cnt desc	
----- 	select rohr_id, count(rohr_id )cnt from sel2 group by rohr_id order by cnt desc	
----- 		
----- 	

/*############     Trasse           #################################################################################################################*/
with sel1 as ( select * from comsof.out_usedsegments where id in (select id from comsof.out_feederroutes) )
	, sel2 as (select id , st_linemerge(geom), case when crossing='T' then 'Querung' Else 'Laengstrasse' end ,
		case when crossing='T' then 'Pressbohrung/Bodenverdraengung' Else 'Klassischer Tiefbau (Ausschachtung)' end, Null,
		0.6, 'Unbefestigt', 'Unbekannt', Null, 'Grobplanung', 'Haupt-Ebene' , 'HP : Home-Pass', (select destination_cluster from comsof.comsof_metadata)
		from sel1 where st_length(geom)!=0)
		Insert into comsof.trasse (id , geom, typ ,trassenbauverfahren, sonst_bauverfahren, verlege_tief_m, oberflaeche, widmung, foerdert_status, planung_status,netzebene, homeconnect_status ,cluster) select * from sel2;

with sel1 as ( select * from comsof.out_usedsegments where id in (select id from comsof.out_distributionroutes) and id not in (select id from comsof.trasse) )
	, sel2 as (select id , st_linemerge(geom), case when crossing='T' then 'Querung' Else 'Laengstrasse'end ,
		case when crossing='T' then 'Pressbohrung/Bodenverdraengung' Else 'Klassischer Tiefbau (Ausschachtung)' end, Null,
		0.6, 'Unbefestigt', 'Unbekannt', Null, 'Grobplanung', 'Verteiler-Ebene' , Null, (select destination_cluster from comsof.comsof_metadata)
		from sel1 where st_length(geom)!=0)
		Insert into comsof.trasse (id , geom, typ ,trassenbauverfahren, sonst_bauverfahren, verlege_tief_m, oberflaeche, widmung, foerdert_status, planung_status,netzebene, homeconnect_status ,cluster) select * from sel2;

with sel1 as ( select * from comsof.out_usedsegments where id in (select id from comsof.out_droproutes) and id not in (select id from comsof.trasse) )
	, sel2 as (select id , st_linemerge(geom),'Hausanschlusstrasse',
		'Klassischer Tiefbau (Ausschachtung)', Null,
		0.6, 'Unbefestigt', 'Unbekannt', Null, 'Grobplanung', 'Verteiler/Drop' , Null, (select destination_cluster from comsof.comsof_metadata)
		from sel1 where st_length(geom)!=0)
		Insert into comsof.trasse (id , geom, typ ,trassenbauverfahren, sonst_bauverfahren, verlege_tief_m, oberflaeche, widmung, foerdert_status, planung_status,netzebene, homeconnect_status ,cluster) select * from sel2;	






/*############     schutzrohr           #################################################################################################################*/
 /*update gahäuse for start and end of schutzrohr*/
 /*We do not need to link schutzrohr directly with knoten. only the point-generation trigger should be run.*/
with sel1 as (select source_id id from comsof.out_usedsegments where crossing='T' and st_length(geom)!=0
		union
		select target_id id from comsof.out_usedsegments where crossing='T' and st_length(geom)!=0)
	, sel2 as (select id , geom, 'Lage', 'Lage ohne Kugelmarker', 'Grobplanung', Null, Null, (select destination_cluster from comsof.comsof_metadata)  from comsof.out_nodes where id in (select id from sel1 where id not in (select id from comsof.knoten)) )
	insert into comsof.knoten( id, geom, typ ,subtyp, planung_status,foerdert_status,produkt_id , cluster) select * from sel2;

insert into comsof.schutzrohr (id, geom , produkt_id, planung_status, foerdert_status, cluster)
	select id, geom , Null, planung_status, foerdert_status, cluster from comsof.trasse where typ='Querung';


/*update rohr-schutzrohr*/
insert into comsof.rohr_schutzrohr (schutzrohr_id, rohr_id, cluster)
	select s.id, r.id , (select destination_cluster from comsof.comsof_metadata)  from comsof.schutzrohr s join comsof.rohr r on st_contains(r.geom, s.geom) order by s.id, r.id;
with sel as	(select s.schutzrohr_id sid , s.rohr_id rid, d.uuid from comsof.rohr_schutzrohr s join comsof.schutzrohr d on d.id=s.schutzrohr_id)
	update  comsof.rohr_schutzrohr set  schutzrohr_uuid = (select uuid from  sel where sel.sid=comsof.rohr_schutzrohr.schutzrohr_id and sel.rid=comsof.rohr_schutzrohr.rohr_id);
with sel as	(select s.schutzrohr_id sid , s.rohr_id rid, d.uuid from comsof.rohr_schutzrohr s join comsof.rohr d on d.id=s.rohr_id)
	update  comsof.rohr_schutzrohr set  rohr_uuid = (select uuid from  sel where sel.sid=comsof.rohr_schutzrohr.schutzrohr_id and sel.rid=comsof.rohr_schutzrohr.rohr_id);
	
/*############     strecke           #################################################################################################################*/
Insert into comsof.strecke (_uuid,typ,cluster)
	select  uuid, 'Trasse', (select destination_cluster from comsof.comsof_metadata) from comsof.trasse
	union all
	select  uuid, 'Microduct', (select destination_cluster from comsof.comsof_metadata) from comsof.microduct
	union all
	select  uuid, 'Schutzrohr', (select destination_cluster from comsof.comsof_metadata) from comsof.schutzrohr;	


/* # todo next :
feed
	linear_object
	strecke_line
*/

/*############     drop temporary tables           #################################################################################################################*/
drop table  if exists comsof.temp;
drop table if exists  comsof.temp_faser;
drop table if exists  comsof.temp_microduct;










--update comsof.knoten  set label_prefix = 
--	CASE WHEN subtyp IN ('POP', 'Backbone-Ubergabepunkt') then 'P'
--		WHEN subtyp='Mini-POP/MFG' then 'M'
--		WHEN subtyp='GF_NVT' then 'N'
--		WHEN subtyp='KVZ' then 'C'
--		WHEN subtyp='Abschlusspunkt' then 'H'
--		WHEN subtyp='Ziehschacht / Schacht an grossen Knotenpunkten' then 'S'
--		ELSE 'L' END || (select onb_onkz from _cluster where id= cluster) ||'/' ;
--
--update comsof.knoten t set label_wert=(select label_2 from(
--	select id, CASE WHEN label_prefix like 'P%' THEN right((100000+num)::text,2)
--					WHEN label_prefix like 'M%' THEN right((100000+num)::text,2)
--					WHEN label_prefix like 'N%' THEN right((100000+num)::text,3)
--					WHEN label_prefix like 'C%' THEN right((100000+num)::text,3)
--					WHEN label_prefix like 'H%' THEN right((100000+num)::text,5)
--					WHEN label_prefix like 'S%' THEN right((100000+num)::text,4)
--					WHEN label_prefix like 'L%' THEN right((1000000+num)::text,6)
--				END AS label_2
--	from (SELECT id, label_prefix , row_number() OVER (PARTITION BY label_prefix) as num  from comsof.knoten) sel
--	)	as sel2 where t.id=sel2.id
--) ;
--update comsof.knoten set bez=label_prefix||label_wert;		

----now for the versorgt orhr that have null bez we do so:
--update comsof.rohr r set bez=sel7.pre||sel7.label_wert||'-'||sel7.ord::text from (
--	select * from(
--		select id, microduct_nr, rohr_id, label_wert,bez pre , sum(t) over (partition by label_wert order by rohr_id) ord from (
--			select *,  case when rn-cnt<0 then 0 else 1 end  t from (
--				select * , row_number() over (partition by rohr_id) rn from (
--					with sel as (select id knoten_id, label_wert from comsof.knoten where subtyp in('POP', 'Mini-POP/MFG' , 'GF_NVT', 'KVZ', 'Ziehschacht / Schacht an grossen Knotenpunkten'))
--						, sel2 as (select m.id, m.microduct_nr, rohr_id, label_wert, bez  from comsof.microduct m  join sel on m.knoten_anfang=sel.knoten_id order by rohr_id)
--						select * ,count(rohr_id) over (partition by rohr_id) cnt from sel2
--					) sel3
--				)sel4
--			)sel5
--		)sel6 where microduct_nr=1
--) sel7 where sel7.rohr_id=r.id;	
--
----then for drop rohr:
--update comsof.rohr r set bez=sel.source_bez||'-'||sel.brn from (	
--	select 	*,(row_number() over (partition by source_bez))::int, dns_get_alphabet_of_int((row_number() over (partition by source_bez))::int) brn from(
--		with recursive tr as (
--			(select id micro_id , rohr_id , microduct_nr,bez_wert source_bez ,0 rnk, stammt_von ,Null::int source_rohr from comsof.microduct where bez_wert is not null order by rohr_id, microduct_nr)
--			union
--			(select m.id, m.rohr_id , m.microduct_nr, tr.source_bez, tr.rnk+1 , m.stammt_von, tr.rohr_id from comsof.microduct m join tr on tr.micro_id=m.stammt_von where m.bez_wert is null and m.knoten_anfang not in (select id  from comsof.knoten where subtyp in('POP', 'Mini-POP/MFG' , 'GF_NVT', 'KVZ', 'Ziehschacht / Schacht an grossen Knotenpunkten')) order by m.rohr_id, m.microduct_nr)
--			)
--			select * from tr where rnk!=0 and microduct_nr=1	order by source_rohr
--		)sel1 order by source_bez
--)sel where /*bez is null  and*/ sel.rohr_id=r.id;
--
----then for microducts:
--update comsof.rohr r set bez=left(bez,-1)||sel.knoten_ende from (select rohr_id, knoten_ende::text from comsof.microduct  where netzebene='Verteiler/Drop' ) sel where netzebene='Verteiler/Drop' and r.id=sel.rohr_id;

	