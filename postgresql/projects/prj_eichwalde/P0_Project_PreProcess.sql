/*
It creates and prepare the schema for each project

prerequisites:
	- 01_Enums_Domains.sql
	- 01_Functions_and_triggers.sql


16-10-2020
DNSNet GIS-Group*/


---- Create Schema if does not exists
create schema if not exists prj_test_eichwalde;

----sample feeding   _cluster
INSERT INTO _cluster(id,cluster_name, project_name, cluster_parent, onb_onkz, gemeindeschluessel, zubringerpunkt, version, beschreibung, crs_epsg, schema_name)
	values(0,'eichwalde_pop_01', '#296_2020', Null, '33762','{12061112}', 'P01','v_01', 'FTTx Test in Eichwalde', '25833',null);
INSERT INTO _cluster(id,cluster_name, project_name, cluster_parent, onb_onkz, gemeindeschluessel, zubringerpunkt, version, beschreibung, crs_epsg, schema_name)
	values(1,'eichwalde_pop_01/teil_1', '#423_2020', 0, '33762','{12061112}', 'P01', 'v_01', 'Sub-pojekt', '25833', 'prj_test_eichwalde');
	


---- Create Schema if does not exists
--create schema /*if not exists*/ prj_test_zeuthen;

----sample feeding   _cluster
--INSERT INTO _cluster(id,cluster_name, project_name, cluster_parent, onb_onkz, gemeindeschluessel, zubringerpunkt, version, beschreibung, crs_epsg, schema_name)
--	values(2,'zeuthen', '#xxx_2020', Null, '033762','{12061572}', 'P01','v_01', 'FTTx Test in Zeuthen', '25833',null);
--INSERT INTO _cluster(id,cluster_name, project_name, cluster_parent, onb_onkz, gemeindeschluessel, zubringerpunkt, version, beschreibung, crs_epsg, schema_name)
--	values(3,'zeuthen/los_1', '#xxx_2020', 2, '033762','{12061572}', 'P01','v_01', 'FTTx Test in Zeuthen', '25833','prj_test_zeuthen');













