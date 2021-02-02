
/*
This SQL code is to convert from the intermediate tables To model_A
prerequisit:
	- C4_Project_postprocess.sql
	- P0_Model_A__Tables_.sql
	- P0_Project_PreProcess.sql
DNS GIS-Group
29-10-2020
*/

---- Knoten
INSERT INTO prj_biesenthal_kolterpfuhl.knoten (id, bez, geom, typ, subtyp, planung_status, foerdert_status, produkt_id, label_prefix, label_wert,cluster)
	select 
		uuid, bez, geom,typ,subtyp,planung_status,foerdert_status,produkt_id, label_prefix, label_wert,cluster
	from comsof.knoten;	


---- Abschlusspunkte
INSERT INTO prj_biesenthal_kolterpfuhl.abschlusspunkte (id,geom,knoten_id,typ,einbauort,homeconnect_status,cluster)
	select 
		uuid,geom,knoten_uuid,typ,einbauort,homeconnect_status,cluster
	from comsof.abschlusspunkte;	

-- in order to feed dv_abschluss the table adresse_abschluss should get feed after microducts.	
-- ---- adresse_abschluss
-- INSERT INTO prj_biesenthal_kolterpfuhl.adresse_abschluss (adresse_id, abschlusspunkte_id, cluster)
-- 	select 
-- 		adresse_id,abschlusspunkte_uuid,cluster
-- 	from comsof.adresse_abschluss;	

---- Connection_module
INSERT INTO prj_biesenthal_kolterpfuhl.connection_module (id,typ,produkt_id,knoten_id,netzebene_quelle,netzebene_ziel,eigentum_status,foerdert_status, planung_status,cluster)
	select 
		uuid,typ,produkt_id,knoten_uuid,netzebene_quelle,netzebene_ziel,eigentum_status,foerdert_status,planung_status,cluster
	from comsof.connection_module;	
	
---- connection_unit
INSERT INTO prj_biesenthal_kolterpfuhl.connection_unit(id,conn_module_id,produkt_id,letzten_datum_mod,cluster)
	select 
	uuid,conn_module_uuid,produkt_id,letzten_datum_mod,cluster
	from comsof.connection_unit;	

---- Connection_element
INSERT INTO prj_biesenthal_kolterpfuhl.connection_element(id,conn_unit_id,produkt_id,typ,subtyp,installation_ziele,installation_spalte,label,mehrdetail,cluster)
	select 
		uuid,conn_unit_uuid,produkt_id,typ,subtyp,installation_ziele,installation_spalte,label,mehrdetail,cluster
	from comsof.connection_element;	

---- Kabel
INSERT INTO prj_biesenthal_kolterpfuhl.kabel (id,bez,geom,produkt_id, anzahl_fasern,typ,netzebene,conn_module_anfang,conn_module_ende,planung_status,foerdert_status,eigentum_status,homeconnect_status,length,cluster)
	select 
		uuid,bez,geom,produkt_id, anzahl_fasern,typ,netzebene,conn_module_anfang_uuid,conn_module_ende_uuid,planung_status,foerdert_status,eigentum_status,homeconnect_status,length,cluster
	from comsof.kabel;

---- Faser
INSERT INTO prj_biesenthal_kolterpfuhl.faser (id , bez,geom,kabel_id,netzebene, buendeln_nr,faser_label,conn_element_anfang,anf_elem_output_nr,anfang_typ,anfang_label,conn_element_ende,end_elem_input_nr,ende_typ,ende_label,length,external_id,cluster)
	select 
		uuid, bez, geom,kabel_uuid,netzebene, buendeln_nr,faser_label,conn_element_anfang_uuid,anf_elem_output_nr,anfang_typ,anfang_label,conn_element_ende_uuid,end_elem_input_nr,ende_typ,ende_label,length,external_id,cluster
	from comsof.faser;	
	
---- Rohr
INSERT INTO prj_biesenthal_kolterpfuhl.rohr (id,bez,geom,typ,produkt_id, anzahl_microducts,mantel_farbe,mantel_label,planung_status,foerdert_status,netzebene,homeconnect_status,cluster)
	select 
		uuid,bez,geom,typ,produkt_id, anzahl_microducts, mantel_farbe,mantel_label,planung_status,foerdert_status,netzebene,homeconnect_status,cluster
	from comsof.rohr;

---- Microduct
INSERT INTO prj_biesenthal_kolterpfuhl.microduct(id,bez,geom,rohr_id,microduct_nr,knoten_anfang,   conn_module_anfang, conn_module_anfang_label,knoten_ende ,conn_module_ende, conn_module_ende_label,stammt_von, bottom_agg_id, zweig, kabel_id,netzebene, bez_wert,cluster) 
	select 
		uuid,bez,geom,rohr_uuid,microduct_nr,knoten_anfang_uuid, conn_module_anfang_uuid ,conn_module_anfang_label,knoten_ende_uuid, conn_module_ende_uuid, conn_module_ende_label,stammt_von_uuid, (select uuid::text from comsof.knoten kn where kn.id=bottom_agg_id::int), zweig,kabel_uuid,netzebene, bez_wert,cluster
	from comsof.microduct;

	
---- adresse_abschluss
INSERT INTO prj_biesenthal_kolterpfuhl.adresse_abschluss (adresse_id, abschlusspunkte_id, cluster)
	select 
		adresse_id,abschlusspunkte_uuid,cluster
	from comsof.adresse_abschluss;		
	
	
---- Trasse
INSERT INTO prj_biesenthal_kolterpfuhl.trasse(id,geom,typ,trassenbauverfahren,sonst_bauverfahren,verlege_tief_m,oberflaeche,widmung,foerdert_status,planung_status,homeconnect_status,netzebene,cluster)
	select 
		uuid,geom,typ,trassenbauverfahren,sonst_bauverfahren,verlege_tief_m,oberflaeche,widmung,foerdert_status,planung_status,homeconnect_status,netzebene,cluster
	from comsof.trasse;		

---- Schutzrohr
INSERT INTO prj_biesenthal_kolterpfuhl.schutzrohr (id,geom,produkt_id,foerdert_status,planung_status,aggregation_id,cluster)
	select 
		uuid,geom,produkt_id,foerdert_status,planung_status,aggregation_id,cluster
	from comsof.schutzrohr;	
	
---- rohr_schutzrohr
INSERT INTO prj_biesenthal_kolterpfuhl.rohr_schutzrohr (schutzrohr_id,rohr_id,cluster)
	select 
		schutzrohr_uuid,rohr_uuid,cluster
	from comsof.rohr_schutzrohr;
	
---- strecke
INSERT INTO prj_biesenthal_kolterpfuhl.strecke (_id,typ,cluster)
	select 
		_uuid,typ,cluster
	from comsof.strecke;	
	










