	create table zusammenstellungen.eigentuemer_dallgow_temp as 
	SELECT f.ogc_fid,
		f.gml_id,
		f.wkb_geometry,
		fs.flsnr,
		fs.amtlflsfl,
		
		(	SELECT gema_shl.gemarkung FROM gema_shl WHERE (gema_shl.gemashl = fs.gemashl)
		)AS gemarkung,
		
		(	SELECT
				array_to_string((array_agg(DISTINCT ((str_shl.strname)::text || COALESCE((' '::text || (strassen.hausnr)::text), ''::text))) ||
					CASE
						WHEN (fs.lagebez IS NULL) THEN (ARRAY[fs.lagebez])::text[]
						ELSE '{}'::text[]
					END), ''::text) AS array_to_string
			FROM (strassen LEFT JOIN str_shl ON ((strassen.strshl = str_shl.strshl)))
			WHERE ((strassen.flsnr = (fs.flsnr)::bpchar) AND (strassen.ff_stand = 0))
		)AS adressen,
			   
		(	SELECT 
				array_to_string(array_agg(DISTINCT ea.bestdnr), ''::text) AS array_to_string
			FROM eignerart ea
			WHERE ((ea.flsnr = (fs.flsnr)::bpchar) AND (ea.ff_stand = 0))
		)AS bestaende,
			  
		( SELECT 
			array_to_string(array_agg(DISTINCT ((((e.name1)::text || COALESCE((', '::text || (e.name2)::text), ''::text)) 
				|| COALESCE((', '::text || (e.name3)::text), ''::text)) || COALESCE((', '::text 
				|| (e.name4)::text), ''::text))), ''::text) AS array_to_string
			FROM (eignerart ea JOIN eigner e ON (((ea.bestdnr = e.bestdnr) AND (e.ff_stand = 0))))
			WHERE ((ea.flsnr = (fs.flsnr)::bpchar) AND (ea.ff_stand = 0))
		)AS eigentuemer
				
	FROM (ax_flurstueck f JOIN flurst fs ON (((fs.ff_stand = 0) AND ((alkis_flsnr(f.*))::text = (fs.flsnr)::text))))
	WHERE  f.gemarkungsnummer in ('3419','3857','8422') and (f.endet IS NULL)
	GROUP BY f.ogc_fid, f.gml_id, f.wkb_geometry, fs.flsnr, fs.gemashl, fs.lagebez, fs.amtlflsfl;
	
	
	select * from zusammenstellungen.eigentuemer_falkensee_temp where eigentuemer <> '(mehrere)'
	select  *from zusammenstellungen.eigentuemer_dallgow_temp where eigentuemer <> '(mehrere)'