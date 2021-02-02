---- Create Schema if does not exists
create schema if not exists prj_biesenthal_kolterpfuhl;

----sample feeding   _cluster
INSERT INTO _cluster(
			id,	 	cluster_name, 		project_name, 			cluster_parent, 	onb_onkz, 		gemeindeschluessel,			zubringerpunkt, 	version, 		beschreibung, 					crs_epsg, 		schema_name)
	values(	11, 		'Biesenthal', 			null, 					null, 				'3337',			'{12060024}', 				'BB_unknown',		'v_01', 		'FTTh projects in Biesenthal_kolterpfuhl', 	'25833',		null);
INSERT INTO _cluster(
			id,		cluster_name, 				project_name, 	cluster_parent, 	onb_onkz, 	gemeindeschluessel, 		zubringerpunkt, 		version, 		beschreibung, 									crs_epsg,	 	schema_name)
	values(	12,		'Biesenthal/Kolterpfuhl', 		'0623', 			11,					'3337',		'{12060024}', 				'POP-01',				'v_01', 		'Neubau gebiet biesenthal_kolterpfuhl', 					'25833',		'prj_biesenthal_kolterpfuhl');
	