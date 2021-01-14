/*--------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	Rule                                                                                                                                               			    --
--	                                                                                                                                                                --
--	                                                                                                                                                                --
--	name:		rule_geometryadresse25832_update_1                                                                                                                  --
--	Database:	dns_net_geodb                                                                                                                                       --
--	schema:		public                                                                                                                                              --
--	typ:		Rule                                                                                                                                                --
--	cr.date:	05.09.2020                                                                                                                                          --  
--	ed.date:	13.11.2020                                                                                                                                          --  
--	impressionable_tables:                                                                                                                                          --
--				adressen.dv_adressen_brandenburg                                                                                                                    --
--				adressen.adressen                                                                                                                                   --
--	purpose: 	                                                                                                                                                    --
--				ON Update TO table "adressen._geometry_adresse_25832".                                                                                              --
--	DNS-Net GIS group                                                                                                                                               --
--*/------------------------------------------------------------------------------------------------------------------------------------------------------------------




Drop rule if exists rule_geometryadresse25832_update_1 on adressen._geometry_adresse_25832;


CREATE OR REPLACE RULE rule_geometryadresse25832_update_1
	AS ON UPDATE TO adressen._geometry_adresse_25832
		where (NoT st_equals(new.geom,old.geom)) and new._id=Old._id
		DO ALSO (
			UPDATE adressen.adressen ad
				set _epsg_code=25832 ,_x=st_x(new.geom),_y=st_y(new.geom), _z=st_z(new.geom), _wgs84_lat=st_y(st_transform(new.geom,4326)), _wgs84_lon=st_x(st_transform(new.geom,4326)) 
				where new._id=ad.id;
			);
			
			
			
			



