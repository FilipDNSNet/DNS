/*-- The sql queries to test the new changes made to create the dynamic view of  bb.alkis.zusammenstellung.dv_fluerstueck.
--DNS-Net GIT team
--18-01-2021*/

-- Wanted:    -----------------------------------------------------------------------------------------------------------------------------

select  distinct on (ax_flurstueck.gml_id) ax_flurstueck.gml_id,
	ax_flurstueck.ogc_fid,
	ax_flurstueck.flurstueckskennzeichen,
	v_eigentuemer.flsnr,
	ax_flurstueck.gemarkungsnummer,
	v_eigentuemer.gemarkung,
	ax_flurstueck.flurnummer,
	ax_flurstueck.nenner,
	ax_flurstueck.zaehler, 
	ax_flurstueck.weistauf,
	v_eigentuemer.adressen,
	v_eigentuemer.eigentuemer,
	gem_shl.gemname as "gemeinde",
	ax_flurstueck.wkb_geometry
from public.ax_flurstueck
	right join v_eigentuemer on ax_flurstueck.gml_id = v_eigentuemer.gml_id
	right join ax_gemarkung on ax_flurstueck.gemarkungsnummer = ax_gemarkung.gemarkungsnummer
	right join gema_shl on ax_gemarkung.schluesselgesamt = gema_shl.gemashl
	right join gem_shl on gema_shl.gemshl = gem_shl.gemshl



------------------------

new._ogc_fid_					
new._gml_id						
new._flurstueckskennzeichen_ 	
new._flsnr_						
new._gemarkungsnummer_ 			
new._gemarkung_					
new._flurnummer_ 				
new._nenner_ 					
new._zaehler_					
new._weistauf_ 					
new._adressen_ 					
new._eigentuemer_				
new._gemname_					
new._geom_ 						
new._trig			

-- v_eigentuemer:    -----------------------------------------------------------------------------------------------------------------------------

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
	WHERE (f.endet IS NULL)
	GROUP BY f.ogc_fid, f.gml_id, f.wkb_geometry, fs.flsnr, fs.gemashl, fs.lagebez, fs.amtlflsfl;

--------------------------------------------------------------------------------------------------------------------------------------------------------  
  
  --Tables:
	gema_shl:	1429
	gem_shl:	271
	strassen:	1970975
	str_shl:	51243
	eignerart:	2085287
	eigner:		883699
	ax_flurstueck	2078399
	flurst:			2076885
	
	
	--generated sample date
ogc_fid: 1     flsnr: 122953-011-00970/000  lagebez:null
10	122955-008-00961/000 null
519795	120101-001-00236/000 Pumpergraben




--	Table:			n_entities:	used columns:
--	gema_shl:		1429		(gemashl, gemarkung)
--	gem_shl:		271			(gemname)
--	strassen:		1970975		(flsnr, ff_stand)
--	str_shl:		51243		(strshl, strname)
--	eignerart:		2085287		(flsnr, ff_stand)
--	eigner:			883699		(name1, name2, name3, name4, bestdnr, ff_stand)
--	ax_flurstueck	2078399 	()
--	flurst:			2076885		(flsnr , ff_stand, amtlflsfl, lagebez, gemashl)
			