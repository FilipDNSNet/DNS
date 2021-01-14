/*
Adressen Tables and Triggers:

prerequisites:
	- 01_Enums_Domains.sql
	- 01_Functions_and_triggers.sql
*/

/*###	TABLE CREATION	###########################################################################################################################*/
CREATE TABLE adressen.adressen (
	id uuid DEFAULT dns_netzwerk_uuid('adresse'),
	alkis_id dom_adresse_id,
	vid dom_vid,/*Unknown external_id*/
--	geom geometry(POINT, 25833),/* berlin */
	typ TEXT DEFAULT 'A: Adresse' NOT NULL,
	ortsnetzbereiche dom_numeric_string,
	gemeinde_name text,
	gemeinde_schluessel dom_8_digit_string, --NOT NULL,
	amtname text,
	bundesland text NOT NULL,
	kreis text,
	kreis_nr dom_5_digit_string,
	bezirk text,
	bezirk_nr dom_2_digit_string,
	ort text,
	ortsteil text,
	ortsteil_nr dom_4_digit_string,
	plz dom_5_digit_string NOT NULL,
	strasse text NOT NULL,
	psn text,
	strassenschluessel varchar(5),
	hausnr dom_numeric_string ,
	adresszusatz VARCHAR(15) DEFAULT NULL,
	blk dom_6_digit_string,
	funktion text,
	funktion_kategorie TEXT,
	anzahl_wohneinheit INTEGER,
	anzahl_gewerbeeinheit INTEGER,
	anzahl_nutzeinheit INTEGER,
	aufnahmedatum DATE,
--	verifiziert TEXT DEFAULT 'Nicht-verifiziert' NOT NULL,
--	verfizierungsdatum DATE,
	adresse_checked varchar(4) DEFAULT 'Nein',
	ne_checked varchar(4) DEFAULT 'Nein',
	datum_adresse_checked DATE,
	datum_ne_checked DATE,
	qualitaet TEXT,
	adresse_status TEXT,-- DEFAULT 'Bestand-Objekt',
	_epsg_code integer,
	_x numeric,
	_y numeric,
	_z numeric,
	_wgs84_lat numeric,
	_wgs84_lon numeric,
	CONSTRAINT pk_adresse PRIMARY KEY (id),
	--CONSTRAINT unq_adresse_id UNIQUE(alkis_id), maybe later we ubderstand earlier than amt that an adress is splitted
	CONSTRAINT fk_adresse_typ FOREIGN KEY(typ) REFERENCES enum_adresse_typ(val) ON UPDATE CASCADE,
	CONSTRAINT fk_adresse_bundesland FOREIGN KEY(bundesland) REFERENCES enum_bundesland(val) ON UPDATE CASCADE,
	CONSTRAINT fk_adresse_funktion_kategorie FOREIGN KEY(funktion_kategorie) REFERENCES enum_adresse_funktionkategorie(val) ON UPDATE CASCADE,
	--CONSTRAINT fk_adresse_verifiziert FOREIGN KEY(verifiziert) REFERENCES enum_adresse_verifiziert(val) ON UPDATE CASCADE,
	CONSTRAINT fk_adresse_nechecked FOREIGN KEY (ne_checked) REFERENCES enum_ja_nein(val) ON UPDATE CASCADE,
	CONSTRAINT fk_adresse_adresssechecked FOREIGN KEY (adresse_checked) REFERENCES enum_ja_nein(val) ON UPDATE CASCADE,
	CONSTRAINT fk_adresse_qualitaet FOREIGN KEY(qualitaet) REFERENCES enum_adresse_qualitaet(val) ON UPDATE CASCADE,
	CONSTRAINT fk_adresse_status FOREIGN KEY(adresse_status) REFERENCES enum_adresse_status(val) ON UPDATE CASCADE
);
CREATE INDEX inx_adresse_vid ON adressen.adressen (vid);
CREATE INDEX inx_adresse_alkis_id ON adressen.adressen (alkis_id);
CREATE INDEX inx_adresse_strasse ON adressen.adressen (strasse);
CREATE INDEX inx_adresse_hausnr ON adressen.adressen (hausnr);
CREATE INDEX inx_adresse_gemeinde_name ON adressen.adressen(gemeinde_name);
CREATE INDEX inx_adresse_gemeinde_schluessel ON adressen.adressen(gemeinde_schluessel);
CREATE INDEX inx_adresse_plz ON adressen.adressen (plz);
CREATE INDEX inx_adresse_funktion_kategorie ON adressen.adressen(funktion_kategorie);

COMMENT ON TABLE adressen.adressen IS E'This table is the master table for the addresses (every Bundesland.). It does not contain geometry. 
		The geometry is linked through id to separated tables according to their CRS.\n
		The coordinates stored as text in the table are updated on any update to the geometry in other tables through some triggers.
		\nDeveloped by DNSNET GIS-Team. \n05-09-2020';


CREATE OR REPLACE function tr_adressen_nechecked() returns trigger as $$
	BEGIN
		if new.ne_checked='Ja' Then 
			new.datum_ne_checked=(SELECT now());
		elsif new.ne_checked='Nein' Then 
			new.datum_ne_checked=Null;
		end if;
		return New;
	END;
$$ LANGUAGE PLPGSQL;
DROp TRIGGER IF EXISTS  tr_adressen_nechecked on adressen.adressen;
CREATE TRIGGER tr_adressen_nechecked
	Before UPDATE ON adressen.adressen
		For Each ROW
			EXECUTE PROCEDURE tr_adressen_nechecked();
----- We should not write for insert, because on every insert, it might overide incorrectly the value of that have alredy checked dated	with insertion time	
CREATE OR REPLACE function tr_adressen_adressechecked() returns trigger as $$
	BEGIN
		if new.adresse_checked='Ja' Then 
			new.datum_adresse_checked=(SELECT now());
		elsif new.adresse_checked='Nein' Then 
			new.datum_adresse_checked=Null;
		end if;
		return New;
	END;
$$ LANGUAGE PLPGSQL;
DROp TRIGGER IF EXISTS  tr_adressen_adressechecked on adressen.adressen;
CREATE TRIGGER tr_adressen_adressechecked
	Before UPDATE ON adressen.adressen
		For Each ROW
			EXECUTE PROCEDURE tr_adressen_adressechecked();			
----- We should not write for insert, because on every insert, it might overide incorrectly the value of that have alredy checked dated	with insertion time			
		
		
		
		
		
		
		
--create two tables for geometry< and theier triggers.
--import the data from adressen.bb






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


CREATE OR REPLACE RULE rule_geometryadresse25833_insert
	AS ON INSERT TO adressen._geometry_adresse_25833
		DO ALSO (UPDATE adressen.adressen ad
			set _epsg_code=25833 ,_x=st_x(new.geom),_y=st_y(new.geom), _z=st_z(new.geom), _wgs84_lat=st_y(st_transform(new.geom,4326)), _wgs84_lon=st_x(st_transform(new.geom,4326)) 
			where new._id=ad.id);

CREATE OR REPLACE RULE rule_geometryadresse25833_update_1
	AS ON UPDATE TO adressen._geometry_adresse_25833
		where (NoT st_equals(new.geom,old.geom)) and new._id=Old._id
		DO ALSO (
			UPDATE adressen.adressen ad
				set _epsg_code=25833 ,_x=st_x(new.geom),_y=st_y(new.geom), _z=st_z(new.geom), _wgs84_lat=st_y(st_transform(new.geom,4326)), _wgs84_lon=st_x(st_transform(new.geom,4326)) 
				where new._id=ad.id;
			);

CREATE OR REPLACE RULE rule_geometryadresse25833_update_2
	AS ON UPDATE TO adressen._geometry_adresse_25833
		where (NoT st_equals(new.geom,old.geom)) and new._id != Old._id
		DO ALSO (
			-- if the _id is switched to another adrese and at the same time the geometry changed.
			UPDATE adressen.adressen ad
				set _epsg_code=Null ,_x=Null,_y=Null, _z=NULL, _wgs84_lat=Null, _wgs84_lon=Null 
				where old._id=ad.id;
			UPDATE adressen.adressen ad
				set _epsg_code=25833 ,_x=st_x(new.geom),_y=st_y(new.geom), _z=st_z(new.geom), _wgs84_lat=st_y(st_transform(new.geom,4326)), _wgs84_lon=st_x(st_transform(new.geom,4326)) 
				where new._id=ad.id;
			);

CREATE OR REPLACE RULE rule_geometryadresse25833_delete
	AS ON DELETE TO adressen._geometry_adresse_25833
		DO ALSO (UPDATE adressen.adressen ad
			set _epsg_code=Null ,_x=Null,_y=NULL, _z=Null, _wgs84_lat=Null, _wgs84_lon=Null 
			where old._id=ad.id);
			
			




----------------------- 25832
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


CREATE OR REPLACE RULE rule_geometryadresse25832_insert
	AS ON INSERT TO adressen._geometry_adresse_25832
		DO ALSO (UPDATE adressen.adressen ad
			set _epsg_code=25832 ,_x=st_x(new.geom),_y=st_y(new.geom), _z=st_z(new.geom), _wgs84_lat=st_y(st_transform(new.geom,4326)), _wgs84_lon=st_x(st_transform(new.geom,4326)) 
			where new._id=ad.id);

CREATE OR REPLACE RULE rule_geometryadresse25832_update_1
	AS ON UPDATE TO adressen._geometry_adresse_25832
		where (NoT st_equals(new.geom,old.geom)) and new._id=Old._id
		DO ALSO (
			UPDATE adressen.adressen ad
				set _epsg_code=25832 ,_x=st_x(new.geom),_y=st_y(new.geom), _z=st_z(new.geom), _wgs84_lat=st_y(st_transform(new.geom,4326)), _wgs84_lon=st_x(st_transform(new.geom,4326)) 
				where new._id=ad.id;
			);

CREATE OR REPLACE RULE rule_geometryadresse25832_update_2
	AS ON UPDATE TO adressen._geometry_adresse_25832
		where (NoT st_equals(new.geom,old.geom)) and new._id != Old._id
		DO ALSO (
			-- if the _id is switched to another adrese and at the same time the geometry changed.
			UPDATE adressen.adressen ad
				set _epsg_code=Null ,_x=Null,_y=Null, _z=NULL, _wgs84_lat=Null, _wgs84_lon=Null 
				where old._id=ad.id;
			UPDATE adressen.adressen ad
				set _epsg_code=25832 ,_x=st_x(new.geom),_y=st_y(new.geom), _z=st_z(new.geom), _wgs84_lat=st_y(st_transform(new.geom,4326)), _wgs84_lon=st_x(st_transform(new.geom,4326)) 
				where new._id=ad.id;
			);

CREATE OR REPLACE RULE rule_geometryadresse25832_delete
	AS ON DELETE TO adressen._geometry_adresse_25832
		DO ALSO (UPDATE adressen.adressen ad
			set _epsg_code=Null ,_x=Null,_y=NULL, _z=Null, _wgs84_lat=Null, _wgs84_lon=Null 
			where old._id=ad.id);			




