/*------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	Trigger                                                                                                                                               		  -- 
--	                                                                                                                                                              --  
--	                                                                                                                                                              --  
--	name:		tr_adressen_before_insert                                                                                                             			  --     
--	schema:		public                                                                                                                                            --  
--	typ:		Trigger                                                                                                                                           --     
--	cr.date:	04.01.2021                                                                                                                                        --  
--	ed.date:	04.01.2021                                                                                                                                        --  
--	impressionable_tables:                                                                                                                                        --
				adressen.adressen																																  --
--	purpose: 	                                                                                                                                                  --  
--				before insert on "adressen.adressen"			                                                     			                                  --                                                                                                             
--	DNS-Net GIS group                                                                                                                                             --  
--*/----------------------------------------------------------------------------------------------------------------------------------------------------------------



create or replace function tr_adressen_before_insert() returns trigger as $$ --#new#
-- it efects adressen.adressen only.
-- #todo later :  auto-insert value for bundestland, ONB , ... via geometry
begin 
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
	return new;
end;
$$ language plpgsql;	

	
drop trigger if exists 	tr_adressen_before_insert on adressen.adressen;


create trigger tr_adressen_beforeupdate_fill_xy 
	before insert on adressen.adressen
		for each row
			execute procedure tr_adressen_before_insert();




