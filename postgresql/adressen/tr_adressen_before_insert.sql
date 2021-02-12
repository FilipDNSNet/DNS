/*------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	Trigger                                                                                                                                               		  -- 
--	                                                                                                                                                              --  
--	                                                                                                                                                              --  
--	name:		tr_adressen_before_insert                                                                                                             			  --     
--	schema:		public                                                                                                                                            --  
--	typ:		Trigger                                                                                                                                           --     
--	cr.date:	04.01.2021                                                                                                                                        --  
--	ed.date:	11.02.2021                                                                                                                                        --  
--	impressionable_tables:                                                                                                                                        --
				adressen.adressen																																  --
--	purpose: 	                                                                                                                                                  --  
--				before insert on "adressen.adressen"			                                                     			                                  --                                                                                                             
--	DNS-Net GIS group                                                                                                                                             --  
--*/----------------------------------------------------------------------------------------------------------------------------------------------------------------



CREATE OR REPLACE FUNCTION tr_adressen_before_insert() RETURNS TRIGGER AS $$
DECLARE
	t boolean :=False;
BEGIN 
	if new.bundesland='Berlin' or new.bundesland='Brandenburg' then
		new._epsg_code:= 25833;
		new._x:=st_x(st_transform(new.geom,25833));
		new._y:=st_y(st_transform(new.geom,25833));
		new._z:=st_z(st_transform(new.geom,25833));
		new._wgs84_lat:=st_y(new.geom);
		new._wgs84_lon:=st_x(new.geom);
	elsif new.bundesland='Sachsen-Anhalt' then
		new._epsg_code:= 25832;
		new._x:=st_x(st_transform(new.geom,25832));
		new._y:=st_y(st_transform(new.geom,25832));
		new._z:=st_z(st_transform(new.geom,25832));
		new._wgs84_lat:=st_y(new.geom);
		new._wgs84_lon:=st_x(new.geom);
	end if;
  
  if st_isvalid(new.geom)=True and st_srid(new.geom)='4326' Then
			select True into t;
		end if;
		--bundesland :
		if new.bundesland is null AND t
			AND exists (SELECT FROM information_schema.tables WHERE  table_schema='basisdaten' AND table_name='bundeslaender_generalisierte_grenzen')
			THEN
			select bn.gen from basisdaten.bundeslaender_generalisierte_grenzen bn
				where st_contains(bn.geom, new.geom) limit 1 into new.bundesland;
		end if;
		
		--Gemeinde:
		----		Table "basisdaten.zusammengestellten_gemeinden" is created manually.
		if (new.gemeinde_name is Null OR new.gemeinde_schluessel is null) 
			AND exists (SELECT FROM information_schema.tables WHERE  table_schema='basisdaten' AND table_name='zusammengestellten_gemeinden')
			THEN
			if new.gemeinde_schluessel is not null then
				select gem_name from basisdaten.zusammengestellten_gemeinden where gem_nr=new.gemeinde_schluessel into new.gemeinde_name;
			elsif new.gemeinde_name is not Null then
				select gem_nr from basisdaten.zusammengestellten_gemeinden where gem_name=new.gemeinde_name into new.gemeinde_schluessel;
			elsif new.bundesland in ('Berlin') THEN
				select 'Berlin', '11000000'	into new.gemeinde_name, new.gemeinde_schluessel;
			elsif t THEN
				select gem_name, gem_nr from basisdaten.zusammengestellten_gemeinden pol where st_contains(pol.geom, new.geom) limit 1
					into new.gemeinde_name, new.gemeinde_schluessel;
			end if;				
		end if;

		--onb:
		if new.ortsnetzbereiche is null and t 
			AND exists (SELECT FROM information_schema.tables WHERE table_schema='basisdaten' AND table_name='ortznetzbereiche_deutschland_bneta')
			THEN
				select onb_nummer from basisdaten.ortznetzbereiche_deutschland_bneta pol where st_contains(pol.geom, new.geom) 
					into new.ortsnetzbereiche;
		End if;
		
		
		
		----kreis:
		----		Table "basisdaten.zusammengestellten_kreise" is created manually.
		if (new.kreis is Null OR new.kreis_nr is null) 
			AND exists (SELECT FROM information_schema.tables WHERE  table_schema='basisdaten' AND table_name='zusammengestellten_kreise')
			THEN
			if new.kreis_nr is not null then
				select kr_name from basisdaten.zusammengestellten_kreise where kr_nr=new.kreis_nr into new.kreis;
			elsif new.kreis is not Null then
				select kr_nr from basisdaten.zusammengestellten_kreise where kr_name=new.kreis into new.kreis_nr;
			elsif t THEN
				select kr_name, kr_nr from basisdaten.zusammengestellten_kreise pol where st_contains(pol.geom, new.geom) limit 1
					into new.kreis, new.kreis_nr;
			end if;				
		end if;
		
		
		-- #todo PLZ and verifizierungstyp(new.verifiziertstyp is null and alkis_id not like 'DE%' Then 'unsicher')
		-- verifizierungstyp
		
		if  new.verifizierungstyp is null and new.alkis_id not like 'DE%' and lower(new.adresse_checked)='nein' Then 
			select 'unsicher' into new.verifizierungstyp;
		end if;
		
		--typ		
		if new.typ is null and (new.strasse is null or lower(new.strasse) in ('keins', 'kein', 'keine', 'ohne', '-', ' ','') ) 
			and (new.psn is null or lower(new.psn) in ('keins', 'kein', 'keine', 'ohne', '-', ' ','') )
			and new.strassenschluessel is null THEN
				select 'C: Platz ohne Strassenbezeichnung' into new.typ;
		elsif new.typ is null and (new.strasse is NOT null and lower(new.strasse) NOT in ('keins', 'kein', 'keine', 'ohne', '-', ' ','') ) 
			and  (new.hausnr is null) then
				select 'B: Platz/Strasse ohne Hausnummer' into new.typ;
		elsif new.typ is null then
			select 'A: Adresse' into new.typ;
		end if;
		
		--aufnahmedatum
		if new.aufnahmedatum is null then 
			select now() into new.aufnahmedatum;
		end if;


	return new;
END; $$ language plpgsql;





DROP TRIGGER IF EXISTS tr_adressen_before_insert on adressen.adressen;

CREATE TRIGGER tr_adressen_before_insert 
  BEFORE INSERT ON adressen.adressen
    FOR EACH ROW
      EXECUTE PROCEDURE tr_adressen_before_insert();




