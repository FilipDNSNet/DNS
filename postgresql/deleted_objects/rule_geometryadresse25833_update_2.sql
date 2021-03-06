/*--------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	Rule                                                                                                                                               			    --
--	                                                                                                                                                                --
--	                                                                                                                                                                --
--	name:		rule_geometryadresse25833_update_2                                                                                                                  --
--	Database:	dns_net_geodb                                                                                                                                       --
--	schema:		public                                                                                                                                              --
--	typ:		Rule                                                                                                                                                --
--	cr.date:	05.09.2020                                                                                                                                          --    
--	ed.date:	09.02.2021                                                                                                                                          --    
--	impressionable_tables:                                                                                                                                          --
--				adressen.dv_adressen_brandenburg                                                                                                                    --
--				adressen.adressen                                                                                                                                   --
--	purpose: 	                                                                                                                                                    --
--				ON Update TO table "adressen._geometry_adresse_25833".                                                                                              --
--	DNS-Net GIS group                                                                                                                                               --
--*/------------------------------------------------------------------------------------------------------------------------------------------------------------------

Drop rule if exists rule_geometryadresse25833_update_2 on adressen._geometry_adresse_25833;


--CREATE OR REPLACE RULE rule_geometryadresse25833_update_2
--	AS ON UPDATE TO adressen._geometry_adresse_25833
--		where (NoT st_equals(new.geom,old.geom)) and new._id != Old._id
--		DO ALSO (
--			-- if the _id is switched to another adrese and at the same time the geometry changed.
--			UPDATE adressen.adressen ad
--				set _epsg_code=Null ,_x=Null,_y=Null, _z=NULL, _wgs84_lat=Null, _wgs84_lon=Null 
--				where old._id=ad.id;
--			UPDATE adressen.adressen ad
--				set _epsg_code=25833 ,_x=st_x(new.geom),_y=st_y(new.geom), _z=st_z(new.geom), _wgs84_lat=st_y(st_transform(new.geom,4326)), _wgs84_lon=st_x(st_transform(new.geom,4326)) 
--				where new._id=ad.id;
--			);
--
