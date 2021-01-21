--This query was written to update ne we ge values for the gemeinde  with the given shapefile from michael. It ended to match 96%. 
-- DNS-NET Gis Team
-- 19.01.2021

--  select id id_ad, plz, replace(lower(replace(strasse, ' ', '')) , 'straße', 'str')strasse_ad, hausnr||coalesce(adresszusatz,'') hausnr_ad , geom geom_ad from adressen.adressen where gemeinde_schluessel='15083415'
--  
--  select sel.*, (select id wid from we_ge where st_distance(we_ge.geom, sel.geom_ad)<.5 order by st_distance(we_ge.geom, sel.geom_ad) limit 1 ) from
--  	(
--  	select id id_ad, plz, replace(lower(replace(strasse, ' ', '')) , 'straße', 'str')strasse_ad, hausnr||coalesce(adresszusatz,'') hausnr_ad , geom geom_ad from adressen.adressen where gemeinde_schluessel='15083415'
--  	) sel
--   
--   
--   
--  select sel1.* , (select replace(lower(replace(strasse, ' ', '')) , 'straße', 'str')||hausnr from we_ge where we_ge.id=sel1.wid) from 
--  	(
--  		select * from tt
--  		--select sel.*, (select id wid from we_ge where st_distance(we_ge.geom, sel.geom_ad)<.5 order by st_distance(we_ge.geom, sel.geom_ad) limit 1 ) from
--  		--	(
--  		--	select id id_ad, plz, replace(lower(replace(strasse, ' ', '')) , 'straße', 'str')strasse_ad, hausnr||coalesce(adresszusatz,'') hausnr_ad , geom geom_ad from adressen.adressen where gemeinde_schluessel='15083415'
--  		--	) sel
--  		) sel1
--  
--  
--  select * from we_ge
--  
--  
--  select * from 
--  (
--  	select sel1.* , (select replace(  plz||replace(lower(replace(strasse, ' ', '')) , 'straße', 'str')  ||lower(hausnr), '.', '') from we_ge where we_ge.id=sel1.wid) schl_wege from 
--  		(
--  			select * from tt
--  			--select sel.*, (select id wid from we_ge where st_distance(we_ge.geom, sel.geom_ad)<.5 order by st_distance(we_ge.geom, sel.geom_ad) limit 1 ) from
--  			--	(
--  			--	select id id_ad, plz, replace(lower(replace(strasse, ' ', '')) , 'straße', 'str')strasse_ad, hausnr||coalesce(adresszusatz,'') hausnr_ad , geom geom_ad from adressen.adressen where gemeinde_schluessel='15083415'
--  			--	) sel
--  			) sel1
--  ) sel2 where schl_wege= plz||strasse_ad||hausnr_ad	
--  
--  
--  
--  
--  
--  ALTER TABLE we_ge add column adresse_id uuid;
--  
--  update we_ge set adresse_id=sel3.id_ad from 
--  	(
--  		SELECT * FROM 
--  		(
--  			select sel1.* , (select replace(  plz||replace(lower(replace(strasse, ' ', '')) , 'straße', 'str')  ||lower(hausnr), '.', '') from we_ge where we_ge.id=sel1.wid) schl_wege from 
--  				(
--  					select sel.*, (select id wid from we_ge where st_distance(we_ge.geom, sel.geom_ad)<.5 order by st_distance(we_ge.geom, sel.geom_ad) limit 1 ) from
--  						(
--  						select id id_ad, plz, replace(lower(replace(strasse, ' ', '')) , 'straße', 'str')strasse_ad, hausnr||coalesce(lower(adresszusatz),'') hausnr_ad , geom geom_ad from adressen.adressen where gemeinde_schluessel='15083415'
--  						) sel
--  					) sel1
--  		) sel2 where schl_wege= plz||strasse_ad||lower(hausnr_ad)	
--  	) sel3 where sel3.wid=we_ge.id
--  	
--  
--  select * from  adressen.adressen where gemeinde_schluessel='15083415'
--  	
--  update adressen.adressen  set anzahl_wohneinheit= sel.we , anzahl_gewerbeeinheit=sel.ge, anzahl_nutzeinheit=sel.ne from
--  	(select * from we_ge) sel
--  	where gemeinde_schluessel='15083415' and adressen.adressen.id=sel.adresse_idupdate adressen.adressen  set anzahl_wohneinheit= sel.we , anzahl_gewerbeeinheit=sel.ge, anzahl_nutzeinheit=sel.ne from
--   	(select * from we_ge) sel
--   	where gemeinde_schluessel='15083415' and adressen.adressen.id=sel.adresse_id
--  
--  	
--  	select * from we_ge where adresse_id is not null
--  	
--  	
--  select * from  adressen.adressen where gemeinde_schluessel='15083415' and anzahl_wohneinheit is null
--  
--  
--  select *  from  
--  
--  
--  select * from (
--  	select *,  plz||strasse_ad||lower(hausnr_ad) schl_ad , plz||strasse_ad||lower(hausnr_ad)= schl_wege ky from 
--  	(
--  		select sel1.* , (select replace(  plz||replace(lower(replace(strasse, ' ', '')) , 'straße', 'str')  ||lower(hausnr), '.', '') from we_ge where we_ge.id=sel1.wid) schl_wege from 
--  			(
--  				select * from tt
--  				--select sel.*, (select id wid from we_ge where st_distance(we_ge.geom, sel.geom_ad)<.5 order by st_distance(we_ge.geom, sel.geom_ad) limit 1 ) from
--  				--	(
--  				--	select id id_ad, plz, replace(lower(replace(strasse, ' ', '')) , 'straße', 'str')strasse_ad, hausnr||coalesce(adresszusatz,'') hausnr_ad , geom geom_ad from adressen.adressen where gemeinde_schluessel='15083415'
--  				--	) sel
--  				) sel1
--  	) sel2 
--  ) sel3 where ky=False
--  
--  
---------------------------------------------------------------------------------------------------------------------------------
--   Executed :

-- first import the shapefile to the database dns-net_geodb table we_ge


update we_ge set adresse_id=sel3.id_ad from 
	(
		SELECT * FROM 
		(
			select sel1.* , (select replace(  plz||replace(lower(replace(strasse, ' ', '')) , 'straße', 'str')  ||lower(hausnr), '.', '') from we_ge where we_ge.id=sel1.wid) schl_wege from 
				(
					select sel.*, (select id wid from we_ge where st_distance(we_ge.geom, sel.geom_ad)<.5 order by st_distance(we_ge.geom, sel.geom_ad) limit 1 ) from
						(
						select id id_ad, plz, replace(lower(replace(strasse, ' ', '')) , 'straße', 'str')strasse_ad, hausnr||coalesce(lower(adresszusatz),'') hausnr_ad , geom geom_ad from adressen.adressen where gemeinde_schluessel='15083415'
						) sel
					) sel1
		) sel2 where schl_wege= plz||strasse_ad||lower(hausnr_ad)	
	) sel3 where sel3.wid=we_ge.id
	
	
update adressen.adressen ad set anzahl_wohneinheit= sel.we , anzahl_gewerbeeinheit=sel.ge, anzahl_nutzeinheit=sel.ne from
	(select * from we_ge) sel
	where gemeinde_schluessel='15083415' and ad.id=uuid(sel.adresse_id)
	
	
select * from  adressen.adressen where gemeinde_schluessel='15083415' and anzahl_wohneinheit is null

---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
-- For  Gemeinde Barleben(15083040) in Sachsen_anhalt

-- first inport the shape file in adressen.we_ge 

ALTER TABLE we_ge add column adresse_id uuid;


update we_ge set adresse_id=null

update we_ge set adresse_id=sel3.id_ad from 
	(
		SELECT * FROM 
		(
			select sel1.* , (select replace(  plz||replace(lower(replace(strasse, ' ', '')) , 'straße', 'str')  ||lower(hausnr::text || coalesce(hausnr_z,'') ), '.', '') from we_ge where we_ge.id=sel1.wid) schl_wege from 
				(
					select sel.*, (select id wid from we_ge where st_distance(we_ge.geom, sel.geom_ad,false)<20 order by st_distance(we_ge.geom, sel.geom_ad) limit 1 ) from
						(
						select id id_ad, plz, replace(lower(replace(strasse, ' ', '')) , 'straße', 'str')strasse_ad, hausnr||coalesce(lower(adresszusatz),'') hausnr_ad , geom geom_ad from adressen.adressen where gemeinde_schluessel='15083040'
						) sel
					) sel1
		) sel2 where schl_wege= plz||strasse_ad||lower(hausnr_ad)	
	) sel3 where sel3.wid=we_ge.id;

	
	
select count(*) from we_ge where adresse_id is null

update adressen.adressen ad set anzahl_wohneinheit= sel.we , anzahl_gewerbeeinheit=sel.ge from
	(select * from we_ge) sel
	where gemeinde_schluessel='15083040' and ad.id=uuid(sel.adresse_id);



