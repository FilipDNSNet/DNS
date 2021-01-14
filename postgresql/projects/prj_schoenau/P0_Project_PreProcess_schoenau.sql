---- Create Schema if does not exists
create schema /*if not exists*/ prj_test_zeuthen;

----sample feeding   _cluster
INSERT INTO _cluster(id,cluster_name, project_name, cluster_parent, onb_onkz, gemeindeschluessel, zubringerpunkt, version, beschreibung, crs_epsg, schema_name)
	values(4,'Schoenow', null, null, '3338','{12060020}', 'P01','v_01', 'FTTx Test in Schoenow', '25833','prj_schoenow');
INSERT INTO _cluster(id,cluster_name, project_name, cluster_parent, onb_onkz, gemeindeschluessel, zubringerpunkt, version, beschreibung, crs_epsg, schema_name)
	values(5,'Schoenow', '745', 4, '3338','{12060020}', 'NVT-17','v_01', 'FTTx Test in Schoenow:  NVT-17', '25833','prj_schoenow');





