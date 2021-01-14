/*------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	Trigger                                                                                                                                                       --
--	                                                                                                                                                              --
--	                                                                                                                                                              --
--	name:		tr_adressen_before_update_insert_fill_xy                                                                                                          --
--	Database:	dns_net_geodb                                                                                                                                     --
--	schema:		public                                                                                                                                            --
--	typ:		Trigger                                                                                                                                           --
--	cr.date:	03.12.2020                                                                                                                                        --
--	ed.date:	03.12.2020                                                                                                                                        --
--	impressionable_tables:                                                                                                                                        --
--				adressen.adressen                                                                                                                                 --
--	purpose: 	                                                                                                                                                  --
--				before update or insert on  "adressen.adressen"                                                      			                                  --
--	DNS-Net GIS group                                                                                                                                             --
--*/----------------------------------------------------------------------------------------------------------------------------------------------------------------

--drop function if exists tr_adressen_before_update_insert_fill_xy;


create or replace function tr_adressen_before_update_insert_fill_xy() returns trigger as $$ --#new#
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

			
drop trigger if exists 	tr_adressen_before_update_insert_fill_xy on adressen.adressen;

create trigger tr_adressen_beforeupdate_fill_xy 
	before update or insert on adressen.adressen
		for each row
			execute procedure tr_adressen_before_update_insert_fill_xy();



--##todo trigger to fill out the _x,_y, srid by change in the geom 
----
----		Do here
----
----	
