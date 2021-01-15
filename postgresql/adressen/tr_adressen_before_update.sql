/*------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	Trigger                                                                                                                                               		  -- 
--	                                                                                                                                                              --  
--	                                                                                                                                                              --  
--	name:		tr_adressen_before_update                                                                                                             			  --     
--	schema:		public                                                                                                                                            --  
--	typ:		Trigger                                                                                                                                           --     
--	cr.date:	04.01.2021                                                                                                                                        --  
--	ed.date:	04.01.2021                                                                                                                                        --  
--	impressionable_tables:                                                                                                                                        --
--				adressen.adressen  		                                                                                                                          --
--	purpose: 	                                                                                                                                                  --  
--				Before Update on "adressen.adressen"			                                                     		                                      --                                                                                                  
--	DNS-Net GIS group                                                                                                                                             --  
--*/----------------------------------------------------------------------------------------------------------------------------------------------------------------




CREATE OR REPLACE function tr_adressen_before_update() returns trigger as $$
-- it efects adressen.adressen only.
-- #todo later :  auto-Check (no update) value for bundestland, ONB , ... via geometry
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
		
		if new.ne_checked='Ja' Then ----- We should not write for insert, because on every insert, it might overide incorrectly the value of that have alredy checked dated	with insertion time			 
			new.datum_ne_checked=(SELECT now());
		elsif new.ne_checked='Nein' Then 
			new.datum_ne_checked=Null;
		end if;
		
		if new.adresse_checked='Ja' Then ----- We should not write for insert, because on every insert, it might overide incorrectly the value of that have alredy checked dated	with insertion time			
			new.datum_adresse_checked=(SELECT now());
		elsif new.adresse_checked='Nein' Then 
			new.datum_adresse_checked=Null;
		end if;
		
		return New;
	END;
$$ LANGUAGE PLPGSQL;


DROp TRIGGER IF EXISTS  tr_adressen_before_update on adressen.adressen;


CREATE TRIGGER tr_adressen_before_update
	Before UPDATE ON adressen.adressen
		For Each ROW
			EXECUTE PROCEDURE tr_adressen_before_update();	
			
			