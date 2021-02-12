/*--------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	Table Definition                                                                                                                                                --
--	                                                                                                                                                                --
--	adressen.dv_adressen_berlin                                                                                                                                     --
--	                                                                                                                                                                --
--	name:		dv_adressen_berlin                                                                                                                                  --
--	Database:	dns_net_geodb                                                                                                                                       --
--	schema:		adressen                                                                                                                                            --
--	typ:		Dynamic-Linked_Table                                                                                                                                --
--	cr.date:	13.10.2020                                                                                                                                          --
--	ed.date:	11.02.2021                                                                                                                                          --
--	impressionable_tables:                                                                                                                                          --
--				adressen.adressen                                                                                                                                   --
--	purpose: 	                                                                                                                                                    --
--				This table mirrors the information of the table "adressen.adressen" for Berlin.                                                                     --
--				You cannot directly insert or delete from this table, instead work on the mother table "adressen.adressen"											--
--				Ususally the values can get updated.            	    												                                            --
--				The columns which their names starts with "_" cannot get updated from this table, although they might be switchable.                                --
--				"adressen.adresse_abschluss".                                                                                                                       --
--				                                                                                                                                                    --
-- EPSG code:	25833				                                                                                                                                --
--	DNS-Net GIS group                                                                                                                                               --
--*/------------------------------------------------------------------------------------------------------------------------------------------------------------------


DROP TABLE IF EXISTS adressen.dv_adressen_berlin cascade;



--Table definition 
CREATE TABLE adressen.dv_adressen_berlin (
	_id uuid,
	alkis_id dom_adresse_id,
	vid dom_vid,/*Unknown external_id*/
	geom geometry(POINT, 25833),/* berlin */
	typ TEXT DEFAULT 'A: Adresse', --NOT NULL,
	ortsnetzbereiche dom_numeric_string,
	gemeinde_name text,
	gemeinde_schluessel dom_8_digit_string, ----NOT NULL,
	--amtname text,
	--bundesland text NOT NULL,
	kreis text,
	kreis_nr dom_5_digit_string,
	bezirk text,
	bezirk_nr dom_2_digit_string,
	ort text,
	ortsteil text,
	ortsteil_nr dom_4_digit_string,
	plz dom_5_digit_string, --NOT NULL,
	strasse text, --NOT NULL,
	psn text,
	strassenschluessel varchar(5),
	hausnr dom_numeric_string ,
	adresszusatz VARCHAR(15) DEFAULT NULL,
	--blk dom_6_digit_string,
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
	_trig text default 'dv',
	--_epsg_code integer,
	_x numeric,
	_y numeric,
	--_z numeric,
	--_wgs84_lat numeric,
	--_wgs84_lon numeric,
	CONSTRAINT pk_adressen_berlin PRIMARY KEY (_id),
	--CONSTRAINT fk_adressen_berlin_id FOREIGN KEY (_id) REFERENCES adressen.adressen(id)  ON DELETE CASCADE,  --ON UPDATE CASCADE
	--CONSTRAINT unq_adresse_berlin_id UNIQUE(alkis_id), maybe later we ubderstand earlier than amt that an adress is splitted
	CONSTRAINT fk_adresse_berlin_typ FOREIGN KEY(typ) REFERENCES enum_adresse_typ(val) ON UPDATE CASCADE,
	--CONSTRAINT fk_adresse_berlin_bundesland FOREIGN KEY(bundesland) REFERENCES enum_bundesland(val) ON UPDATE CASCADE,
	CONSTRAINT fk_adresse_berlin_funktion_kategorie FOREIGN KEY(funktion_kategorie) REFERENCES enum_adresse_funktionkategorie(val) ON UPDATE CASCADE,
	--CONSTRAINT fk_adresse_berlin_verifiziert FOREIGN KEY(verifiziert) REFERENCES enum_adresse_verifiziert(val) ON UPDATE CASCADE,
	CONSTRAINT fk_adresse_berlin_nechecked FOREIGN KEY (ne_checked) REFERENCES enum_ja_nein(val) ON UPDATE CASCADE,
	CONSTRAINT fk_adresse_berlin_adresssechecked FOREIGN KEY (adresse_checked) REFERENCES enum_ja_nein(val) ON UPDATE CASCADE,
	CONSTRAINT fk_adresse_berlin_qualitaet FOREIGN KEY(qualitaet) REFERENCES enum_adresse_qualitaet(val) ON UPDATE CASCADE,
	CONSTRAINT fk_adresse_berlin_status FOREIGN KEY(adresse_status) REFERENCES enum_adresse_status(val) ON UPDATE CASCADE
);
CREATE INDEX inx_adresse_berlin_geom ON adressen.dv_adressen_berlin USING GIST(geom);
CREATE INDEX inx_adresse_berlin_vid ON adressen.dv_adressen_berlin (vid);
CREATE INDEX inx_adresse_berlin_alkis_id ON adressen.dv_adressen_berlin (alkis_id);
CREATE INDEX inx_adresse_berlin_strasse ON adressen.dv_adressen_berlin (strasse);
CREATE INDEX inx_adresse_berlin_hausnr ON adressen.dv_adressen_berlin (hausnr);
CREATE INDEX inx_adresse_berlin_gemeinde_name ON adressen.dv_adressen_berlin(gemeinde_name);
CREATE INDEX inx_adresse_berlin_gemeinde_schluessel ON adressen.dv_adressen_berlin(gemeinde_schluessel);
CREATE INDEX inx_adresse_berlin_kreis ON adressen.dv_adressen_berlin(kreis);
CREATE INDEX inx_adresse_berlin_kreis_nr ON adressen.dv_adressen_berlin(kreis_nr);
CREATE INDEX inx_adresse_berlin_plz ON adressen.dv_adressen_berlin (plz);
CREATE INDEX inx_adresse_berlin_funktion_kategorie ON adressen.dv_adressen_berlin(funktion_kategorie);
COMMENT ON TABLE adressen.dv_adressen_berlin IS E'Dynamic-view "dv_adressen_berlin" (EPSG: 25833)\nThis table is joint to "adressen.adressen".
	\nEvery change on the master tables are mirrored here. Man cannot insert or delete from this table.\nDeveloped by DNSNET GIS-Team.  \n13-10-2020\n This table in practce would be FDW';	




---- 09-02-2021

alter table adressen.dv_adressen_berlin add column verifizierungstyp text;
alter table adressen.dv_adressen_berlin add column analysiert_durch text;
alter table adressen.dv_adressen_berlin add column foerder_status text;
alter table adressen.dv_adressen_berlin add column beschreibung text;
--constraints
alter table adressen.dv_adressen_berlin add constraint fk_adresse_berlin_verifizierungstyp foreign key (verifizierungstyp)
	references enum_adressen_verifizierungstyp(val) on update cascade;
alter table adressen.dv_adressen_berlin add constraint fk_adresse_berlin_analysiert_durch foreign key (analysiert_durch)
	references enum_adressen_analysiert_durch(val) on update cascade;
alter table adressen.dv_adressen_berlin add constraint fk_adresse_berlin_foerder_status foreign key (foerder_status)
	references enum_adressen_foerder_status(val) on update cascade;


---- on 11-02-2021:
alter table adressen.dv_adressen_berlin alter column typ drop not null;-- 11.02.2021
alter table adressen.dv_adressen_berlin alter column typ drop default;-- 11.02.2021