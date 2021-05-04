prj_fresdorf.db_cluster
prj_fresdorf.adressen
prj_fresdorf.gpk_knoten
prj_fresdorf.gpk_abschlusspunkte
prj_fresdorf.gpk_connection_module
prj_fresdorf.gpk_connection_unit
prj_fresdorf.gpk_connection_element
prj_fresdorf.gpk_kabel
prj_fresdorf.gpk_faser
prj_fresdorf.gpk_rohr
prj_fresdorf.gpk_microduct 
prj_fresdorf.gpk_trasse
prj_fresdorf.gpk_schutzrohr

prj_fresdorf.gpk_rohr_schutzrohr
prj_fresdorf.gpk_adresse_abschluss



DROP TABLE prj_fresdorf.db_cluster;
DROP TABLE prj_fresdorf.adressen;
DROP TABLE prj_fresdorf.gpk_knoten;
DROP TABLE prj_fresdorf.gpk_abschlusspunkte;
DROP TABLE prj_fresdorf.gpk_connection_module;
DROP TABLE prj_fresdorf.gpk_connection_unit;
DROP TABLE prj_fresdorf.gpk_connection_element;
DROP TABLE prj_fresdorf.gpk_kabel;
DROP TABLE prj_fresdorf.gpk_faser;
DROP TABLE prj_fresdorf.gpk_rohr;
DROP TABLE prj_fresdorf.gpk_microduct;
DROP TABLE prj_fresdorf.gpk_trasse;
DROP TABLE prj_fresdorf.gpk_schutzrohr;
DROP TABLE prj_fresdorf.gpk_rohr_schutzrohr;
DROP TABLE prj_fresdorf.gpk_adresse_abschluss;





create table prj_fresdorf.db_cluster as select * from _cluster where id in (select destination_cluster from comsof.comsof_metadata);-- for geopackage.

create table prj_fresdorf.adressen as 
	select id, alkis_id , plz, strasse , hausnr, adresszusatz, ortsnetzbereiche, vid, typ, bundesland, gemeinde_name, ortsteil, ort, funktion, anzahl_wohneinheit, anzahl_gewerbeeinheit, anzahl_nutzeinheit, verifizierungstyp , geom from adressen.adressen
		where id in (select adresse_id from prj_fresdorf.adresse_abschluss);
		
create table prj_fresdorf.gpk_knoten as
	select obj.fid, targ.bez, targ.geom, targ.typ, targ.subtyp, targ.foerdert_status, targ.planung_status, targ.produkt_id, targ.cluster db_cluster, null expln from prj_fresdorf.knoten targ join prj_fresdorf.exchange_oid obj on targ.id=obj.uuid;
	
	
	
create table prj_fresdorf.gpk_abschlusspunkte as
	select obj.fid, targ.geom, null knoten_id, targ.typ, targ.einbauort, targ.cluster db_cluster , knoten_id expln from prj_fresdorf.abschlusspunkte targ join prj_fresdorf.exchange_oid obj on targ.id=obj.uuid;
update prj_fresdorf.gpk_abschlusspunkte ab set knoten_id = sel.fid from prj_fresdorf.exchange_oid sel where uuid(ab.expln)=sel.uuid;
update prj_fresdorf.gpk_abschlusspunkte set expln=null;


create table prj_fresdorf.gpk_connection_module as
	select obj.fid, targ.typ, targ.produkt_id, null knoten_id, targ.netzebene_quelle, targ.netzebene_ziel, targ.eigentum_status ,targ.foerdert_status, targ.planung_status,  targ.cluster db_cluster, knoten_id expln from prj_fresdorf.connection_module targ join prj_fresdorf.exchange_oid obj on targ.id=obj.uuid;
update prj_fresdorf.gpk_connection_module ab set knoten_id = sel.fid from prj_fresdorf.exchange_oid sel where uuid(ab.expln)=sel.uuid;
update prj_fresdorf.gpk_connection_module set expln=null;

create table prj_fresdorf.gpk_connection_unit as
	select obj.fid,  null conn_module_id , targ.produkt_id, targ.cluster db_cluster, conn_module_id expln 
		from prj_fresdorf.connection_unit targ join prj_fresdorf.exchange_oid obj on targ.id=obj.uuid;
update prj_fresdorf.gpk_connection_unit ab set conn_module_id = sel.fid from prj_fresdorf.exchange_oid sel where uuid(ab.expln)=sel.uuid;
update prj_fresdorf.gpk_connection_unit set expln=null;

create table prj_fresdorf.gpk_connection_element as
	select obj.fid,  null conn_unit_id, targ.produkt_id, targ.typ, targ.subtyp, targ.installation_ziele installation_zeile, targ.installation_spalte, targ.label, targ.mehrdetail, targ.cluster db_cluster , conn_unit_id expln 
		from prj_fresdorf.connection_element targ join prj_fresdorf.exchange_oid obj on targ.id=obj.uuid;
update prj_fresdorf.gpk_connection_element ab set conn_unit_id = sel.fid from prj_fresdorf.exchange_oid sel where uuid(ab.expln)=sel.uuid;
update prj_fresdorf.gpk_connection_element set expln=null;


create table prj_fresdorf.gpk_kabel as
	select obj.fid,
		targ.bez,
		targ.geom,
		targ.produkt_id,
		targ.anzahl_fasern,
		targ.netzebene,
		null conn_module_anfang,
		targ.conn_module_anfang t1,
		null conn_module_ende,
		targ.conn_module_ende t2,
		targ.foerdert_status,
		targ.planung_status,
		targ.eigentum_status,
		targ.length,		
		targ.cluster db_cluster, 
		null expln 
		from prj_fresdorf.kabel targ join prj_fresdorf.exchange_oid obj on targ.id=obj.uuid;
update prj_fresdorf.gpk_kabel ab set conn_module_anfang = sel.fid from prj_fresdorf.exchange_oid sel where uuid(ab.t1)=sel.uuid;
update prj_fresdorf.gpk_kabel ab set conn_module_ende = sel.fid from prj_fresdorf.exchange_oid sel where uuid(ab.t2)=sel.uuid;
alter table prj_fresdorf.gpk_kabel drop column t1;
alter table prj_fresdorf.gpk_kabel drop column t2;	


create table prj_fresdorf.gpk_faser as
	select obj.fid,
		targ.bez,
		targ.geom,
		null kabel_id,
		targ.kabel_id t0,
		targ.netzebene,
		targ.buendeln_nr,
		null conn_element_anfang,
		targ.conn_element_anfang t1,
		targ.anf_elem_output_nr,
		targ.anfang_typ,
		targ.anfang_label,
		null conn_element_ende,
		targ.conn_element_ende t2,
		targ.end_elem_input_nr,
		targ.ende_typ,
		targ.ende_label,
		targ.length,		
		targ.cluster db_cluster, 
		null expln 
		from prj_fresdorf.faser targ join prj_fresdorf.exchange_oid obj on targ.id=obj.uuid;
update prj_fresdorf.gpk_faser ab set kabel_id = sel.fid from prj_fresdorf.exchange_oid sel where uuid(ab.t0)=sel.uuid;
update prj_fresdorf.gpk_faser ab set conn_element_anfang = sel.fid from prj_fresdorf.exchange_oid sel where uuid(ab.t1)=sel.uuid;
update prj_fresdorf.gpk_faser ab set conn_element_ende = sel.fid from prj_fresdorf.exchange_oid sel where uuid(ab.t2)=sel.uuid;
alter table prj_fresdorf.gpk_faser drop column t0;
alter table prj_fresdorf.gpk_faser drop column t1;
alter table prj_fresdorf.gpk_faser drop column t2;	
	
create table prj_fresdorf.gpk_rohr as
	select obj.fid,
		targ.bez,
		targ.geom,
		targ.typ,
		targ.produkt_id,
		targ.anzahl_microducts,
		targ.mantel_farbe,
		targ.mantel_label,
		targ.foerdert_status,
		targ.planung_status,
		targ.netzebene,
		targ.cluster db_cluster, 
		null expln 
		from prj_fresdorf.rohr targ join prj_fresdorf.exchange_oid obj on targ.id=obj.uuid;
		
		
create table prj_fresdorf.gpk_microduct as
	select obj.fid,
		targ.bez,
		targ.geom,
		null rohr_id,
		targ.rohr_id t0,
		targ.microduct_nr,
		null knoten_anfang,
		targ.knoten_anfang t1,
		null conn_module_anfang,
		targ.conn_module_anfang t2,
		targ.conn_module_anfang_label,
		null knoten_ende,
		targ.knoten_ende t3,
		null conn_module_ende,
		targ.conn_module_ende t4,
		targ.conn_module_ende_label,
		null stammt_von,
		targ.stammt_von t5,
		null bottom_agg_id,
		targ.bottom_agg_id t6,
		null kabel_id,
		targ.kabel_id t7,
		targ.netzebene,
		targ.cluster db_cluster, 
		null expln 
		from prj_fresdorf.microduct targ join prj_fresdorf.exchange_oid obj on targ.id=obj.uuid;
update prj_fresdorf.gpk_microduct ab set rohr_id = sel.fid from prj_fresdorf.exchange_oid sel where uuid(ab.t0)=sel.uuid;
update prj_fresdorf.gpk_microduct ab set knoten_anfang = sel.fid from prj_fresdorf.exchange_oid sel where uuid(ab.t1)=sel.uuid;
update prj_fresdorf.gpk_microduct ab set conn_module_anfang = sel.fid from prj_fresdorf.exchange_oid sel where uuid(ab.t2)=sel.uuid;
update prj_fresdorf.gpk_microduct ab set knoten_ende = sel.fid from prj_fresdorf.exchange_oid sel where uuid(ab.t3)=sel.uuid;
update prj_fresdorf.gpk_microduct ab set conn_module_ende = sel.fid from prj_fresdorf.exchange_oid sel where uuid(ab.t4)=sel.uuid;
update prj_fresdorf.gpk_microduct ab set stammt_von = sel.fid from prj_fresdorf.exchange_oid sel where uuid(ab.t5)=sel.uuid;
update prj_fresdorf.gpk_microduct ab set bottom_agg_id = sel.fid from prj_fresdorf.exchange_oid sel where uuid(ab.t6)=sel.uuid;
update prj_fresdorf.gpk_microduct ab set kabel_id = sel.fid from prj_fresdorf.exchange_oid sel where uuid(ab.t7)=sel.uuid;
alter table prj_fresdorf.gpk_microduct drop column t0;
alter table prj_fresdorf.gpk_microduct drop column t1;
alter table prj_fresdorf.gpk_microduct drop column t2;	
alter table prj_fresdorf.gpk_microduct drop column t3;
alter table prj_fresdorf.gpk_microduct drop column t4;
alter table prj_fresdorf.gpk_microduct drop column t5;	
alter table prj_fresdorf.gpk_microduct drop column t6;
alter table prj_fresdorf.gpk_microduct drop column t7;		
		

create table prj_fresdorf.gpk_trasse as
	select obj.fid,
		targ.geom,
		targ.typ,
		targ.trassenbauverfahren,
		targ.verlege_tief_m,
		targ.oberflaeche,
		targ.widmung,
		targ.foerdert_status,
		targ.planung_status,
		targ.netzebene,
		targ.cluster db_cluster, 
		null expln 
		from prj_fresdorf.trasse targ join prj_fresdorf.exchange_oid obj on targ.id=obj.uuid;
		
		
create table prj_fresdorf.gpk_schutzrohr as
	select obj.fid,
		targ.geom,
		targ.produkt_id,
		targ.foerdert_status,
		targ.planung_status,
		targ.aggregation_id,
		targ.cluster db_cluster, 
		null expln 
		from prj_fresdorf.schutzrohr targ join prj_fresdorf.exchange_oid obj on targ.id=obj.uuid;		

create table prj_fresdorf.gpk_rohr_schutzrohr as
	select 
		null schutzrohr_id,
		targ.schutzrohr_id t0,
		null rohr_id,
		targ.rohr_id t1,
		targ.cluster db_cluster, 
		null expln 
		from prj_fresdorf.rohr_schutzrohr targ;
update prj_fresdorf.gpk_rohr_schutzrohr ab set schutzrohr_id = sel.fid from prj_fresdorf.exchange_oid sel where uuid(ab.t0)=sel.uuid;
update prj_fresdorf.gpk_rohr_schutzrohr ab set rohr_id = sel.fid from prj_fresdorf.exchange_oid sel where uuid(ab.t1)=sel.uuid;
alter table prj_fresdorf.gpk_rohr_schutzrohr drop column t0;
alter table prj_fresdorf.gpk_rohr_schutzrohr drop column t1;

create table prj_fresdorf.gpk_adresse_abschluss as
	select 
		targ.adresse_id,
		obj.fid abschlusspunkte_id,
		targ.cluster db_cluster, 
		null expln 
		from prj_fresdorf.adresse_abschluss targ join prj_fresdorf.exchange_oid obj on targ.abschlusspunkte_id=obj.uuid;
		


