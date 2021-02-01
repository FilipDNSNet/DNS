---- Create Schema if does not exists
create schema if not exists prj_cottbus_vortrieb;

----sample feeding   _cluster

INSERT INTO _cluster(
			id,		cluster_name, 				project_name, 	cluster_parent, 	onb_onkz, 	gemeindeschluessel, 		zubringerpunkt, 		version, 		beschreibung, 									crs_epsg,	 	schema_name)
	values(	10,		'Cottbus/ungefoerdert', 		'896', 			8,					'355',		'{12052000}', 				'POP-01',				'v_01', 		'ungefoerderte Ausbau Cottbus_ vortrieb', 					'25833',		'prj_cottbus_vortrieb');




