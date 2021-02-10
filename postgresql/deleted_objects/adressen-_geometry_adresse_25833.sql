/*--------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	Table Definition                                                                                                                                                --
--	                                                                                                                                                                --
--	adressen._geometry_adresse_25833                                                                                                                                --
--	                                                                                                                                                                --
--	name:		_geometry_adresse_25833                                                                                                                             --
--	Database:	dns_net_geodb                                                                                                                                       --             
--	schema:		adressen                                                                                                                                            --
--	typ:		Dynamic-Linked_Table                                                                                                                                --
--	cr.date:	05.09.2020                                                                                                                                          --
--	ed.date:	09.02.2021                                                                                                                                          --
--	impressionable_tables:                                                                                                                                          --
--				adressen.adressen                                                                                                                                   --
--	purpose: 	                                                                                                                                                    --
--				Handle the geometry of the addresses which have EPSG code of 25833.                                                                                 --
--				=> later that we ahve geometry for adressen.adressen, this table would be depricated.                                                               --                
--				                                                                                                                                                    --
-- EPSG code:	25833				                                                                                                                                --
--	DNS-Net GIS group                                                                                                                                               --
--*/------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- on 09-02-2021 :

DROP TABLE IF EXISTS _geometry_adresse_25833;


CREATE TABLE adressen._geometry_adresse_25833 (
	_id uuid,
	--_alkis_id dom_adresse_id,
	--_vid dom_vid,
	geom geometry(POINT , 25833),
	--_trig text default 'geom',
	CONSTRAINT pk_geometry_adresse_25833 primary key (_id),
	CONSTRAINT fk_geometry_adresse_25833 FOREIGN KEY (_id) REFERENCES adressen.adressen(id) ON UPDATE CASCADE ON DELETE CASCADE
);
CREATE INDEX inx_geometry_adresse_25833_geom ON adressen._geometry_adresse_25833 USING GIST(geom);
--CREATE INDEX inx_geometry_adresse_25833_vid ON adressen._geometry_adresse_25833(_vid);
--CREATE INDEX inx_geometry_adresse_25833_alkisid ON adressen._geometry_adresse_25833(_alkis_id);


