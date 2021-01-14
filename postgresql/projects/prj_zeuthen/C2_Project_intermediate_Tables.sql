/*Create tables of the comsof output

prerequisite:
	- C1_Before_COMSOF_Import.sql
	
DNS GIS-Group
15-10-2020
*/
/* Drop if esixts #############################################################################################*/


DROP TABLE IF EXISTS comsof.linear_object cascade;
DROP TABLE IF EXISTS comsof.strecke_line cascade;
DROP TABLE IF EXISTS comsof.strecke cascade;
DROP TABLE IF EXISTS comsof.rohr_schutzrohr;
DROP TABLE IF EXISTS comsof.schutzrohr;
DROP TABLE IF EXISTS comsof.trasse;
DROP TABLE IF EXISTS comsof.microduct;
DROP TABLE IF EXISTS comsof.rohr;
DROP TABLE IF EXISTS comsof.kabel cascade;
DROP TABLE IF EXISTS comsof.faser;
DROP TABLE IF EXISTS comsof.connection_element;
DROP TABLE IF EXISTS comsof.connection_unit;
DROP TABLE IF EXISTS comsof.connection_module;
DROP TABLE IF EXISTS comsof.abschlusspunkte_kunden;
DROP TABLE IF EXISTS comsof.adresse_abschluss;
DROP TABLE IF EXISTS comsof.abschlusspunkte;
DROP TABLE IF EXISTS comsof.knoten;

----/*###	TABLE CREATION	###########################################################################################################################*/



CREATE TABLE comsof.knoten (
	id serial,
	uuid uuid DEFAULT dns_netzwerk_uuid('knoten') ,
	bez text,
	geom geometry('POINT',25833),
	typ text NOT NULL,
	subtyp text NOT NULL,
	foerdert_status text,
	planung_status text NOT NULL default 'Grobplanung',
	produkt_id text,
	label_prefix text, -- N for NVT, H for Hausanschluss .....
	label_wert text, -- The integer part of the label
	cluster integer,
	CONSTRAINT pk_comsof_knoten PRIMARY KEY(id)
);
ALTER TABLE comsof.knoten ADD CONSTRAINT fk_comsof_knoten_typ FOREIGN KEY (typ) REFERENCES enum_knoten_typ(val) ON UPDATE CASCADE;
ALTER TABLE comsof.knoten ADD CONSTRAINT fk_comsof_knoten_subtyp FOREIGN KEY (subtyp) REFERENCES enum_knoten_subtyp(val)on UPDATE CASCADE;
ALTER TABLE comsof.knoten ADD CONSTRAINT fk_comsof_knoten_status FOREIGN KEY(planung_status) REFERENCES enum_planungsstatus(val) ON UPDATE CASCADE;
ALTER TABLE comsof.knoten ADD CONSTRAINT fk_comsof_knoten_foerdert FOREIGN KEY (foerdert_status) REFERENCES enum_foerdertstatus(val) ON UPDATE CASCADE;
ALTER TABLE comsof.knoten ADD CONSTRAINT fk_comsof_knoten_produkt FOREIGN KEY(produkt_id) REFERENCES _produkt_katalog(_produkt) ON UPDATE CASCADE;
ALTER TABLE comsof.knoten ADD CONSTRAINT fk_comsof_knoten_cluster FOREIGN KEY(cluster) REFERENCES _cluster(id) ON UPDATE CASCADE;
CREATE INDEX inxfk_comsof_knoten_produktid ON comsof.knoten(produkt_id);
CREATE INDEX inxfk_comsof_knoten_cluster ON comsof.knoten(cluster);
CREATE INDEX inx_comsof_knoten_geom ON comsof.knoten USING GIST(geom);




CREATE TABLE comsof.abschlusspunkte(
	id serial,
	uuid uuid DEFAULT dns_netzwerk_uuid('abschlusspunkte'),
	geom geometry('POINT',25833),
	knoten_id integer NOT NULL,
	knoten_uuid uuid,
	typ text NOT NULL,
	einbauort text,
	homeconnect_status text,
	cluster integer,
	CONSTRAINT pk_comsof_abschlusspunkte PRIMARY KEY(id)
);
ALTER TABLE comsof.abschlusspunkte ADD CONSTRAINT fk_comsof_abschlusspunkte_knoten FOREIGN KEY(knoten_id) REFERENCES comsof.knoten(id) ON UPDATE CASCADE;
ALTER TABLE comsof.abschlusspunkte ADD CONSTRAINT fk_comsof_abschlusspunkte_typ FOREIGN KEY(typ) REFERENCES enum_abschlusspunkte_typ(val) ON UPDATE CASCADE;
ALTER TABLE comsof.abschlusspunkte ADD CONSTRAINT fk_comsof_abschlusspunkte_einabuort FOREIGN KEY(einbauort) REFERENCES enum_abschlusspunkte_einbauort(val) ON UPDATE CASCADE;
ALTER TABLE comsof.abschlusspunkte ADD CONSTRAINT fk_comsof_abschlusspunkte_hc FOREIGN KEY(homeconnect_status) REFERENCES enum_hc_status(val) ON UPDATE CASCADE;
ALTER TABLE comsof.abschlusspunkte ADD CONSTRAINT fk_comsof_abschlusspunkte_cluster FOREIGN KEY (cluster) REFERENCES _cluster(id) ON UPDATE CASCADE;
CREATE INDEX inx_comsof_abschlusspunkte_knotenid ON comsof.abschlusspunkte(knoten_id);
CREATE INDEX inx_comsof_abschlusspunkte_cluster ON comsof.abschlusspunkte(cluster);
CREATE INDEX inx_comsof_abschlusspunkte_geom ON comsof.abschlusspunkte USING GIST(geom);




CREATE TABLE comsof.adresse_abschluss(
	id serial,
	adresse_id uuid,
	--adresse_uuid uuid,
	abschlusspunkte_id integer,
	abschlusspunkte_uuid uuid,
	cluster integer,
	CONSTRAINT pk_comsof_adresse_abschluss PRIMARY KEY(adresse_id, abschlusspunkte_id)
);
ALTER TABLE comsof.adresse_abschluss ADD CONSTRAINT fk_comsof_adresseabschluss_adresse FOREIGN KEY (adresse_id) REFERENCES adressen.adressen(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE comsof.adresse_abschluss ADD CONSTRAINT fk_comsof_adresseabschluss_abschluss FOREIGN KEY (abschlusspunkte_id)REFERENCES comsof.abschlusspunkte(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE comsof.adresse_abschluss ADD CONSTRAINT fk_comsof_adresseabschluss_cluster FOREIGN KEY (cluster) REFERENCES _cluster(id) ON UPDATE CASCADE;
CREATE INDEX inxfk_comsof_adresseabschluss_adresse ON comsof.adresse_abschluss(adresse_id);
CREATE INDEX inx_comsof_adresseabschluss_cluster ON comsof.adresse_abschluss(cluster);
CREATE INDEX inxfk_comsof_adresseabschluss_abschlu ON comsof.adresse_abschluss(abschlusspunkte_id);




CREATE TABLE comsof.abschlusspunkte_kunden (
	id serial,
	uuid uuid DEFAULT dns_netzwerk_uuid('attribute'),
	abschlusspunkte_id integer NOT NULL,
	abschlusspunkte_uuid uuid,
	sid varchar(25) NOT NULL,
	vertriebsstatus text NOT NULL,
	active text,
	cluster integer,
	CONSTRAINT pk_comsof_abschlusspunkte_kunden PRIMARY KEY (id)
);
ALTER TABLE comsof.abschlusspunkte_kunden ADD CONSTRAINT fk_comsof_abschlusspunktekunden_abschlusspunkte FOREIGN KEY (abschlusspunkte_id) REFERENCES comsof.abschlusspunkte(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE comsof.abschlusspunkte_kunden ADD CONSTRAINT fk_comsof_abschlusspunktekunden_vertriebsstatus FOREIGN KEY (vertriebsstatus) REFERENCES enum_vertriebsstatus(val) ON UPDATE CASCADE;
ALTER TABLE comsof.abschlusspunkte_kunden ADD CONSTRAINT fk_comsof_abschlusspunktekunden_active FOREIGN KEY (active) REFERENCES enum_ja_nein(val) ON UPDATE CASCADE;
ALTER TABLE comsof.abschlusspunkte_kunden ADD CONSTRAINT fk_comsof_abschlusspunktekunden_cluster FOREIGN KEY (cluster) REFERENCES _cluster(id) ON UPDATE CASCADE;
CREATE INDEX inxfk_comsof_abschlusspunktekunden_abschlusspunkte ON comsof.abschlusspunkte_kunden(abschlusspunkte_id);
CREATE INDEX inx_comsof_abschlusspunktekunden_cluster ON comsof.abschlusspunkte_kunden(cluster);





CREATE TABLE comsof.connection_module (
	id serial,
	uuid uuid DEFAULT dns_netzwerk_uuid('connection_module'),
	typ text NOT NULL,
	produkt_id text,
	knoten_id integer NOT NULL,
	knoten_uuid uuid,
	netzebene_quelle text NOT NULL,
	netzebene_ziel text NOT NULL,
	eigentum_status text NOT NULL DEFAULT 'Eigentum',
	foerdert_status text,
	planung_status text NOT NULL default 'Grobplanung',
	cluster integer,
	CONSTRAINT pk_comsof_connection_module PRIMARY KEY (id)
);
ALTER TABLE comsof.connection_module ADD CONSTRAINT fk_comsof_connectionmodule_typ FOREIGN KEY (typ) REFERENCES enum_connmodule_typ(val) ON UPDATE CASCADE;
ALTER TABLE comsof.connection_module ADD CONSTRAINT fk_comsof_connectionmodule_produkt FOREIGN KEY(produkt_id) REFERENCES _produkt_katalog(_produkt) ON UPDATE CASCADE;
ALTER TABLE comsof.connection_module ADD CONSTRAINT fk_comsof_connectionmodule_knoten FOREIGN KEY (knoten_id) REFERENCES comsof.knoten(id) ON UPDATE CASCADE;
ALTER TABLE comsof.connection_module ADD CONSTRAINT fk_comsof_connectionmodule_netzebene_quel FOREIGN KEY (netzebene_quelle) REFERENCES enum_netzebene(val) ON UPDATE CASCADE;
ALTER TABLE comsof.connection_module ADD CONSTRAINT fk_comsof_connectionmodule_netzebene_ziel FOREIGN KEY (netzebene_ziel) REFERENCES enum_netzebene(val) ON UPDATE CASCADE;
ALTER TABLE comsof.connection_module ADD CONSTRAINT fk_comsof_connectionmodule_eigentum FOREIGN KEY (eigentum_status) REFERENCES enum_eigentum(val) ON UPDATE CASCADE;
ALTER TABLE comsof.connection_module ADD CONSTRAINT fk_comsof_connectionmodule_foerdert FOREIGN KEY (foerdert_status) REFERENCES enum_foerdertstatus(val) ON UPDATE CASCADE;
ALTER TABLE comsof.connection_module ADD CONSTRAINT fk_comsof_connectionmodule_cluster FOREIGN KEY (cluster) REFERENCES _cluster(id) ON UPDATE CASCADE;
alter table comsof.connection_module ADD Constraint unq_comsof_connectionmodule_id_knoten unique (id,knoten_id ); -- it is referenced as a foreign key in microdukt.
CREATE INDEX inxfk_comsof_connmodule_knotenid ON comsof.connection_module(knoten_id);
CREATE INDEX inxfk_comsof_connmodule_produktid ON comsof.connection_module(produkt_id);
CREATE INDEX inx_comsof_connmodule_cluster ON comsof.connection_module(cluster);




CREATE TABLE comsof.connection_unit (
	id serial,
	uuid uuid DEFAULT dns_netzwerk_uuid('connection_unit'),
	conn_module_id integer NOT NULL,
	conn_module_uuid uuid,
	produkt_id text,
	letzten_datum_mod date,
	cluster integer,
	CONSTRAINT pk_comsof_connection_unit PRIMARY KEY (id) 
);
ALTER TABLE comsof.connection_unit ADD CONSTRAINT fk_comsof_connectionunit_connmodule FOREIGN KEY(conn_module_id) REFERENCES comsof.connection_module(id) ON UPDATE CASCADE;
ALTER TABLE comsof.connection_unit ADD CONSTRAINT fk_comsof_connectionunit_produkt FOREIGN KEY(produkt_id) REFERENCES _produkt_katalog(_produkt) ON UPDATE CASCADE;
ALTER TABLE comsof.connection_unit ADD CONSTRAINT fk_comsof_connectionunit_cluster FOREIGN KEY(cluster) REFERENCES _cluster(id)ON UPDATE CASCADE;
CREATE INDEX inxfk_comsof_connunit_connmoduleid ON comsof.connection_unit(conn_module_id);
CREATE INDEX inxfk_comsof_connunit_produktid ON comsof.connection_unit(produkt_id);
CREATE INDEX inx_comsof_connunit_cluster ON comsof.connection_unit(cluster);



CREATE TABLE comsof.connection_element(
	id serial,
	uuid uuid DEFAULT dns_netzwerk_uuid('connection_element'),
	conn_unit_id integer NOT NULL,
	conn_unit_uuid uuid,
	produkt_id text,
	typ text NOT NULL default 'Passive',
	subtyp text NOT NULL,
	installation_ziele dom_zahl default 1,
	installation_spalte dom_zahl default 1,
	label text,
	mehrdetail text,
	cluster integer,
	CONSTRAINT pk_comsof_connectionelement PRIMARY KEY(id)
);
ALTER TABLE comsof.connection_element ADD CONSTRAINT fk_comsof_connectionelem_unit FOREIGN KEY (conn_unit_id) REFERENCES comsof.connection_unit(id) ON UPDATE CASCADE;
ALTER TABLE comsof.connection_element ADD CONSTRAINT fk_comsof_connectionelem_produkt FOREIGN KEY(produkt_id) REFERENCES _produkt_katalog(_produkt) ON UPDATE CASCADE;
ALTER TABLE comsof.connection_element ADD CONSTRAINT fk_comsof_connectionelem_typ FOREIGN KEY (typ) REFERENCES enum_connelement_typ(val) ON UPDATE CASCADE;
ALTER TABLE comsof.connection_element ADD CONSTRAINT fk_comsof_connectionelem_subtyp FOREIGN KEY (subtyp) REFERENCES enum_connelement_subtyp(val) ON UPDATE CASCADE;
ALTER TABLE comsof.connection_element ADD CONSTRAINT fk_comsof_connectionelem_cluster FOREIGN KEY (cluster) REFERENCES _cluster(id) ON UPDATE CASCADE;
CREATE INDEX inxfk_comsof_connelement_connunitid ON comsof.connection_element(conn_unit_id);
CREATE INDEX inxfk_comsof_connelement_produktid ON comsof.connection_element(produkt_id);
CREATE INDEX inx_comsof_connelement_cluster ON comsof.connection_element(cluster);





CREATE TABLE comsof.kabel (
	id serial,
	uuid uuid DEFAULT dns_netzwerk_uuid('KABEL'),
	bez text, -- used for bezeicnung MRV06565/fid
	geom geometry('LINESTRING',25833),
	produkt_id text,
	anzahl_fasern dom_zahl NOT NULL,
	typ text NOT NULL Default 'Kabel',
	netzebene text NOT NULL,
	conn_module_anfang integer NOT NULL,
	conn_module_anfang_uuid uuid,
	conn_module_ende integer,
	conn_module_ende_uuid uuid,
	foerdert_status text,-- NOT NULL,
	planung_status text NOT NULL,
	eigentum_status text NOT NULL Default 'Eigentum',
	homeconnect_status text,
	length numeric,
	cluster integer,	
	CONSTRAINT pk_comsof_kabel PRIMARY KEY (id)
);
ALTER TABLE comsof.kabel ADD CONSTRAINT fk_comsof_kabel_typ FOREIGN KEY (typ) REFERENCES enum_kabel_typ(val) ON UPDATE CASCADE;
ALTER TABLE comsof.kabel ADD CONSTRAINT fk_comsof_kabel_produkt FOREIGN KEY(produkt_id) REFERENCES _produkt_katalog(_produkt) ON UPDATE CASCADE;
ALTER TABLE comsof.kabel ADD CONSTRAINT fk_comsof_kabel_netzebene FOREIGN KEY (netzebene) REFERENCES enum_netzebene(val) ON UPDATE CASCADE;
ALTER TABLE comsof.kabel ADD CONSTRAINT fk_comsof_kabel_conn_module_anfang FOREIGN KEY (conn_module_anfang) REFERENCES comsof.connection_module(id) ON UPDATE CASCADE;
ALTER TABLE comsof.kabel ADD CONSTRAINT fk_comsof_kabel_conn_module_ende FOREIGN KEY (conn_module_ende) REFERENCES comsof.connection_module(id) ON UPDATE CASCADE;
ALTER TABLE comsof.kabel ADD CONSTRAINT fk_comsof_kabel_status FOREIGN KEY(planung_status) REFERENCES enum_planungsstatus(val) ON UPDATE CASCADE;
ALTER TABLE comsof.kabel ADD CONSTRAINT fk_comsof_kabel_foerdert FOREIGN KEY (foerdert_status) REFERENCES enum_foerdertstatus(val) ON UPDATE CASCADE;
ALTER TABLE comsof.kabel ADD CONSTRAINT fk_comsof_kabel_eigentum FOREIGN KEY(eigentum_status) REFERENCES enum_eigentum(val) ON UPDATE CASCADE;
ALTER TABLE comsof.kabel ADD CONSTRAINT fk_comsof_kabel_hc FOREIGN KEY(homeconnect_status) REFERENCES enum_hc_status(val) ON UPDATE CASCADE;
ALTER TABLE comsof.kabel ADD CONSTRAINT fk_comsof_kabel_cluster FOREIGN KEY (cluster) REFERENCES _cluster(id) ON UPDATE CASCADE;
alter table comsof.kabel ADD CONSTRAINT fk_comsof_kabel_produkt_anzahlfaser FOREIGN key (produkt_id, anzahl_fasern) references pr_kabel(produkt,anzahl_faser) on update cascade; -- control the numebr of rohr with produkt
CREATE INDEX inxfk_comsof_kabel_produktid ON comsof.kabel(produkt_id);
CREATE INDEX inxfk_comsof_kabel_connmodule_anfang ON comsof.kabel(conn_module_anfang);
CREATE INDEX inxfk_comsof_kabel_connmodule_ende ON comsof.kabel(conn_module_ende);
CREATE INDEX inx_comsof_kabel_cluster ON comsof.kabel(cluster);
CREATE INDEX inx_comsof_kabel_geom ON comsof.kabel USING GIST(geom);




CREATE TABLE comsof.faser (
	id serial,
	uuid uuid DEFAULT dns_netzwerk_uuid('faser'),
	bez text,
	geom geometry('LINESTRING',25833),
	kabel_id integer NOT NULL,
	kabel_uuid uuid,
	netzebene text NOT NULL,
	buendeln_nr dom_zahl NOT NULL,
	faser_label text,
	conn_element_anfang integer NOT NULL,
	conn_element_anfang_uuid uuid,
	anf_elem_output_nr dom_zahl,/*input_nr integer,*/
	anfang_typ text default 'Nicht angegeben',/*input_typ text default 'Nicht angegeben',*/
	anfang_label text,
	conn_element_ende integer NOT NULL,
	conn_element_ende_uuid uuid,
	end_elem_input_nr dom_zahl,/*output_nr integer,*/
	ende_typ text default 'Nicht angegeben',/*output_typ text default 'Nicht angegeben',*/
	ende_label text,
	length numeric,
	external_id text,
	cluster integer,
	CONSTRAINT pk_comsof_faser PRIMARY KEY (id)
);
ALTER TABLE comsof.faser ADD CONSTRAINT fk_comsof_faser_kabel FOREIGN KEY (kabel_id) REFERENCES comsof.kabel(id)on UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE comsof.faser ADD CONSTRAINT fk_comsof_faser_netzebene FOREIGN KEY (netzebene) REFERENCES enum_netzebene(val) ON UPDATE CASCADE;
ALTER TABLE comsof.faser ADD CONSTRAINT fk_comsof_faser_connelement_anfang FOREIGN KEY (conn_element_anfang) REFERENCES comsof.connection_element(id) ON UPDATE CASCADE;
ALTER TABLE comsof.faser ADD CONSTRAINT fk_comsof_faser_connelement_ende FOREIGN KEY (conn_element_ende) REFERENCES comsof.connection_element(id) ON UPDATE CASCADE;
ALTER TABLE comsof.faser ADD CONSTRAINT fk_comsof_faser_input_type FOREIGN KEY (anfang_typ) REFERENCES enum_faserconn(val) ON UPDATE CASCADE;
ALTER TABLE comsof.faser ADD CONSTRAINT fk_comsof_faser_output_type FOREIGN KEY (ende_typ) REFERENCES enum_faserconn(val) ON UPDATE CASCADE;
ALTER TABLE comsof.faser ADD CONSTRAINT fk_comsof_faser_cluster FOREIGN KEY (cluster) REFERENCES _cluster(id) ON UPDATE CASCADE;
CREATE INDEX inxfk_comsof_faser_kabel_id ON comsof.faser(kabel_id);
CREATE INDEX inxfk_comsof_faser_connelement_anfang ON comsof.faser(conn_element_anfang);
CREATE INDEX inxfk_comsof_faser_connelement_ende ON comsof.faser(conn_element_ende);
CREATE INDEX inx_comsof_faser_cluster ON comsof.faser(cluster);
CREATE INDEX inx_comsof_faser_geom ON comsof.faser USING GIST(geom);




CREATE TABLE comsof.rohr (
	id serial,
	uuid uuid DEFAULT dns_netzwerk_uuid('rohr'),
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
	top_agg_id text,
	bez_wert text,
	cluster integer,
	CONSTRAINT pk_comsof_rohr PRIMARY KEY (id)
);
ALTER TABLE comsof.rohr ADD CONSTRAINT fk_comsof_rohr_typ FOREIGN KEY (typ) REFERENCES enum_rohr_typ(val) ON UPDATE CASCADE;
ALTER TABLE comsof.rohr ADD CONSTRAINT fk_comsof_rohr_produkt FOREIGN KEY(produkt_id) REFERENCES _produkt_katalog(_produkt) ON UPDATE CASCADE;
ALTER TABLE comsof.rohr ADD CONSTRAINT fk_comsof_rohr_mantel_farbe FOREIGN KEY(mantel_farbe) REFERENCES enum_farbe(val) ON UPDATE CASCADE;
ALTER TABLE comsof.rohr ADD CONSTRAINT fk_comsof_rohr_status FOREIGN KEY (planung_status) REFERENCES enum_planungsstatus(val) ON UPDATE CASCADE; 
ALTER TABLE comsof.rohr ADD CONSTRAINT fk_comsof_rohr_foerdert FOREIGN KEY (foerdert_status) REFERENCES enum_foerdertstatus(val) ON UPDATE CASCADE;
ALTER TABLE comsof.rohr ADD CONSTRAINT fk_comsof_rohr_netzebene FOREIGN KEY (netzebene) REFERENCES enum_netzebene(val) ON UPDATE CASCADE;
ALTER TABLE comsof.rohr ADD CONSTRAINT fk_comsof_rohr_hc_status FOREIGN KEY (homeconnect_status) REFERENCES enum_hc_status(val) ON UPDATE CASCADE;
ALTER TABLE comsof.rohr ADD CONSTRAINT fk_comsof_rohr_cluster FOREIGN KEY (cluster) REFERENCES _cluster(id) ON UPDATE CASCADE;
alter table comsof.rohr ADD CONSTRAINT fk_comsof_rohr_produkt_anzahlmicroduct FOREIGN key (produkt_id, anzahl_microducts) references pr_rohr(produkt,anzahl_microducts) on update cascade;-- control the numebr of rohr with produkt
CREATE INDEX inxfk_comsof_rohr_produktid ON comsof.rohr(produkt_id);
CREATE INDEX inx_comsof_rohr_cluster ON comsof.rohr(cluster);
CREATE INDEX inx_comsof_rohr_topaggid on comsof.rohr(top_agg_id);
CREATE INDEX inx_comsof_rohr_geom ON comsof.rohr USING GIST(geom);




CREATE TABLE comsof.microduct (
	id serial,
	uuid uuid DEFAULT dns_netzwerk_uuid('microduct'),
	bez text, -- ror_name / microduct nr
	geom geometry('LINESTRING',25833),
	rohr_id integer NOT NULL,
	rohr_uuid uuid,
	microduct_nr dom_zahl NOT NULL,
	knoten_anfang integer Not Null,
	knoten_anfang_uuid uuid,
	conn_module_anfang integer,
	conn_module_anfang_uuid uuid,
	conn_module_anfang_label text,--which  input of connection_module
	knoten_ende integer,
	knoten_ende_uuid uuid,
	conn_module_ende integer,
	conn_module_ende_uuid uuid,
	conn_module_ende_label text,--which  input of connection_module
	stammt_von integer,
	stammt_von_uuid uuid,
	bottom_agg_id text,-- identifies the microducts that are connected to eachother in each netzebene. it is the uuid of underlying knoten_id.(e.g. th uuid of hausanschluss_koten in verteiler ebene) 
	zweig dom_zahl Default 1,-- determines the order of branch.
	kabel_id integer,
	kabel_uuid uuid,
	netzebene text NOT NULL,
	bez_wert text,
	cluster integer,
	CONSTRAINT pk_comsof_microduct PRIMARY KEY (id)
);
ALTER TABLE comsof.microduct ADD CONSTRAINT fk_comsof_microduct_rohr FOREIGN KEY (rohr_id) REFERENCES comsof.rohr(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE comsof.microduct ADD CONSTRAINT fk_comsof_microduct_knoten_anfang FOREIGN KEY (knoten_anfang) REFERENCES comsof.knoten(id) ON UPDATE CASCADE;
ALTER TABLE comsof.microduct ADD CONSTRAINT fk_comsof_microduct_knoten_ende FOREIGN KEY (knoten_ende) REFERENCES comsof.knoten(id) ON UPDATE CASCADE;
ALTER TABLE comsof.microduct ADD CONSTRAINT fk_comsof_microduct_stammtvon FOREIGN KEY (stammt_von) REFERENCES comsof.microduct(id) ON UPDATE CASCADE;
ALTER TABLE comsof.microduct ADD CONSTRAINT fk_comsof_microduct_kabel_id FOREIGN KEY (kabel_id) REFERENCES comsof.kabel(id) ON UPDATE CASCADE;
ALTER TABLE comsof.microduct ADD CONSTRAINT fk_comsof_microduct_netzebene FOREIGN KEY (netzebene) REFERENCES enum_netzebene(val) ON UPDATE CASCADE;
ALTER TABLE comsof.microduct ADD CONSTRAINT fk_comsof_microduct_cluster FOREIGN KEY (cluster) REFERENCES _cluster(id) ON UPDATE CASCADE;
--alter table comsof.microduct ADD constraint fk_comsof_microduct_connmodule_anf FOREIGN KEY (knoten_anfang, conn_module_anfang) references comsof.connection_module (id,knoten_id) on update cascade;
--alter table comsof.microduct ADD constraint fk_comsof_microduct_connmodule_end FOREIGN KEY (knoten_ende, conn_module_ende) references comsof.connection_module (id, knoten_id) on update cascade;
alter table comsof.microduct ADD constraint fk_comsof_microduct_connmodule_anf FOREIGN KEY (knoten_anfang, conn_module_anfang) references comsof.connection_module (knoten_id, id) on update cascade;
alter table comsof.microduct ADD constraint fk_comsof_microduct_connmodule_end FOREIGN KEY (knoten_ende, conn_module_ende) references comsof.connection_module (knoten_id, id) on update cascade;
CREATE INDEX inxfk_comsof_microduct_rohr ON comsof.microduct(rohr_id);
CREATE INDEX inxfk_comsof_microduct_knot_anf ON comsof.microduct(knoten_anfang);
CREATE INDEX inxfk_comsof_microduct_knot_ende ON comsof.microduct(knoten_ende);
CREATE INDEX inxfk_comsof_microduct_stammtvon ON comsof.microduct(stammt_von);
CREATE INDEX inx_comsof_microduct_btnaggid on comsof.microduct(bottom_agg_id);
CREATE INDEX inxfk_comsof_microduct_kabelud ON comsof.microduct(kabel_id);
CREATE INDEX inx_comsof_microduct_cluster ON comsof.microduct(cluster);
CREATE INDEX inx_comsof_microduct_geom ON comsof.microduct USING GIST(geom);




CREATE TABLE comsof.trasse (
	id serial,
	uuid uuid DEFAULT dns_netzwerk_uuid('trasse'),
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
	CONSTRAINT pk_comsof_trasse PRIMARY KEY (id)
);
ALTER TABLE comsof.trasse ADD CONSTRAINT fk_comsof_trasse_typ FOREIGN KEY (typ) REFERENCES enum_trasse_typ (val) ON UPDATE CASCADE;
ALTER TABLE comsof.trasse ADD CONSTRAINT fk_comsof_trasse_bauverfahr FOREIGN KEY (trassenbauverfahren) REFERENCES enum_trassenbauverfahren(val) ON UPDATE CASCADE;
ALTER TABLE comsof.trasse ADD CONSTRAINT fk_comsof_trasse_oberflaeche FOREIGN KEY (oberflaeche) REFERENCES enum_trasse_oberflaeche(val) ON UPDATE CASCADE;
ALTER TABLE comsof.trasse ADD CONSTRAINT fk_comsof_trasse_widmung FOREIGN KEY (widmung) REFERENCES enum_widmung(val) ON UPDATE CASCADE;
ALTER TABLE comsof.trasse ADD CONSTRAINT fk_comsof_trasse_foerdert FOREIGN KEY (foerdert_status) REFERENCES enum_foerdertstatus ON UPDATE CASCADE;
ALTER TABLE comsof.trasse ADD CONSTRAINT fk_comsof_trasse_status FOREIGN KEY (planung_status) REFERENCES enum_planungsstatus ON UPDATE CASCADE;
ALTER TABLE comsof.trasse ADD CONSTRAINT fk_comsof_trasse_netzebene FOREIGN KEY (netzebene) REFERENCES enum_netzebene(val) ON UPDATE CASCADE;
ALTER TABLE comsof.trasse ADD CONSTRAINT fk_comsof_trasse_hc_status FOREIGN KEY (homeconnect_status) REFERENCES enum_hc_status(val) ON UPDATE CASCADE;
ALTER TABLE comsof.trasse ADD CONSTRAINT fk_comsof_trasse_cluster FOREIGN KEY (cluster) REFERENCES _cluster(id) ON UPDATE CASCADE;
CREATE INDEX inx_comsof_trasse_cluster ON comsof.trasse(cluster);
CREATE INDEX inx_comsof_trasse_geom ON comsof.trasse USING GIST(geom);



CREATE TABLE comsof.schutzrohr (
	id serial,
	uuid uuid DEFAULT dns_netzwerk_uuid('schutzrohr'),
	geom geometry('LINESTRING', 25833) NOT NULL,
	produkt_id text,
	foerdert_status text,-- NOT NULL,
	planung_status text NOT NULL,
	aggregation_id text,
	cluster integer,	
	constraint pk_comsof_schutzrohr PRIMARY KEY (id)
);
ALTER TABLE comsof.schutzrohr ADD CONSTRAINT fk_comsof_schutzrohr_produkt FOREIGN KEY(produkt_id) REFERENCES _produkt_katalog(_produkt) ON UPDATE CASCADE;
ALTER TABLE comsof.schutzrohr ADD CONSTRAINT fk_comsof_schutzrohr_status FOREIGN KEY (planung_status) REFERENCES enum_planungsstatus(val) ON UPDATE CASCADE;
ALTER TABLE comsof.schutzrohr ADD CONSTRAINT fk_comsof_schutzrohr_foerdert FOREIGN KEY (foerdert_status) REFERENCES enum_foerdertstatus(val) ON UPDATE CASCADE;
ALTER TABLE comsof.schutzrohr ADD CONSTRAINT fk_comsof_schutzrohr_custer FOREIGN KEY (cluster) REFERENCES _cluster(id) ON UPDATE CASCADE;
CREATE INDEX inxfk_comsof_schutzrohr_produktid ON comsof.schutzrohr(produkt_id);
CREATE INDEX inx_comsof_schutzrohr_cluster ON comsof.schutzrohr(cluster);
CREATE INDEX inx_comsof_schutzrohr_geom ON comsof.schutzrohr USING GIST(geom);




CREATE TABLE comsof.rohr_schutzrohr (
	schutzrohr_id integer,
	schutzrohr_uuid uuid, --Not NUll,
	rohr_id integer,
	rohr_uuid uuid,
	cluster integer,	
	CONSTRAINT pk_comsof_rohr_schutzrohr PRIMARY KEY (schutzrohr_id,rohr_id)
);
ALTER TABLE comsof.rohr_schutzrohr ADD CONSTRAINT fk_comsof_rohr_schutzrohr_schutz_id FOREIGN KEY (schutzrohr_id) REFERENCES comsof.schutzrohr(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE comsof.rohr_schutzrohr ADD CONSTRAINT fk_comsof_rohr_schutzrohr_rohr_id FOREIGN KEY (rohr_id) REFERENCES comsof.rohr(id) ON UPDATE CASCADE;
ALTER TABLE comsof.rohr_schutzrohr ADD CONSTRAINT fk_comsof_rohr_schutzrohr_custer FOREIGN KEY (cluster) REFERENCES _cluster(id) ON UPDATE CASCADE;
CREATE INDEX inxfk_comsof_rohr_schutzrohr_schutz ON comsof.rohr_schutzrohr(schutzrohr_id);
CREATE INDEX inxfk_comsof_rohr_schutzrohr_rohr ON comsof.rohr_schutzrohr(rohr_id);
CREATE INDEX inx_comsof_rohr_schutzrohr_cluster ON comsof.rohr_schutzrohr(cluster);



CREATE TABLE comsof.strecke (
	_id bigserial unique,
	_uuid uuid,-- DEFAULT dns_netzwerk_uuid('strecke'),
	typ text NOT NULL,
	cluster integer,
	CONSTRAINT pk_comsof_strecke PRIMARY KEY (_uuid) 
);
ALTER TABLE comsof.strecke ADD CONSTRAINT fk_comsof_strecke_strecketyp FOREIGN KEY (typ) REFERENCES enum_strecke_typ(val) ON UPDATE CASCADE;
ALTER TABLE comsof.strecke ADD CONSTRAINT fk_comsof_strecke_cluster FOREIGN KEY (cluster) REFERENCES _cluster(id) ON UPDATE CASCADE;
CREATE INDEX inx_comsof_strecke_cluster ON comsof.strecke(cluster);



CREATE TABLE comsof.linear_object (
	id serial,
	uuid uuid DEFAULT dns_netzwerk_uuid('linear_object'),
	geom geometry('Linestring',25833) NOT NULL,
	cluster integer,
	CONSTRAINT pk_comsof_linear_object PRIMARY KEY (id)
);
ALTER TABLE comsof.linear_object ADD CONSTRAINT fk_comsof_linearobject_cluster FOREIGN KEY (cluster) REFERENCES _cluster(id) ON UPDATE CASCADE;
CREATE INDEX inx_comsof_linearobject_cluster ON comsof.linear_object(cluster);
CREATE INDEX inx_comsof_linearobject_geom ON comsof.linear_object USING GIST(geom);



CREATE TABLE comsof.strecke_line (
	strecke_id integer,
	strecke_uuid uuid,
	segment_id integer,
	segment_uuid uuid,
	cluster integer,
	CONSTRAINT pk_comsof_strecke_line PRIMARY KEY (strecke_id, segment_id)
);
ALTER TABLE comsof.strecke_line ADD CONSTRAINT fk_comsof_streckeline_streckeid FOREIGN KEY (strecke_id) REFERENCES comsof.strecke(_id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE comsof.strecke_line ADD CONSTRAINT fk_comsof_streckeline_segmentid FOREIGN KEY (segment_id) REFERENCES comsof.linear_object(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE comsof.strecke_line ADD CONSTRAINT fk_comsof_streckeline_cluster FOREIGN KEY (cluster) REFERENCES _cluster(id) ON UPDATE CASCADE;
CREATE INDEX inxfk_comsof_streckeline_streckeid ON comsof.strecke_line(strecke_id);
CREATE INDEX inxfk_comsof_streckeline_segmentid ON comsof.strecke_line(segment_id);
CREATE INDEX inx_comsof_streckeline_cluster ON comsof.strecke_line(cluster);

