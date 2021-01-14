/*--------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	Table Definition                                                                                                                                                --
--	                                                                                                                                                                --
--	adressen._geometry_adresse_25832                                                                                                                                --
--	                                                                                                                                                                --
--	name:		_geometry_adresse_25832                                                                                                                             --
--	Database:	dns_net_geodb                                                                                                                                       --               
--	schema:		adressen                                                                                                                                            --
--	typ:		Dynamic-Linked_Table                                                                                                                                --
--	cr.date:	05.09.2020                                                                                                                                          --
--	ed.date:	13.11.2020                                                                                                                                          --
--	impressionable_tables:                                                                                                                                          --
--				adressen.adressen                                                                                                                                   --
--	purpose: 	                                                                                                                                                    --
--				Handle the geometry of the addresses which have EPSG code of 25832.                                                                                 --
--				=> later that we ahve geometry for adressen.adressen, this table would be depricated.                                                               --                  
--				                                                                                                                                                    --
-- EPSG code:	25832				                                                                                                                                --
--	DNS-Net GIS group                                                                                                                                               --
--*/------------------------------------------------------------------------------------------------------------------------------------------------------------------


CREATE TABLE adressen._geometry_adresse_25832 (
	_id uuid,
	--_alkis_id dom_adresse_id,
	--_vid dom_vid,
	geom geometry(POINT , 25832),
	--_trig text default 'geom',
	CONSTRAINT pk_geometry_adresse_25832 primary key (_id),
	CONSTRAINT fk_geometry_adresse_25832 FOREIGN KEY (_id) REFERENCES adressen.adressen(id) ON UPDATE CASCADE ON DELETE CASCADE
);
CREATE INDEX inx_geometry_adresse_25832_geom ON adressen._geometry_adresse_25832 USING GIST(geom);
--CREATE INDEX inx_geometry_adresse_25832_vid ON adressen._geometry_adresse_25832(_vid);
--CREATE INDEX inx_geometry_adresse_25832_alkisid ON adressen._geometry_adresse_25832(_alkis_id);

