/*--------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	Table Definition                                                                                                                                                --
--	                                                                                                                                                                --
--	adressen.adressen                                                                                                                                               --
--	                                                                                                                                                                --
--	name:		adressen                                                                                                                                            --
--	Database:	dns_net_geodb                                                                                                                                       --
--	schema:		adressen                                                                                                                                            --
--	typ:		Table                                                                                                                                				--
--	cr.date:	05.09.2020                                                                                                                                          --
--	ed.date:	11.02.2021                                                                                                                                          --
--	impressionable_tables:                                                                                                                                          --
--				adressen.adressen                                                                                                                                   --
--	purpose: 	                                                                                                                                                    --
--				The Master table for address managment. The "id" is generated with a DNS-NET structure.                                                             --
--				The column names starting with "_" are not directly inserted or updated. They get updated automatically.                                            --
--				The following Tables reflects the information in "adressen.adressen" and work interactively with eachother.                                         --
--					adressen.adresse_abschluss                                                                                                                      --
--					adressen.dv_adressen_berlin                                                                                                                     --
--					adressen.dv_adressen_brandenburg                                                                                                                --
--					adressen.dv_adressen_sachsen_analt                                                                                                              --
--					adressen._geometry_adresse_25832  (Depricated)                                                                                                  --
--					adressen._geometry_adresse_25833  (Depricated)                                                                                                  --
--				                                                                                                                                                    --
-- EPSG code:	4326				                                                                                                                                --
--	DNS-Net GIS group                                                                                                                                               --
--*/------------------------------------------------------------------------------------------------------------------------------------------------------------------


/*###	TABLE CREATION	###########################################################################################################################*/
CREATE TABLE adressen.adressen (
	id uuid DEFAULT dns_netzwerk_uuid('adresse'),
	alkis_id dom_adresse_id,
	vid dom_vid,/*Unknown external_id*/
--	geom geometry(POINT, 25833),/* berlin */
	typ TEXT DEFAULT 'A: Adresse' NOT NULL,
	ortsnetzbereiche dom_numeric_string,
	gemeinde_name text,
	gemeinde_schluessel dom_8_digit_string NOT NULL,
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
	adresse_status TEXT DEFAULT 'Bestand-Objekt',
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

-- an edit on 02-12-2020 add geom
alter table adressen.adressen add column geom geometry(POINT,4326);
create index inx_adressen_adressen_geom on adressen.adressen using GIST(geom);


COMMENT ON TABLE adressen.adressen IS E'This table is the master table for the addresses (every Bundesland.).  
		\n 
		\n, Developed by DNSNET GIS-Team. \n05-09-2020';


---- on 09-02-2021:

alter table adressen.adressen add column verifizierungstyp text;
alter table adressen.adressen add column analysiert_durch text;
alter table adressen.adressen add column foerder_status text;
alter table adressen.adressen add column beschreibung text;


COMMENT ON TABLE adressen.adressen IS E'This table is the master table for the addresses (every Bundesland.).  
		\n 
		\n, Developed by DNSNET GIS-Team. \n05-09-2020';

--constraints

alter table adressen.adressen add constraint fk_adresse_verifizierungstyp foreign key (verifizierungstyp)
	references enum_adressen_verifizierungstyp(val) on update cascade;

alter table adressen.aderessen add constraint fk_adresse_analysiert_durch foreign key (analysiert_durch)
	references enum_adressen_analysiert_durch(val) on update cascade;

alter table adressen.adressen add constraint fk_adresse_foerder_status foreign key (foerder_status)
	references enum_adressen_foerder_status(val) on update cascade;


---- on 11-02-2021:
alter table adressen.adressen alter column typ drop not null;-- 11.02.2021
alter table adressen.adressen alter column typ drop default;-- 11.02.2021
