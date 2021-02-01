---- Create Schema if does not exists
create schema /*if not exists*/ prj_cottbus;

----sample feeding   _cluster
INSERT INTO _cluster(
			id,	 	cluster_name, 		project_name, 			cluster_parent, 	onb_onkz, 		gemeindeschluessel,			zubringerpunkt, 	version, 		beschreibung, 					crs_epsg, 		schema_name)
	values(	8, 		'Cottbus', 			null, 					null, 				'355',			'{12052000}', 				'BB_unknown',		'v_01', 		'FTTh projects in Cottbus', 	'25833',		null);
INSERT INTO _cluster(
			id,		cluster_name, 				project_name, 	cluster_parent, 	onb_onkz, 	gemeindeschluessel, 		zubringerpunkt, 		version, 		beschreibung, 									crs_epsg,	 	schema_name)
	values(	9,		'Cottbus/gefoerdert', 		'896', 			8,					'355',		'{12052000}', 				'POP-01',				'v_01', 		'gefoerderte Ausbau Cottbus', 					'25833',		'prj_cottbus');




