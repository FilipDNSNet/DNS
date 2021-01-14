/*
Brandenburg (EPSG 25833)

This File is implemented to structure the DNSNET exchange for FTTH-planning datamodel.
- All of the column_names are in lowercase.
- Each column_name has utmost 10 characters.

30-07-2020
Version 00*/


Insert into  gpkg_spatial_ref_sys  values(
	'ETRS89 / UTM zone 33N',
	25833,
	'EPSG',
	25833,
	'PROJCS["ETRS89 / UTM zone 33N",GEOGCS["ETRS89",DATUM["European_Terrestrial_Reference_System_1989",SPHEROID["GRS 1980",6378137,298.257222101,AUTHORITY["EPSG","7019"]],TOWGS84[0,0,0,0,0,0,0],AUTHORITY["EPSG","6258"]],PRIMEM["Greenwich",0,AUTHORITY["EPSG","8901"]],UNIT["degree",0.0174532925199433,AUTHORITY["EPSG","9122"]],AUTHORITY["EPSG","4258"]],PROJECTION["Transverse_Mercator"],PARAMETER["latitude_of_origin",0],PARAMETER["central_meridian",15],PARAMETER["scale_factor",0.9996],PARAMETER["false_easting",500000],PARAMETER["false_northing",0],UNIT["metre",1,AUTHORITY["EPSG","9001"]],AXIS["Easting",EAST],AXIS["Northing",NORTH],AUTHORITY["EPSG","25833"]]',
	'Cartesian 2D CS. Axes: easting, northing (E,N). Orientations: east, north. UoM: m.'
);

Insert into  gpkg_spatial_ref_sys  values(
	'ETRS89 / UTM zone 32N',
	25832,
	'EPSG',
	25832,
	'PROJCS["ETRS89 / UTM zone 32N",GEOGCS["ETRS89",DATUM["European_Terrestrial_Reference_System_1989",SPHEROID["GRS 1980",6378137,298.257222101,AUTHORITY["EPSG","7019"]],TOWGS84[0,0,0,0,0,0,0],AUTHORITY["EPSG","6258"]],PRIMEM["Greenwich",0,AUTHORITY["EPSG","8901"]],UNIT["degree",0.0174532925199433,AUTHORITY["EPSG","9122"]],AUTHORITY["EPSG","4258"]],PROJECTION["Transverse_Mercator"],PARAMETER["latitude_of_origin",0],PARAMETER["central_meridian",9],PARAMETER["scale_factor",0.9996],PARAMETER["false_easting",500000],PARAMETER["false_northing",0],UNIT["metre",1,AUTHORITY["EPSG","9001"]],AXIS["Easting",EAST],AXIS["Northing",NORTH],AUTHORITY["EPSG","25832"]]',
	'Cartesian 2D CS. Axes: easting, northing (E,N). Orientations: east, north. UoM: m.'
);

select * from gpkg_spatial_ref_sys;



/* Wertliste*/
CREATE TABLE enum_adresse_typ (val TEXT PRIMARY KEY);
	INSERT INTO enum_adresse_typ VALUES('A: Adresse');
	INSERT INTO enum_adresse_typ VALUES('B: Platz/Strasse ohne hausenummer');


CREATE TABLE enum_adresse_verifiziert (val TEXT PRIMARY KEY);
	INSERT INTO enum_adresse_verifiziert VALUES('Nicht-verifiziert');
	INSERT INTO enum_adresse_verifiziert VALUES('Lage-verifiziert');
	INSERT INTO enum_adresse_verifiziert VALUES('Nutzung-verifiziert');
	INSERT INTO enum_adresse_verifiziert VALUES('Funktion-verifiziert');
	INSERT INTO enum_adresse_verifiziert VALUES('Verifiziert');


CREATE TABLE enum_adresse_funktionkategorie (val TEXT PRIMARY KEY);
	INSERT INTO enum_adresse_funktionkategorie VALUES('Wohngebäude');
	INSERT INTO enum_adresse_funktionkategorie VALUES('Wohn-und Gewerbegebäude');
	INSERT INTO enum_adresse_funktionkategorie VALUES('Gewerbegebäude');
	INSERT INTO enum_adresse_funktionkategorie VALUES('Schule und sonstige Bildungseinrichtung');
	INSERT INTO enum_adresse_funktionkategorie VALUES('Krankenhaus');
	INSERT INTO enum_adresse_funktionkategorie VALUES('Freizeit- und Erholung');
	INSERT INTO enum_adresse_funktionkategorie VALUES('Öffentliche Gebäude');
	INSERT INTO enum_adresse_funktionkategorie VALUES('Religiöse und kulurelle Nutzung');
	INSERT INTO enum_adresse_funktionkategorie VALUES('Sonstige Nutzung');


CREATE TABLE enum_adresse_qualitaet (val TEXT PRIMARY KEY);
	INSERT INTO enum_adresse_qualitaet VALUES('1- Hauskoordinate innerhalb Flurstueck');
	INSERT INTO enum_adresse_qualitaet VALUES('2- Koordinate liegt auf einem Gebaeudeumring');
	INSERT INTO enum_adresse_qualitaet VALUES('3- Katasterinterne Hausnumme / Hauskoordinate innerhalb Flurstueck');

CREATE TABLE enum_adresse_status (val TEXT PRIMARY KEY);
	INSERT INTO enum_adresse_status VALUES('Bestand-Objekt');
	INSERT INTO enum_adresse_status VALUES('In Bau');
	INSERT INTO enum_adresse_status VALUES('Bebauungsplan');
	INSERT INTO enum_adresse_status VALUES('Baulücke');
	INSERT INTO enum_adresse_status VALUES('Ruine');

/*Update metadata*/
insert into gpkg_contents(table_name, data_type,identifier) values ('enum_adresse_typ', 'attributes','enum_adresse_typ');
insert into gpkg_contents(table_name, data_type,identifier) values ('enum_adresse_verifiziert', 'attributes','enum_adresse_verifiziert');
insert into gpkg_contents(table_name, data_type,identifier) values ('enum_adresse_funktionkategorie', 'attributes','enum_adresse_funktionkategorie');
insert into gpkg_contents(table_name, data_type,identifier) values ('enum_adresse_qualitaet', 'attributes','enum_adresse_qualitaet');

select * from gpkg_contents;

/*---	TABLE Adresse*/

CREATE TABLE adresse(
	id INTEGER primary key Autoincrement,
	adresse_id text,
	vid INTEGER,
	geom POINT,/* brandenburg */
	typ TEXT DEFAULT 'A: Adresse' NOT NULL,
	onb text check( cast(onb as Integer)=onb ),/*Check for being numeric string*/
	gmd_name text,
	gmd_nr text NOT NULL CHECK( length(gmd_nr)=8  and CAST(gmd_nr as INTEGER)=gmd_nr),/*Check for being numeric string with the length of 8 characters.*/
	amtname text,
	kreis text,
	kreis_nr text CHECK( length(kreis_nr)=5  and CAST(kreis_nr as INTEGER)=kreis_nr),/*Check for being numeric string with the length of 5 characters.*/
	bezirk text,
	bezirk_nr text CHECK( length(bezirk_nr)=2  and CAST(bezirk_nr as INTEGER)=bezirk_nr),/*Check for being numeric string with the length of 2 characters.*/
	ort text,
	ortsteil text,
	ortsteilnr text CHECK( length(ortsteilnr)=4  and CAST(ortsteilnr as INTEGER)=ortsteilnr),/*Check for being numeric string with the length of 4 characters.*/
	plz text NOT NULL CHECK( length(plz)=5  and CAST(plz as INTEGER)=plz),/*Check for being numeric string with the length of 5 characters.*/
	strasse text NOT NULL,
	psn text NOT NULL,
	str_schlus TEXT CHECK( length(str_schlus)=5  and CAST(str_schlus as INTEGER)=str_schlus),/*Check for being numeric string with the length of 5 characters.*/
	hausnr text NOT NULL check( cast(hausnr as Integer)=hausnr ),/*Check for being numeric string*/
	adz text DEFAULT NULL,
	blk text CHECK( length(blk)=6  and CAST(blk as INTEGER)=blk),/*Check for being numeric string with the length of 6 characters.*/
	funktion text,
	funk_kateg TEXT,
	anzahl_we INTEGER,
	anzahl_ge INTEGER,
	anzahl_ne INTEGER,
	/*aufn_datum text CHECK(date(aufn_datum) is not Null),*/
	aufn_datum date,
	verifizrt TEXT DEFAULT 'Nicht-verifiziert' NOT NULL,
	/*datum_verf text CHECK(date(datum_verf) is not Null),*/
	datum_verf date,
	qualitaet TEXT,
	adr_status TEXT DEFAULT 'Bestand-Objekt',
	--CONSTRAINT pk_adresse_id PRIMARY KEY (id),
	CONSTRAINT fk_adresse_typ FOREIGN KEY(typ) REFERENCES enum_adresse_typ(val) ON UPDATE CASCADE,
	CONSTRAINT fk_adresse_funktion_kategorie FOREIGN KEY(funk_kateg) REFERENCES enum_adresse_funktionkategorie(val) ON UPDATE CASCADE,
	CONSTRAINT fk_adresse_verifiziert FOREIGN KEY(verifizrt) REFERENCES enum_adresse_verifiziert(val) ON UPDATE CASCADE,
	CONSTRAINT fk_adresse_qualitaet FOREIGN KEY(qualitaet) REFERENCES enum_adresse_qualitaet(val) ON UPDATE CASCADE,
	CONSTRAINT fk_adresse_status FOREIGN KEY(adr_status) REFERENCES enum_adresse_status(val) ON UPDATE CASCADE,
	UNIQUE(adresse_id)
);


/*Definition of Index*/
insert into gpkg_contents(table_name, data_type,identifier,srs_id) values ('adresse', 'features','adresse',25833);/*Brandenburg EPSG:25833*/
insert into gpkg_geometry_columns values ('adresse','geom','POINT',25833, 0, 0 );/*Brandenburg EPSG:25833*/
--CREATE UNIQUE INDEX idx_contacts_email ON contacts (email);

create table t1 (da date)
insert into gpkg_contents(table_name, data_type,identifier) values ('t1', 'attributes','t1');