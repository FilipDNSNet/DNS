/*File name: Tables.sql
Implementation of Tables in Model A.
Notcie that the Following SQL should have benn run first:

prerequisites:
	- 01_Enums_Domains.sql
	- 01_Functions_and_triggers.sql

DNS-NET GIS group
	Last Update: 15-10-2020 
	Deployed on : 15-10-2020 
*/

/*LIST of Tables:
	_cluster
*/

/* Drop if esixts #############################################################################################*/

DROP TABLE IF EXISTS prj_cottbus_vortrieb.linear_object cascade;
DROP TABLE IF EXISTS prj_cottbus_vortrieb.strecke_line cascade;
DROP TABLE IF EXISTS prj_cottbus_vortrieb.strecke cascade;
DROP TABLE IF EXISTS prj_cottbus_vortrieb.rohr_schutzrohr;
DROP TABLE IF EXISTS prj_cottbus_vortrieb.schutzrohr;
DROP TABLE IF EXISTS prj_cottbus_vortrieb.trasse;
DROP TABLE IF EXISTS prj_cottbus_vortrieb.microduct;
DROP TABLE IF EXISTS prj_cottbus_vortrieb.rohr cascade;
DROP TABLE IF EXISTS prj_cottbus_vortrieb.kabel cascade;
DROP TABLE IF EXISTS prj_cottbus_vortrieb.faser;
DROP TABLE IF EXISTS prj_cottbus_vortrieb.connection_element;
DROP TABLE IF EXISTS prj_cottbus_vortrieb.connection_unit;
DROP TABLE IF EXISTS prj_cottbus_vortrieb.connection_module;
DROP TABLE IF EXISTS prj_cottbus_vortrieb.abschlusspunkte_kunden;
DROP TABLE IF EXISTS prj_cottbus_vortrieb.adresse_abschluss;
DROP TABLE IF EXISTS prj_cottbus_vortrieb.abschlusspunkte;
DROP TABLE IF EXISTS prj_cottbus_vortrieb.knoten;





----/*###	TABLE CREATION	###########################################################################################################################*/



CREATE TABLE prj_cottbus_vortrieb.knoten (
	id uuid DEFAULT dns_netzwerk_uuid('knoten') ,
	bez text,
	geom geometry('POINT',25833) Not Null,
	typ text NOT NULL,
	subtyp text NOT NULL,
	foerdert_status text,
	planung_status text NOT NULL default 'Grobplanung',
	produkt_id text,
	label_prefix text, -- N for NVT, H for Hausanschluss .....
	label_wert text, -- The integer part of the label
	cluster integer,
	CONSTRAINT pk_prj_cottbus_vortrieb_knoten PRIMARY KEY(id)
);
ALTER TABLE prj_cottbus_vortrieb.knoten ADD CONSTRAINT fk_prj_cottbus_vortrieb_knoten_typ FOREIGN KEY (typ) REFERENCES enum_knoten_typ(val) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.knoten ADD CONSTRAINT fk_prj_cottbus_vortrieb_knoten_subtyp FOREIGN KEY (subtyp) REFERENCES enum_knoten_subtyp(val)on UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.knoten ADD CONSTRAINT fk_prj_cottbus_vortrieb_knoten_status FOREIGN KEY(planung_status) REFERENCES enum_planungsstatus(val) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.knoten ADD CONSTRAINT fk_prj_cottbus_vortrieb_knoten_foerdert FOREIGN KEY (foerdert_status) REFERENCES enum_foerdertstatus(val) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.knoten ADD CONSTRAINT fk_prj_cottbus_vortrieb_knoten_produkt FOREIGN KEY(produkt_id) REFERENCES _produkt_katalog(_produkt) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.knoten ADD CONSTRAINT fk_prj_cottbus_vortrieb_knoten_cluster FOREIGN KEY(cluster) REFERENCES _cluster(id) ON UPDATE CASCADE;
CREATE INDEX inxfk_prj_cottbus_vortrieb_knoten_produktid ON prj_cottbus_vortrieb.knoten(produkt_id);
CREATE INDEX inxfk_prj_cottbus_vortrieb_knoten_cluster ON prj_cottbus_vortrieb.knoten(cluster);
CREATE INDEX inx_prj_cottbus_vortrieb_knoten_geom ON prj_cottbus_vortrieb.knoten USING GIST(geom);



CREATE TABLE prj_cottbus_vortrieb.abschlusspunkte(
	id uuid DEFAULT dns_netzwerk_uuid('abschlusspunkte'),
	geom geometry('POINT',25833),
	knoten_id uuid NOT NULL,
	typ text NOT NULL,
	einbauort text,
	homeconnect_status text,
	cluster integer,
	CONSTRAINT pk_prj_cottbus_vortrieb_abschlusspunkte PRIMARY KEY(id)
);
ALTER TABLE prj_cottbus_vortrieb.abschlusspunkte ADD CONSTRAINT fk_prj_cottbus_vortrieb_abschlusspunkte_knoten FOREIGN KEY(knoten_id) REFERENCES prj_cottbus_vortrieb.knoten(id) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.abschlusspunkte ADD CONSTRAINT fk_prj_cottbus_vortrieb_abschlusspunkte_typ FOREIGN KEY(typ) REFERENCES enum_abschlusspunkte_typ(val) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.abschlusspunkte ADD CONSTRAINT fk_prj_cottbus_vortrieb_abschlusspunkte_einabuort FOREIGN KEY(einbauort) REFERENCES enum_abschlusspunkte_einbauort(val) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.abschlusspunkte ADD CONSTRAINT fk_prj_cottbus_vortrieb_abschlusspunkte_hc FOREIGN KEY(homeconnect_status) REFERENCES enum_hc_status(val) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.abschlusspunkte ADD CONSTRAINT fk_prj_cottbus_vortrieb_abschlusspunkte_cluster FOREIGN KEY (cluster) REFERENCES _cluster(id) ON UPDATE CASCADE;
CREATE INDEX inx_prj_cottbus_vortrieb_abschlusspunkte_knotenid ON prj_cottbus_vortrieb.abschlusspunkte(knoten_id);
CREATE INDEX inx_prj_cottbus_vortrieb_abschlusspunkte_cluster ON prj_cottbus_vortrieb.abschlusspunkte(cluster);
CREATE INDEX inx_prj_cottbus_vortrieb_abschlusspunkte_geom ON prj_cottbus_vortrieb.abschlusspunkte USING GIST(geom);



CREATE TABLE prj_cottbus_vortrieb.adresse_abschluss(
	adresse_id uuid,
	abschlusspunkte_id uuid,
	cluster integer,
	CONSTRAINT pk_prj_cottbus_vortrieb_adresse_abschluss PRIMARY KEY(adresse_id, abschlusspunkte_id)
);
ALTER TABLE prj_cottbus_vortrieb.adresse_abschluss ADD CONSTRAINT fk_prj_cottbus_vortrieb_adresseabschluss_adresse FOREIGN KEY (adresse_id) REFERENCES adressen.adressen(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.adresse_abschluss ADD CONSTRAINT fk_prj_cottbus_vortrieb_adresseabschluss_abschluss FOREIGN KEY (abschlusspunkte_id)REFERENCES prj_cottbus_vortrieb.abschlusspunkte(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.adresse_abschluss ADD CONSTRAINT fk_prj_cottbus_vortrieb_adresseabschluss_cluster FOREIGN KEY (cluster) REFERENCES _cluster(id) ON UPDATE CASCADE;
CREATE INDEX inxfk_prj_cottbus_vortrieb_adresseabschluss_adresse ON prj_cottbus_vortrieb.adresse_abschluss(adresse_id);
CREATE INDEX inx_prj_cottbus_vortrieb_adresseabschluss_cluster ON prj_cottbus_vortrieb.adresse_abschluss(cluster);
CREATE INDEX inxfk_prj_cottbus_vortrieb_adresseabschluss_abschlu ON prj_cottbus_vortrieb.adresse_abschluss(abschlusspunkte_id);




CREATE TABLE prj_cottbus_vortrieb.abschlusspunkte_kunden (
	id uuid DEFAULT dns_netzwerk_uuid('attribute'),
	abschlusspunkte_id uuid NOT NULL,
	sid varchar(25) NOT NULL,
	vertriebsstatus text NOT NULL,
	active text,
	cluster integer,
	CONSTRAINT pk_prj_cottbus_vortrieb_abschlusspunkte_kunden PRIMARY KEY (id)
);
ALTER TABLE prj_cottbus_vortrieb.abschlusspunkte_kunden ADD CONSTRAINT fk_prj_cottbus_vortrieb_abschlusspunktekunden_abschlusspunkte FOREIGN KEY (abschlusspunkte_id) REFERENCES prj_cottbus_vortrieb.abschlusspunkte(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.abschlusspunkte_kunden ADD CONSTRAINT fk_prj_cottbus_vortrieb_abschlusspunktekunden_vertriebsstatus FOREIGN KEY (vertriebsstatus) REFERENCES enum_vertriebsstatus(val) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.abschlusspunkte_kunden ADD CONSTRAINT fk_prj_cottbus_vortrieb_abschlusspunktekunden_active FOREIGN KEY (active) REFERENCES enum_ja_nein(val) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.abschlusspunkte_kunden ADD CONSTRAINT fk_prj_cottbus_vortrieb_abschlusspunktekunden_cluster FOREIGN KEY (cluster) REFERENCES _cluster(id) ON UPDATE CASCADE;
CREATE INDEX inxfk_prj_cottbus_vortrieb_abschlusspunktekunden_abschlusspunkte ON prj_cottbus_vortrieb.abschlusspunkte_kunden(abschlusspunkte_id);
CREATE INDEX inx_prj_cottbus_vortrieb_abschlusspunktekunden_cluster ON prj_cottbus_vortrieb.abschlusspunkte_kunden(cluster);


CREATE TABLE prj_cottbus_vortrieb.connection_module (
	id uuid DEFAULT dns_netzwerk_uuid('connection_module'),
	typ text NOT NULL,
	produkt_id text,
	knoten_id uuid NOT NULL,
	netzebene_quelle text NOT NULL,
	netzebene_ziel text NOT NULL,
	eigentum_status text NOT NULL DEFAULT 'Eigentum',
	foerdert_status text,
	planung_status text NOT NULL default 'Grobplanung',
	cluster integer,
	CONSTRAINT pk_prj_cottbus_vortrieb_connection_module PRIMARY KEY (id)
);
ALTER TABLE prj_cottbus_vortrieb.connection_module ADD CONSTRAINT fk_prj_cottbus_vortrieb_connectionmodule_typ FOREIGN KEY (typ) REFERENCES enum_connmodule_typ(val) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.connection_module ADD CONSTRAINT fk_prj_cottbus_vortrieb_connectionmodule_produkt FOREIGN KEY(produkt_id) REFERENCES _produkt_katalog(_produkt) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.connection_module ADD CONSTRAINT fk_prj_cottbus_vortrieb_connectionmodule_knoten FOREIGN KEY (knoten_id) REFERENCES prj_cottbus_vortrieb.knoten(id) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.connection_module ADD CONSTRAINT fk_prj_cottbus_vortrieb_connectionmodule_netzebene_quel FOREIGN KEY (netzebene_quelle) REFERENCES enum_netzebene(val) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.connection_module ADD CONSTRAINT fk_prj_cottbus_vortrieb_connectionmodule_netzebene_ziel FOREIGN KEY (netzebene_ziel) REFERENCES enum_netzebene(val) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.connection_module ADD CONSTRAINT fk_prj_cottbus_vortrieb_connectionmodule_eigentum FOREIGN KEY (eigentum_status) REFERENCES enum_eigentum(val) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.connection_module ADD CONSTRAINT fk_prj_cottbus_vortrieb_connectionmodule_foerdert FOREIGN KEY (foerdert_status) REFERENCES enum_foerdertstatus(val) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.connection_module ADD CONSTRAINT fk_prj_cottbus_vortrieb_connectionmodule_cluster FOREIGN KEY (cluster) REFERENCES _cluster(id) ON UPDATE CASCADE;
alter table prj_cottbus_vortrieb.connection_module ADD Constraint unq_prj_cottbus_vortrieb_connectionmodule_id_knoten unique (id,knoten_id ); -- it is referenced as a foreign key in microdukt.
CREATE INDEX inxfk_prj_cottbus_vortrieb_connmodule_knotenid ON prj_cottbus_vortrieb.connection_module(knoten_id);
CREATE INDEX inxfk_prj_cottbus_vortrieb_connmodule_produktid ON prj_cottbus_vortrieb.connection_module(produkt_id);
CREATE INDEX inx_prj_cottbus_vortrieb_connmodule_cluster ON prj_cottbus_vortrieb.connection_module(cluster);


CREATE TABLE prj_cottbus_vortrieb.connection_unit (
	id uuid DEFAULT dns_netzwerk_uuid('connection_unit'),
	conn_module_id uuid NOT NULL,
	produkt_id text,
	letzten_datum_mod date,
	cluster integer,
	CONSTRAINT pk_prj_cottbus_vortrieb_connection_unit PRIMARY KEY (id) 
);
ALTER TABLE prj_cottbus_vortrieb.connection_unit ADD CONSTRAINT fk_prj_cottbus_vortrieb_connectionunit_connmodule FOREIGN KEY(conn_module_id) REFERENCES prj_cottbus_vortrieb.connection_module(id) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.connection_unit ADD CONSTRAINT fk_prj_cottbus_vortrieb_connectionunit_produkt FOREIGN KEY(produkt_id) REFERENCES _produkt_katalog(_produkt) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.connection_unit ADD CONSTRAINT fk_prj_cottbus_vortrieb_connectionunit_cluster FOREIGN KEY(cluster) REFERENCES _cluster(id)ON UPDATE CASCADE;
CREATE INDEX inxfk_prj_cottbus_vortrieb_connunit_connmoduleid ON prj_cottbus_vortrieb.connection_unit(conn_module_id);
CREATE INDEX inxfk_prj_cottbus_vortrieb_connunit_produktid ON prj_cottbus_vortrieb.connection_unit(produkt_id);
CREATE INDEX inx_prj_cottbus_vortrieb_connunit_cluster ON prj_cottbus_vortrieb.connection_unit(cluster);


CREATE TABLE prj_cottbus_vortrieb.connection_element(
	id uuid DEFAULT dns_netzwerk_uuid('connection_element'),
	conn_unit_id uuid NOT NULL,
	produkt_id text,
	typ text NOT NULL default 'Passive',
	subtyp text NOT NULL,
	installation_ziele dom_zahl default 1,
	installation_spalte dom_zahl default 1,
	label text,
	mehrdetail text,
	cluster integer,
	CONSTRAINT pk_prj_cottbus_vortrieb_connectionelement PRIMARY KEY(id)
);
ALTER TABLE prj_cottbus_vortrieb.connection_element ADD CONSTRAINT fk_prj_cottbus_vortrieb_connectionelem_unit FOREIGN KEY (conn_unit_id) REFERENCES prj_cottbus_vortrieb.connection_unit(id) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.connection_element ADD CONSTRAINT fk_prj_cottbus_vortrieb_connectionelem_produkt FOREIGN KEY(produkt_id) REFERENCES _produkt_katalog(_produkt) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.connection_element ADD CONSTRAINT fk_prj_cottbus_vortrieb_connectionelem_typ FOREIGN KEY (typ) REFERENCES enum_connelement_typ(val) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.connection_element ADD CONSTRAINT fk_prj_cottbus_vortrieb_connectionelem_subtyp FOREIGN KEY (subtyp) REFERENCES enum_connelement_subtyp(val) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.connection_element ADD CONSTRAINT fk_prj_cottbus_vortrieb_connectionelem_cluster FOREIGN KEY (cluster) REFERENCES _cluster(id) ON UPDATE CASCADE;
CREATE INDEX inxfk_prj_cottbus_vortrieb_connelement_connunitid ON prj_cottbus_vortrieb.connection_element(conn_unit_id);
CREATE INDEX inxfk_prj_cottbus_vortrieb_connelement_produktid ON prj_cottbus_vortrieb.connection_element(produkt_id);
CREATE INDEX inx_prj_cottbus_vortrieb_connelement_cluster ON prj_cottbus_vortrieb.connection_element(cluster);


CREATE TABLE prj_cottbus_vortrieb.kabel (
	id uuid DEFAULT dns_netzwerk_uuid('KABEL'),
	bez text, -- used for bezeicnung MRV06565/fid
	geom geometry('LINESTRING',25833),
	produkt_id text,
	anzahl_fasern dom_zahl NOT NULL,
	typ text NOT NULL Default 'Kabel',
	netzebene text NOT NULL,
	conn_module_anfang uuid NOT NULL,
	conn_module_ende uuid,
	foerdert_status text,-- NOT NULL,
	planung_status text NOT NULL,
	eigentum_status text NOT NULL Default 'Eigentum',
	homeconnect_status text,
	length numeric,
	cluster integer,	
	CONSTRAINT pk_prj_cottbus_vortrieb_kabel PRIMARY KEY (id)
);
ALTER TABLE prj_cottbus_vortrieb.kabel ADD CONSTRAINT fk_prj_cottbus_vortrieb_kabel_typ FOREIGN KEY (typ) REFERENCES enum_kabel_typ(val) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.kabel ADD CONSTRAINT fk_prj_cottbus_vortrieb_kabel_produkt FOREIGN KEY(produkt_id) REFERENCES _produkt_katalog(_produkt) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.kabel ADD CONSTRAINT fk_prj_cottbus_vortrieb_kabel_netzebene FOREIGN KEY (netzebene) REFERENCES enum_netzebene(val) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.kabel ADD CONSTRAINT fk_prj_cottbus_vortrieb_kabel_conn_module_anfang FOREIGN KEY (conn_module_anfang) REFERENCES prj_cottbus_vortrieb.connection_module(id) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.kabel ADD CONSTRAINT fk_prj_cottbus_vortrieb_kabel_conn_module_ende FOREIGN KEY (conn_module_ende) REFERENCES prj_cottbus_vortrieb.connection_module(id) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.kabel ADD CONSTRAINT fk_prj_cottbus_vortrieb_kabel_status FOREIGN KEY(planung_status) REFERENCES enum_planungsstatus(val) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.kabel ADD CONSTRAINT fk_prj_cottbus_vortrieb_kabel_foerdert FOREIGN KEY (foerdert_status) REFERENCES enum_foerdertstatus(val) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.kabel ADD CONSTRAINT fk_prj_cottbus_vortrieb_kabel_eigentum FOREIGN KEY(eigentum_status) REFERENCES enum_eigentum(val) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.kabel ADD CONSTRAINT fk_prj_cottbus_vortrieb_kabel_hc FOREIGN KEY(homeconnect_status) REFERENCES enum_hc_status(val) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.kabel ADD CONSTRAINT fk_prj_cottbus_vortrieb_kabel_cluster FOREIGN KEY (cluster) REFERENCES _cluster(id) ON UPDATE CASCADE;
alter table prj_cottbus_vortrieb.kabel ADD CONSTRAINT fk_prj_cottbus_vortrieb_kabel_produkt_anzahlfaser FOREIGN key (produkt_id, anzahl_fasern) references pr_kabel(produkt,anzahl_faser) on update cascade; -- control the numebr of rohr with produkt
CREATE INDEX inxfk_prj_cottbus_vortrieb_kabel_produktid ON prj_cottbus_vortrieb.kabel(produkt_id);
CREATE INDEX inxfk_prj_cottbus_vortrieb_kabel_connmodule_anfang ON prj_cottbus_vortrieb.kabel(conn_module_anfang);
CREATE INDEX inxfk_prj_cottbus_vortrieb_kabel_connmodule_ende ON prj_cottbus_vortrieb.kabel(conn_module_ende);
CREATE INDEX inx_prj_cottbus_vortrieb_kabel_cluster ON prj_cottbus_vortrieb.kabel(cluster);
CREATE INDEX inx_prj_cottbus_vortrieb_kabel_geom ON prj_cottbus_vortrieb.kabel USING GIST(geom);


CREATE TABLE prj_cottbus_vortrieb.faser (
	id uuid DEFAULT dns_netzwerk_uuid('faser'),
	bez text,
	geom geometry('LINESTRING',25833),
	kabel_id uuid NOT NULL,
	netzebene text NOT NULL,
	buendeln_nr dom_zahl NOT NULL,
	faser_label text,
	conn_element_anfang uuid NOT NULL,
	anf_elem_output_nr dom_zahl,/*input_nr integer,*/
	anfang_typ text default 'Nicht angegeben',/*input_typ text default 'Nicht angegeben',*/
	anfang_label text,
	conn_element_ende uuid NOT NULL,
	end_elem_input_nr dom_zahl,/*output_nr integer,*/
	ende_typ text default 'Nicht angegeben',/*output_typ text default 'Nicht angegeben',*/
	ende_label text,
	length numeric,
	external_id text,
	cluster integer,
	CONSTRAINT pk_prj_cottbus_vortrieb_faser PRIMARY KEY (id)
);
ALTER TABLE prj_cottbus_vortrieb.faser ADD CONSTRAINT fk_prj_cottbus_vortrieb_faser_kabel FOREIGN KEY (kabel_id) REFERENCES prj_cottbus_vortrieb.kabel(id)on UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.faser ADD CONSTRAINT fk_prj_cottbus_vortrieb_faser_netzebene FOREIGN KEY (netzebene) REFERENCES enum_netzebene(val) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.faser ADD CONSTRAINT fk_prj_cottbus_vortrieb_faser_connelement_anfang FOREIGN KEY (conn_element_anfang) REFERENCES prj_cottbus_vortrieb.connection_element(id) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.faser ADD CONSTRAINT fk_prj_cottbus_vortrieb_faser_connelement_ende FOREIGN KEY (conn_element_ende) REFERENCES prj_cottbus_vortrieb.connection_element(id) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.faser ADD CONSTRAINT fk_prj_cottbus_vortrieb_faser_input_type FOREIGN KEY (anfang_typ) REFERENCES enum_faserconn(val) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.faser ADD CONSTRAINT fk_prj_cottbus_vortrieb_faser_output_type FOREIGN KEY (ende_typ) REFERENCES enum_faserconn(val) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.faser ADD CONSTRAINT fk_prj_cottbus_vortrieb_faser_cluster FOREIGN KEY (cluster) REFERENCES _cluster(id) ON UPDATE CASCADE;
CREATE INDEX inxfk_prj_cottbus_vortrieb_faser_kabel_id ON prj_cottbus_vortrieb.faser(kabel_id);
CREATE INDEX inxfk_prj_cottbus_vortrieb_faser_connelement_anfang ON prj_cottbus_vortrieb.faser(conn_element_anfang);
CREATE INDEX inxfk_prj_cottbus_vortrieb_faser_connelement_ende ON prj_cottbus_vortrieb.faser(conn_element_ende);
CREATE INDEX inx_prj_cottbus_vortrieb_faser_cluster ON prj_cottbus_vortrieb.faser(cluster);
CREATE INDEX inx_prj_cottbus_vortrieb_faser_geom ON prj_cottbus_vortrieb.faser USING GIST(geom);


CREATE TABLE prj_cottbus_vortrieb.rohr (
	id uuid DEFAULT dns_netzwerk_uuid('rohr'),
	bez text, -- used for bezeicnung MRV06565/fid
	geom geometry('LINESTRING',25833),
	typ text NOT NULL,
	produkt_id text,
	anzahl_microducts dom_zahl Not Null,
	mantel_farbe text,
	mantel_label text,
	foerdert_status text,-- NOT NULL,
	planung_status text NOT NULL,
	netzebene text NOT NULL,
	homeconnect_status text,
	top_agg_id text,--uuid,
	bez_wert text,
	cluster integer,
	CONSTRAINT pk_prj_cottbus_vortrieb_rohr PRIMARY KEY (id)
);
ALTER TABLE prj_cottbus_vortrieb.rohr ADD CONSTRAINT fk_prj_cottbus_vortrieb_rohr_typ FOREIGN KEY (typ) REFERENCES enum_rohr_typ(val) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.rohr ADD CONSTRAINT fk_prj_cottbus_vortrieb_rohr_produkt FOREIGN KEY(produkt_id) REFERENCES _produkt_katalog(_produkt) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.rohr ADD CONSTRAINT fk_prj_cottbus_vortrieb_rohr_mantel_farbe FOREIGN KEY(mantel_farbe) REFERENCES enum_farbe(val) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.rohr ADD CONSTRAINT fk_prj_cottbus_vortrieb_rohr_status FOREIGN KEY (planung_status) REFERENCES enum_planungsstatus(val) ON UPDATE CASCADE; 
ALTER TABLE prj_cottbus_vortrieb.rohr ADD CONSTRAINT fk_prj_cottbus_vortrieb_rohr_foerdert FOREIGN KEY (foerdert_status) REFERENCES enum_foerdertstatus(val) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.rohr ADD CONSTRAINT fk_prj_cottbus_vortrieb_rohr_netzebene FOREIGN KEY (netzebene) REFERENCES enum_netzebene(val) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.rohr ADD CONSTRAINT fk_prj_cottbus_vortrieb_rohr_hc_status FOREIGN KEY (homeconnect_status) REFERENCES enum_hc_status(val) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.rohr ADD CONSTRAINT fk_prj_cottbus_vortrieb_rohr_cluster FOREIGN KEY (cluster) REFERENCES _cluster(id) ON UPDATE CASCADE;
alter table prj_cottbus_vortrieb.rohr ADD CONSTRAINT fk_prj_cottbus_vortrieb_rohr_produkt_anzahlmicroduct FOREIGN key (produkt_id, anzahl_microducts) references pr_rohr(produkt,anzahl_microducts) on update cascade;-- control the numebr of rohr with produkt
CREATE INDEX inxfk_prj_cottbus_vortrieb_rohr_produktid ON prj_cottbus_vortrieb.rohr(produkt_id);
CREATE INDEX inx_prj_cottbus_vortrieb_rohr_topaggid on prj_cottbus_vortrieb.rohr(top_agg_id);
CREATE INDEX inx_prj_cottbus_vortrieb_rohr_cluster ON prj_cottbus_vortrieb.rohr(cluster);
CREATE INDEX inx_prj_cottbus_vortrieb_rohr_geom ON prj_cottbus_vortrieb.rohr USING GIST(geom);


CREATE TABLE prj_cottbus_vortrieb.microduct (
	id uuid DEFAULT dns_netzwerk_uuid('microduct'),
	bez text, -- ror_name / microduct nr
	geom geometry('LINESTRING',25833),
	rohr_id uuid NOT NULL,
	microduct_nr dom_zahl NOT NULL, -- two microducts can have the same rohr_id and microduct_nr (one is  dead)
	knoten_anfang uuid NOT NULL,
	conn_module_anfang uuid,
	conn_module_anfang_label text,--which  input of connection_module
	knoten_ende uuid,
	conn_module_ende uuid,
	conn_module_ende_label text,--which  input of connection_module
	stammt_von uuid,
	bottom_agg_id text,--uuid, -- identifies the microducts that are connected to eachother in each netzebene. it is the uuid of underlying knoten_id.(e.g. th uuid of hausanschluss_koten in verteiler ebene) 
	zweig dom_zahl Default 1, -- determines the order of branch.
	kabel_id uuid,
	netzebene text NOT NULL,
	bez_wert text,
	cluster integer,
	CONSTRAINT pk_prj_cottbus_vortrieb_microduct PRIMARY KEY (id)
);
ALTER TABLE prj_cottbus_vortrieb.microduct ADD CONSTRAINT fk_prj_cottbus_vortrieb_microduct_rohr FOREIGN KEY (rohr_id) REFERENCES prj_cottbus_vortrieb.rohr(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.microduct ADD CONSTRAINT fk_prj_cottbus_vortrieb_microduct_knoten_anfang FOREIGN KEY (knoten_anfang) REFERENCES prj_cottbus_vortrieb.knoten(id) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.microduct ADD CONSTRAINT fk_prj_cottbus_vortrieb_microduct_knoten_ende FOREIGN KEY (knoten_ende) REFERENCES prj_cottbus_vortrieb.knoten(id) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.microduct ADD CONSTRAINT fk_prj_cottbus_vortrieb_microduct_stammtvon FOREIGN KEY (stammt_von) REFERENCES prj_cottbus_vortrieb.microduct(id) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.microduct ADD CONSTRAINT fk_prj_cottbus_vortrieb_microduct_kabel_id FOREIGN KEY (kabel_id) REFERENCES prj_cottbus_vortrieb.kabel(id) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.microduct ADD CONSTRAINT fk_prj_cottbus_vortrieb_microduct_netzebene FOREIGN KEY (netzebene) REFERENCES enum_netzebene(val) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.microduct ADD CONSTRAINT fk_prj_cottbus_vortrieb_microduct_cluster FOREIGN KEY (cluster) REFERENCES _cluster(id) ON UPDATE CASCADE;
--alter table prj_cottbus_vortrieb.microduct ADD constraint fk_prj_cottbus_vortrieb_microduct_connmodule_anf FOREIGN KEY (knoten_anfang, conn_module_anfang) references prj_cottbus_vortrieb.connection_module (id,knoten_id) on update cascade;
--alter table prj_cottbus_vortrieb.microduct ADD constraint fk_prj_cottbus_vortrieb_microduct_connmodule_end FOREIGN KEY (knoten_ende, conn_module_ende) references prj_cottbus_vortrieb.connection_module (id, knoten_id) on update cascade;
alter table prj_cottbus_vortrieb.microduct ADD constraint fk_prj_cottbus_vortrieb_microduct_connmodule_anf FOREIGN KEY (knoten_anfang, conn_module_anfang) references prj_cottbus_vortrieb.connection_module (knoten_id, id) on update cascade;
alter table prj_cottbus_vortrieb.microduct ADD constraint fk_prj_cottbus_vortrieb_microduct_connmodule_end FOREIGN KEY (knoten_ende, conn_module_ende) references prj_cottbus_vortrieb.connection_module (knoten_id, id) on update cascade;
CREATE INDEX inxfk_prj_cottbus_vortrieb_microduct_rohr ON prj_cottbus_vortrieb.microduct(rohr_id);
CREATE INDEX inxfk_prj_cottbus_vortrieb_microduct_knot_anf ON prj_cottbus_vortrieb.microduct(knoten_anfang);
CREATE INDEX inxfk_prj_cottbus_vortrieb_microduct_knot_ende ON prj_cottbus_vortrieb.microduct(knoten_ende);
CREATE INDEX inxfk_prj_cottbus_vortrieb_microduct_stammtvon ON prj_cottbus_vortrieb.microduct(stammt_von);
CREATE INDEX inx_prj_cottbus_vortrieb_microduct_btnaggid on prj_cottbus_vortrieb.microduct(bottom_agg_id);
CREATE INDEX inxfk_prj_cottbus_vortrieb_microduct_kabelid ON prj_cottbus_vortrieb.microduct(kabel_id);
CREATE INDEX inx_prj_cottbus_vortrieb_microduct_cluster ON prj_cottbus_vortrieb.microduct(cluster);
CREATE INDEX inx_prj_cottbus_vortrieb_microduct_geom ON prj_cottbus_vortrieb.microduct USING GIST(geom);



CREATE TABLE prj_cottbus_vortrieb.trasse (
	id uuid DEFAULT dns_netzwerk_uuid('trasse'),
	geom geometry('Linestring',25833) NOT NULL,
	typ text NOT NULL,
	trassenbauverfahren text NOT NULL,
	sonst_bauverfahren text Default NULL,
	verlege_tief_m numeric NOT NULL,
	oberflaeche text NOT NULL,
	widmung text NOT NULL,
	foerdert_status text,-- NOT NULL,
	planung_status text NOT NULL,
	homeconnect_status text,
	netzebene text NOT NULL,
	cluster integer,
	CONSTRAINT pk_prj_cottbus_vortrieb_trasse PRIMARY KEY (id)
);
ALTER TABLE prj_cottbus_vortrieb.trasse ADD CONSTRAINT fk_prj_cottbus_vortrieb_trasse_typ FOREIGN KEY (typ) REFERENCES enum_trasse_typ (val) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.trasse ADD CONSTRAINT fk_prj_cottbus_vortrieb_trasse_bauverfahr FOREIGN KEY (trassenbauverfahren) REFERENCES enum_trassenbauverfahren(val) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.trasse ADD CONSTRAINT fk_prj_cottbus_vortrieb_trasse_oberflaeche FOREIGN KEY (oberflaeche) REFERENCES enum_trasse_oberflaeche(val) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.trasse ADD CONSTRAINT fk_prj_cottbus_vortrieb_trasse_widmung FOREIGN KEY (widmung) REFERENCES enum_widmung(val) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.trasse ADD CONSTRAINT fk_prj_cottbus_vortrieb_trasse_foerdert FOREIGN KEY (foerdert_status) REFERENCES enum_foerdertstatus ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.trasse ADD CONSTRAINT fk_prj_cottbus_vortrieb_trasse_status FOREIGN KEY (planung_status) REFERENCES enum_planungsstatus ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.trasse ADD CONSTRAINT fk_prj_cottbus_vortrieb_trasse_netzebene FOREIGN KEY (netzebene) REFERENCES enum_netzebene(val) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.trasse ADD CONSTRAINT fk_prj_cottbus_vortrieb_trasse_hc_status FOREIGN KEY (homeconnect_status) REFERENCES enum_hc_status(val) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.trasse ADD CONSTRAINT fk_prj_cottbus_vortrieb_trasse_cluster FOREIGN KEY (cluster) REFERENCES _cluster(id) ON UPDATE CASCADE;
CREATE INDEX inx_prj_cottbus_vortrieb_trasse_cluster ON prj_cottbus_vortrieb.trasse(cluster);
CREATE INDEX inx_prj_cottbus_vortrieb_trasse_geom ON prj_cottbus_vortrieb.trasse USING GIST(geom);


CREATE TABLE prj_cottbus_vortrieb.schutzrohr (
	id uuid DEFAULT dns_netzwerk_uuid('schutzrohr'),
	geom geometry('LINESTRING', 25833) NOT NULL,
	produkt_id text,
	foerdert_status text,-- NOT NULL,
	planung_status text NOT NULL,
	aggregation_id text,
	cluster integer,	
	constraint pk_prj_cottbus_vortrieb_schutzrohr PRIMARY KEY (id)
);
ALTER TABLE prj_cottbus_vortrieb.schutzrohr ADD CONSTRAINT fk_prj_cottbus_vortrieb_schutzrohr_produkt FOREIGN KEY(produkt_id) REFERENCES _produkt_katalog(_produkt) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.schutzrohr ADD CONSTRAINT fk_prj_cottbus_vortrieb_schutzrohr_status FOREIGN KEY (planung_status) REFERENCES enum_planungsstatus(val) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.schutzrohr ADD CONSTRAINT fk_prj_cottbus_vortrieb_schutzrohr_foerdert FOREIGN KEY (foerdert_status) REFERENCES enum_foerdertstatus(val) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.schutzrohr ADD CONSTRAINT fk_prj_cottbus_vortrieb_schutzrohr_custer FOREIGN KEY (cluster) REFERENCES _cluster(id) ON UPDATE CASCADE;
CREATE INDEX inxfk_prj_cottbus_vortrieb_schutzrohr_produktid ON prj_cottbus_vortrieb.schutzrohr(produkt_id);
CREATE INDEX inx_prj_cottbus_vortrieb_schutzrohr_cluster ON prj_cottbus_vortrieb.schutzrohr(cluster);
CREATE INDEX inx_prj_cottbus_vortrieb_schutzrohr_geom ON prj_cottbus_vortrieb.schutzrohr USING GIST(geom);



CREATE TABLE prj_cottbus_vortrieb.rohr_schutzrohr (
	schutzrohr_id uuid Not NUll,
	rohr_id uuid,
	cluster integer,	
	CONSTRAINT pk_prj_cottbus_vortrieb_rohr_schutzrohr PRIMARY KEY (schutzrohr_id,rohr_id)
);
ALTER TABLE prj_cottbus_vortrieb.rohr_schutzrohr ADD CONSTRAINT fk_prj_cottbus_vortrieb_rohr_schutzrohr_schutz_id FOREIGN KEY (schutzrohr_id) REFERENCES prj_cottbus_vortrieb.schutzrohr(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.rohr_schutzrohr ADD CONSTRAINT fk_prj_cottbus_vortrieb_rohr_schutzrohr_rohr_id FOREIGN KEY (rohr_id) REFERENCES prj_cottbus_vortrieb.rohr(id) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.rohr_schutzrohr ADD CONSTRAINT fk_prj_cottbus_vortrieb_rohr_schutzrohr_custer FOREIGN KEY (cluster) REFERENCES _cluster(id) ON UPDATE CASCADE;
CREATE INDEX inxfk_prj_cottbus_vortrieb_rohr_schutzrohr_schutz ON prj_cottbus_vortrieb.rohr_schutzrohr(schutzrohr_id);
CREATE INDEX inxfk_prj_cottbus_vortrieb_rohr_schutzrohr_rohr ON prj_cottbus_vortrieb.rohr_schutzrohr(rohr_id);
CREATE INDEX inx_prj_cottbus_vortrieb_rohr_schutzrohr_cluster ON prj_cottbus_vortrieb.rohr_schutzrohr(cluster);


CREATE TABLE prj_cottbus_vortrieb.strecke (
	_id uuid, -- DEFAULT dns_netzwerk_uuid('strecke'),
	typ text NOT NULL,
	cluster integer,
	CONSTRAINT pk_prj_cottbus_vortrieb_strecke PRIMARY KEY (_id) 
);
ALTER TABLE prj_cottbus_vortrieb.strecke ADD CONSTRAINT fk_prj_cottbus_vortrieb_strecke_strecketyp FOREIGN KEY (typ) REFERENCES enum_strecke_typ(val) ON UPDATE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.strecke ADD CONSTRAINT fk_prj_cottbus_vortrieb_strecke_cluster FOREIGN KEY (cluster) REFERENCES _cluster(id) ON UPDATE CASCADE;
CREATE INDEX inx_prj_cottbus_vortrieb_strecke_cluster ON prj_cottbus_vortrieb.strecke(cluster);



CREATE TABLE prj_cottbus_vortrieb.linear_object (
	id uuid DEFAULT dns_netzwerk_uuid('linear_object'),
	geom geometry('Linestring',25833) NOT NULL,
	cluster integer,
	CONSTRAINT pk_prj_cottbus_vortrieb_linear_object PRIMARY KEY (id)
);
ALTER TABLE prj_cottbus_vortrieb.linear_object ADD CONSTRAINT fk_prj_cottbus_vortrieb_linearobject_cluster FOREIGN KEY (cluster) REFERENCES _cluster(id) ON UPDATE CASCADE;
CREATE INDEX inx_prj_cottbus_vortrieb_linearobject_cluster ON prj_cottbus_vortrieb.linear_object(cluster);
CREATE INDEX inx_prj_cottbus_vortrieb_linearobject_geom ON prj_cottbus_vortrieb.linear_object USING GIST(geom);





CREATE TABLE prj_cottbus_vortrieb.strecke_line (
	strecke_id uuid,
	segment_id uuid,
	cluster integer,
	CONSTRAINT pk_prj_cottbus_vortrieb_strecke_line PRIMARY KEY (strecke_id, segment_id)
);
ALTER TABLE prj_cottbus_vortrieb.strecke_line ADD CONSTRAINT fk_prj_cottbus_vortrieb_streckeline_streckeid FOREIGN KEY (strecke_id) REFERENCES prj_cottbus_vortrieb.strecke(_id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.strecke_line ADD CONSTRAINT fk_prj_cottbus_vortrieb_streckeline_segmentid FOREIGN KEY (segment_id) REFERENCES prj_cottbus_vortrieb.linear_object(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE prj_cottbus_vortrieb.strecke_line ADD CONSTRAINT fk_prj_cottbus_vortrieb_streckeline_cluster FOREIGN KEY (cluster) REFERENCES _cluster(id) ON UPDATE CASCADE;
CREATE INDEX inxfk_prj_cottbus_vortrieb_streckeline_streckeid ON prj_cottbus_vortrieb.strecke_line(strecke_id);
CREATE INDEX inxfk_prj_cottbus_vortrieb_streckeline_segmentid ON prj_cottbus_vortrieb.strecke_line(segment_id);
CREATE INDEX inx_prj_cottbus_vortrieb_streckeline_cluster ON prj_cottbus_vortrieb.strecke_line(cluster);







































