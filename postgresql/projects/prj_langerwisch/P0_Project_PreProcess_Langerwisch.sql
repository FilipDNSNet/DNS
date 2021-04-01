---- Create Schema if does not exists
create schema /*if not exists*/ prj_langerwisch;

----sample feeding   _cluster


INSERT INTO _cluster(id, cluster_name, project_name, cluster_parent, onb_onkz, gemeindeschluessel, zubringerpunkt, version, beschreibung, crs_epsg, schema_name)
	values(13, 'Michendorf', null, null, '332058','{12069397}', 'BB_unknown','v_01', 'FTTx projects in Michendorf', '25833',null);
INSERT INTO _cluster(id,cluster_name, project_name, cluster_parent, onb_onkz, gemeindeschluessel, zubringerpunkt, version, beschreibung, crs_epsg, schema_name)
	values(14,'Michendorf/Langerwisch', '797', 13, '33205','{12069397}', 'BB_unknown','v_01', 'Michendorf/Langerwisch', '25833','prj_langerwisch');