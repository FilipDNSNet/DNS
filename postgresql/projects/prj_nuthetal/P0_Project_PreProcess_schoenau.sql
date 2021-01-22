---- Create Schema if does not exists
create schema /*if not exists*/ prj_nuthetal;

----sample feeding   _cluster
INSERT INTO _cluster(id, cluster_name, project_name, cluster_parent, onb_onkz, gemeindeschluessel, zubringerpunkt, version, beschreibung, crs_epsg, schema_name)
	values(6, 'Nuthehal', null, null, '33205','{12069454}', 'BB_unknown','v_01', 'FTTx projects in Nuthehal', '25833',null);
INSERT INTO _cluster(id,cluster_name, project_name, cluster_parent, onb_onkz, gemeindeschluessel, zubringerpunkt, version, beschreibung, crs_epsg, schema_name)
	values(7,'Nuthehal/Tremsdorf', '786', 6, '33205','{12069454}', 'M33200/02','v_01', 'Nuthehal/Tremsdorf  NVT 001 and 002', '25833','prj_nuthetal');





