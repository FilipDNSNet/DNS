--  Deployed changes on the database.
--  
--  Thesse chamges are made to clean the database and organize the structure of adresses.
--  
--  They are deloyed whern we were adding some columns to the table "adressen.adressen"
--  
--  DNS-Net GIS Team
--  10-02-2020



-----------------------------------------------------------------------------------------
-- creation of som tables:
drop table basisdaten.zusammengestellten_gemeinden;
create table basisdaten.zusammengestellten_gemeinden (gem_nr varchar(8) primary key , gem_name text, bundesland text, geom geometry(geometry, 4326));
create index inx_basisdaten_zusammengestellten_gemeinden_geom on basisdaten.zusammengestellten_gemeinden using gist(geom);
create index inx_basisdaten_zusammengestellten_gemeinden_gemname on basisdaten.zusammengestellten_gemeinden(gem_name);

insert into basisdaten.zusammengestellten_gemeinden
		select vsn_klar gem_nr ,gn_alias gem_name, 'Sachsen_Anhalt' bundesland, st_transform(geom, 4326) goem from basisdaten.st_gemeinde
	union all 
		select  nr gem_nr, name gem_name , 'Brandenburg' bundesland, st_transform(geom, 4326) from basisdaten.brb_gemeinden
	order by gem_name;



drop table basisdaten.zusammengestellten_kreise;
create table basisdaten.zusammengestellten_kreise (kr_nr varchar(8) primary key , kr_name text, bundesland text, geom geometry(geometry, 4326));
create index inx_basisdaten_zusammengestellten_kreise_geom on basisdaten.zusammengestellten_kreise using gist(geom);
create index inx_basisdaten_zusammengestellten_kreise_krname on basisdaten.zusammengestellten_kreise(kr_name);

insert into basisdaten.zusammengestellten_kreise
		select vsn_klar::integer kr_nr, gn_klar kr_name, 'Sachsen_Anhalt' bundesland, st_transform(geom, 4326) goem from basisdaten.st_landkreise_und_kreisfreie_staedte
	union all 
		select left(nr, 5)::integer kr_nr, name kr_name, 'Brandenburg' bundesland ,st_transform(geom, 4326) geom from basisdaten.brb_landkreise 
	order by kr_name;
	
-----------------------------------------------------------------------------------------
-- Drop Triggers :
drop TRIGGER IF EXISTS tr_adressen_beforeupdate_fill_xy on adressen.adressen;
DROP FUNCTION IF EXISTS tr_adressen_beforeupdate_fill_xy;

drop TRIGGER IF EXISTS tr_adressen_before_insert_setid on adressen.adressen;
DROP FUNCTION IF EXISTS tr_adressen_before_insert_setid;

drop TRIGGER IF EXISTS tr_adressen_before_insert on adressen.adressen;
DROP FUNCTION IF EXISTS tr_adressen_before_insert;

drop TRIGGER IF EXISTS tr_dv_abschluss_before_update on view_b_bb.dv_abschluss;
drop TRIGGER IF EXISTS tr_dv_abschluss_before_update on view_st.dv_abschluss;
DROP FUNCTION IF EXISTS tr_dv_abschluss_before_update;


drop TRIGGER IF EXISTS tr_prj_test_eichwalde_adresseabschluss_delete_on_dvabschluss on prj_test_eichwalde.adresse_abschluss;
DROP FUNCTION IF EXISTS tr_prj_test_eichwalde_adresseabschluss_delete_on_dvabschluss;

drop TRIGGER IF EXISTS tr_prj_test_eichwalde_adresseabschluss_insert_on_dvabschluss on prj_test_eichwalde.adresse_abschluss;
DROP FUNCTION IF EXISTS tr_prj_test_eichwalde_adresseabschluss_insert_on_dvabschluss;

drop TRIGGER IF EXISTS tr_prj_test_zeuthen_adresseabschluss_delete_on_dvabschluss on prj_test_zeuthen.adresse_abschluss;
DROP FUNCTION IF EXISTS tr_prj_test_zeuthen_adresseabschluss_delete_on_dvabschluss;

drop TRIGGER IF EXISTS tr_prj_test_zeuthen_adresseabschluss_insert_on_dvabschluss on prj_test_zeuthen.adresse_abschluss;
DROP FUNCTION IF EXISTS tr_prj_test_zeuthen_adresseabschluss_insert_on_dvabschluss;

drop trigger if exists tr_adressen_before_update_insert_fill_xy on adressen.adressen;
drop function if exists tr_adressen_before_update_insert_fill_xy cascade; 

drop trigger if exists tr_adresse_abschluss_before_delete on adressen.adressen;
drop  function if exists tr_adresse_abschluss_before_delete cascade;

drop trigger if exists tr_adresse_aftert_insert_copyon_adresseabschluss on adressen.adressen;
drop function if exists tr_adresse_aftert_insert_copyon_adresseabschluss cascade;

DROp TRIGGER IF EXISTS  tr_adressen_adressechecked on adressen.adressen;
drop function if exists tr_adressen_adressechecked;

drop trigger if exists tr_adressen_insert_dv on adressen.adressen;
drop function if exists tr_adressen_insert_dv cascade;

DROp TRIGGER IF EXISTS  tr_adressen_nechecked on adressen.adressen;
drop function if exists tr_adressen_nechecked;

--drop TRIGGER IF EXISTS tr_XX on adressen.XX;
--DROP FUNCTION IF EXISTS tr_XX;


-----------------------------------------------------------------------------------------
-- drop rules:
DROP RULE IF EXISTS rule_adressen_update_effectson_adresse_abschluss ON adressen.adressen;

DROP RULE IF EXISTS rule_adressen_update_on_dv_prj_test_eichwalde ON adressen.adressen;

DROP RULE IF EXISTS rule_adressen_update_on_dv_prj_test_zeuthen ON adressen.adressen;

DROP RULE IF EXISTS rule_geometryadresse25832_insert ON adressen._geometry_adresse_25832;
Drop rule if exists rule_geometryadresse25832_update_1 on adressen._geometry_adresse_25832;
Drop rule if exists rule_geometryadresse25832_update_2 on adressen._geometry_adresse_25832;

DROP RULE IF EXISTS rule_geometryadresse25832_insert ON adressen._geometry_adresse_25833;
Drop rule if exists rule_geometryadresse25832_update_1 on adressen._geometry_adresse_25833;
Drop rule if exists rule_geometryadresse25832_update_2 on adressen._geometry_adresse_25833;
	
--DROP RULE IF EXISTS XX ON adressen.adressen;
--
--DROP RULE IF EXISTS XX ON adressen.XX;
--
--DROP RULE IF EXISTS XX ON adressen.XX;
--
--DROP RULE IF EXISTS XX ON adressen.XX;

-----------------------------------------------------------------------------------------
-- Drop tables:
DROP TABLE IF EXISTS _geometry_adresse_25833;
DROP TABLE IF EXISTS _geometry_adresse_25832;

-----------------------------------------------------------------------------------------
-- Drop Schemas:
DROP SCHEMA IF EXISTs view_b_bb cascade;
DROP SCHEMA IF EXISTS view_st;
