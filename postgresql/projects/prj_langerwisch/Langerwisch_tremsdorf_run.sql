--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---    P0:
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
create schema /*if not exists*/ prj_langerwisch;

----sample feeding   _cluster


INSERT INTO _cluster(id, cluster_name, project_name, cluster_parent, onb_onkz, gemeindeschluessel, zubringerpunkt, version, beschreibung, crs_epsg, schema_name)
	values(13, 'Michendorf', null, null, '332058','{12069397}', 'BB_unknown','v_01', 'FTTx projects in Michendorf', '25833',null);
INSERT INTO _cluster(id,cluster_name, project_name, cluster_parent, onb_onkz, gemeindeschluessel, zubringerpunkt, version, beschreibung, crs_epsg, schema_name)
	values(14,'Michendorf/Langerwisch', '797', 13, '33205','{12069397}', 'BB_unknown','v_01', 'Michendorf/Langerwisch', '25833','prj_langerwisch');
	
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---    c1:
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

DELETE FROM comsof.comsof_metadata; -- it Also drops the tables with "Out_" and "in_" prifix from comsof.

---- Feeding Metadata
--Eichwalde--  insert into comsof.comsof_metadata( datum, bundesland, _epsg_code, destination_cluster, beschreibung) values ( (select Now()), 'Brandenburg', '25833', Null, 'Test_Eichwalde');
insert into comsof.comsof_metadata( datum, bundesland, _epsg_code, destination_cluster, beschreibung) values( now(), 'Brandenburg', 25833,14,'Michendorf/Langerwisch');



--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---    c2:
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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






--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---    c3:
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

insert into comsof.knoten (id, geom , typ , subtyp , planung_status, foerdert_status, cluster) select id, geom , 'Gebaeude', 'Abschlusspunkt', 'Grobplanung',null , (select destination_cluster from comsof.comsof_metadata)  from comsof.out_accessstructures where type='Building';

with sel as (select ge.id knot_id, uuid knot_uuid ,comsof.in_demandpoints.id fid, ge.geom from comsof.knoten ge join comsof.in_demandpoints on st_equals(ge.geom, comsof.in_demandpoints .geom)) 
	insert into comsof.abschlusspunkte (id,geom,  knoten_id, knoten_uuid,typ,  einbauort , homeconnect_status, cluster)  select fid , geom, knot_id ,knot_uuid , 'Gf-HUEP', Null, Null , (select destination_cluster from comsof.comsof_metadata) from sel ;
	
insert into comsof.adresse_abschluss (adresse_id, abschlusspunkte_id, abschlusspunkte_uuid, cluster)
	select uuid(ind._id) adr_uuid , ab.id ab_id, ab.uuid ab_uuid ,  ab.cluster from comsof.abschlusspunkte ab join comsof.in_demandpoints ind on st_equals(ind.geom, ab.geom)

insert into comsof.connection_module(id, typ, produkt_id, knoten_id, netzebene_quelle,netzebene_ziel, eigentum_status, foerdert_status, cluster) 
	select eq_id, 'Switch / Plugin', NULL, id, 'Verteiler-Ebene','In-House-Ebene', 'Eigentum', 'Eigenausbau',(select destination_cluster from comsof.comsof_metadata) from comsof.out_accessstructures where type = 'Building';
with sel as( select connmodule.id, knot.uuid  knot_uuid from  comsof.connection_module connmodule join comsof.knoten knot on knot.id=connmodule.knoten_id )
	update comsof.connection_module set knoten_uuid=(select knot_uuid from sel where sel.id=comsof.connection_module .id); 

/*The id of the "connection_unit" is the eq_id of the "out_closure" */
insert into comsof.connection_unit (id, conn_module_id,	produkt_id, letzten_datum_mod, cluster)
	select  eq_id , enc_eqp_id ,Null , Null, (select destination_cluster from comsof.comsof_metadata) from comsof.out_closures where layer='Demand';
with sel as (select conmod.id elem_id, connmodule.uuid from comsof.connection_module connmodule  join comsof.connection_unit conmod on conmod.conn_module_id = connmodule.id)
	update comsof.connection_unit set conn_module_uuid = (select sel.uuid from sel where sel.elem_id=comsof.connection_unit.id);

/* The id of the "connection_Element" is
	For hausanschluss or POP is the same as the id of the "connection_unit" (i.e. the eq_id of the "outer_closure" ) 
	For splitter is the splice_id of the  "outer_splitter"*/
insert into  comsof.connection_element( id,	conn_unit_id,	produkt_id,	typ, subtyp, installation_ziele,	installation_spalte , label,	 mehrdetail, cluster )
	select eq_id, eq_id, null, 'Passive', 'Switch / Plugin', Null, Null, Null, null,(select destination_cluster from comsof.comsof_metadata) from comsof.out_closures where layer='Demand'; /*only for Haus anschluss*/	
with sel as (select elem.id elem_id, unit.uuid from comsof.connection_element elem join comsof.connection_unit unit on unit.id= elem.conn_unit_id)
	update comsof.connection_element set conn_unit_uuid=(select uuid from sel where sel.elem_id= comsof.connection_element.id ) ;


insert into comsof.knoten (id, geom , typ , subtyp , planung_status, foerdert_status, cluster )
	select id, geom , 'Gebaeude', 'POP', 'Grobplanung',Null , (select destination_cluster from comsof.comsof_metadata)  from comsof.out_accessstructures where type='CentralOffice';

/*the id of the "connection_module" is eq_id of the "OUT_ACCESSSTRUCTURE"*/
insert into comsof.connection_module(id, typ, produkt_id, knoten_id, netzebene_quelle,netzebene_ziel, eigentum_status, foerdert_status, cluster)
	select eq_id, 'Switch / Plugin', NULL, id, 'Backbone-Ebene','Haupt-Ebene', 'Eigentum', Null, (select destination_cluster from comsof.comsof_metadata) from comsof.out_accessstructures where type = 'CentralOffice';
with sel as( select connmodule.id, knot.uuid  knot_uuid from  comsof.connection_module connmodule join comsof.knoten knot on knot.id=connmodule.knoten_id )
	update comsof.connection_module set knoten_uuid=(select knot_uuid from sel where sel.id=comsof.connection_module .id)  where  comsof.connection_module.knoten_uuid is null;
	
/*The id of the "connection_unit" is the eq_id of the "out_closure" */
insert into comsof.connection_unit (id, conn_module_id,	produkt_id, letzten_datum_mod, cluster)
	select  eq_id , enc_eqp_id ,Null , Null, (select destination_cluster from comsof.comsof_metadata) from comsof.out_closures where layer='Feeder';
with sel as (select conmod.id elem_id, connmodule.uuid from comsof.connection_module connmodule  join comsof.connection_unit conmod on conmod.conn_module_id = connmodule.id)
	update comsof.connection_unit set conn_module_uuid = (select sel.uuid from sel where sel.elem_id=comsof.connection_unit.id) where conn_module_uuid is null;


/* The id of the "connection_Element" is
	For hausanschluss or POP is the same as the id of the "connection_unit" (i.e. the eq_id of the "outer_closure" ) 
	For splitter is the splice_id of the  "outer_splitter"*/
insert into  comsof.connection_element( id,	conn_unit_id,	produkt_id,	typ, subtyp, installation_ziele,	installation_spalte , label,	 mehrdetail, cluster )
	select eq_id, eq_id, null, 'Active', 'Switch / Plugin', Null, Null, Null, null, (select destination_cluster from comsof.comsof_metadata) from comsof.out_closures where layer='Feeder'; /*only for POP*/
with sel as (select elem.id elem_id, unit.uuid from comsof.connection_element elem join comsof.connection_unit unit on unit.id= elem.conn_unit_id)
	update comsof.connection_element set conn_unit_uuid=(select uuid from sel where sel.elem_id= comsof.connection_element.id ) where conn_unit_uuid is null;

/*  ########################        schacht              ####################################################################################################################################################################################   */
/*Ziehschacht : */
insert into comsof.knoten (id, geom , typ , subtyp , planung_status, foerdert_status, cluster)
	select id, geom , 'Schacht', 'Ziehschacht / Schacht an grossen Knotenpunkten', 'Grobplanung',Null , (select destination_cluster from comsof.comsof_metadata)  from comsof.out_accessstructures where type='HandHole';
/*Verteilerschacht :*/
insert into comsof.knoten (id, geom , typ , subtyp , planung_status, foerdert_status, cluster)
	select id, geom , 'Schacht', 'GF_NVT', 'Grobplanung','Eigenausbau' , (select destination_cluster from comsof.comsof_metadata) from comsof.out_accessstructures where type='HandHole' and eq_id in (select enc_eqp_id from comsof.out_closures) ;
	
/*the id of the "connection_module" is eq_id of the "OUT_ACCESSSTRUCTURE"*/     /*Verteilerschacht :*/
insert into comsof.connection_module(id, typ, produkt_id, knoten_id, netzebene_quelle,netzebene_ziel, eigentum_status, foerdert_status, cluster) 
	select eq_id, 'Muffe', NULL, id, 'Hauptebene','Verteilerebene', 'Eigentum', Null,(select destination_cluster from comsof.comsof_metadata) from comsof.out_accessstructures where type = 'HandHole' and eq_id in (select enc_eqp_id from comsof.out_closures);
with sel as( select connmodule.id, knot.uuid  knot_uuid from  comsof.connection_module connmodule join comsof.knoten knot on knot.id=connmodule.knoten_id )
	update comsof.connection_module set knoten_uuid=(select knot_uuid from sel where sel.id=comsof.connection_module .id)  where  comsof.connection_module.knoten_uuid is null;

/*The id of the "connection_unit" is the eq_id of the "out_closure" */     /*Verteilerschacht :*/
insert into comsof.connection_unit (id, conn_module_id,	produkt_id, letzten_datum_mod, cluster)
	select  eq_id , enc_eqp_id ,Null , Null, (select destination_cluster from comsof.comsof_metadata) from comsof.out_closures where layer='Distribution' and enc_eqp_id in (select id from comsof.connection_module where typ='Muffe');
with sel as (select conmod.id elem_id, connmodule.uuid from comsof.connection_module connmodule  join comsof.connection_unit conmod on conmod.conn_module_id = connmodule.id)
	update comsof.connection_unit set conn_module_uuid = (select sel.uuid from sel where sel.elem_id=comsof.connection_unit.id) where conn_module_uuid is null;

/* The id of the "connection_Element" is
	For hausanschluss or POP is the same as the id of the "connection_unit" (i.e. the eq_id of the "outer_closure" ) 
	For splitter is the splice_id of the  "out_splitter"*/      /*Verteilerschacht :*/
insert into  comsof.connection_element( id,	conn_unit_id,	produkt_id,	typ, subtyp, installation_ziele,	installation_spalte , label,	 mehrdetail, cluster)
	select splice_id, eq_id, null, 'Passive', 'Splitter', Null, Null, Null, null, (select destination_cluster from comsof.comsof_metadata) from comsof.out_splitters where enc_eqp_id in (select id from comsof.connection_unit); 
with sel as (select elem.id elem_id, unit.uuid from comsof.connection_element elem join comsof.connection_unit unit on unit.id= elem.conn_unit_id)
	update comsof.connection_element set conn_unit_uuid=(select uuid from sel where sel.elem_id= comsof.connection_element.id ) where conn_unit_uuid is null;

/*  ########################        Trassen/Rohren-abzweigungen              ################################################################################################################################################################### */
/* knotäuse :  make Pop to Mini-POP if exists, and insert NVTs*/
update comsof.knoten set subtyp='Mini-POP/MFG' where id  in (select id from comsof.out_accessstructures where type='Cabinet' and virtual='F' ) and typ='POP' ;

insert into comsof.knoten (id, geom , typ , subtyp , planung_status, foerdert_status, cluster)
	select id, geom , 'Kabinet', 'GF_NVT', 'Grobplanung','Eigenausbau' , (select destination_cluster from comsof.comsof_metadata)  from comsof.out_accessstructures where type='Cabinet' and virtual='F' and id not in (select id from comsof.knoten) ;

/*the id of the "connection_module" is eq_id of the "OUT_ACCESSSTRUCTURE"*/
insert into comsof.connection_module(id, typ, produkt_id, knoten_id, netzebene_quelle,netzebene_ziel, eigentum_status, foerdert_status, cluster) 
	select eq_id, 'Board', NULL, id, 'Haupt-Ebene','Verteiler-Ebene', 'Eigentum', 'Eigenausbau', (select destination_cluster from comsof.comsof_metadata) from comsof.out_accessstructures where  type='Cabinet' and virtual='F';
with sel as( select connmodule.id, knot.uuid  knot_uuid from  comsof.connection_module connmodule join comsof.knoten knot on knot.id=connmodule.knoten_id )
	update comsof.connection_module set knoten_uuid=(select knot_uuid from sel where sel.id=comsof.connection_module .id)  where  comsof.connection_module.knoten_uuid is null;

/*The id of the "connection_unit" is the eq_id of the "out_closure" */
insert into comsof.connection_unit (id, conn_module_id,	produkt_id, letzten_datum_mod, cluster)
	select  eq_id , enc_eqp_id ,Null , Null, (select destination_cluster from comsof.comsof_metadata) from comsof.out_closures where layer='Distribution';	
with sel as (select conmod.id elem_id, connmodule.uuid from comsof.connection_module connmodule  join comsof.connection_unit conmod on conmod.conn_module_id = connmodule.id)
	update comsof.connection_unit set conn_module_uuid = (select sel.uuid from sel where sel.elem_id=comsof.connection_unit.id) where conn_module_uuid is null;

/* The id of the "connection_Element" is
	For hausanschluss or POP is the same as the id of the "connection_unit" (i.e. the eq_id of the "outer_closure" ) 
	For splitter is the splice_id of the  "outer_splitter"*/
insert into  comsof.connection_element(id,	conn_unit_id,	produkt_id,	typ, subtyp, installation_ziele,	installation_spalte , label,	 mehrdetail, cluster)
	select splice_id, enc_eqp_id , null, 'Passive', 'Splitter', Null, Null, Null, null,(select destination_cluster from comsof.comsof_metadata) from comsof.out_splitters; /*only for splitter*/
with sel as (select elem.id elem_id, unit.uuid from comsof.connection_element elem join comsof.connection_unit unit on unit.id= elem.conn_unit_id)
	update comsof.connection_element set conn_unit_uuid=(select uuid from sel where sel.elem_id= comsof.connection_element.id ) where conn_unit_uuid is null;	

/*##########################################################################################################################################################################################################################################################################################################*/
/*############     kable / Faser             ########################################################################################################################################################################################################################################################*/

alter table comsof.kabel alter column anzahl_fasern drop not null;
with sel as (
	select fas.id, fas.geom,fas.cable_id,fas.p_cl_eq_id, fas.c_cl_eq_id, comsof.out_closures.eq_id par_closure_eq, comsof.out_closures.enc_eqp_id connmodule_anfang from comsof.out_feedercableentries fas join comsof.out_closures  on  comsof.out_closures.eq_id=fas.p_cl_eq_id )
	,sel2 as (select sel.id, sel.geom, st_length(sel.geom) leng,max(st_length(sel.geom) ) over (partition by sel.cable_id) max_leng, sel.cable_id, sel.connmodule_anfang, comsof.out_closures.enc_eqp_id connmodule_ende  from sel join comsof.out_closures on comsof.out_closures.eq_id=sel.c_cl_eq_id)
	,sel3 as (select distinct cable_id, st_linemerge(geom), Null produkt, 'Kabel' typ, 'Haupt-Ebene', connmodule_anfang, connmodule_ende, 'Grobplanung', 'Eigenausbau', 'Eigentum' , 'HP : Home-Pass', leng, (select destination_cluster from comsof.comsof_metadata) from sel2 where leng = max_leng)
	insert into comsof.kabel (id, geom, produkt_id, typ, netzebene, conn_module_anfang, conn_module_ende, planung_status, foerdert_status,eigentum_status,   homeconnect_status, length, cluster) select * from sel3;	
with sel as (select k.id, ck.cablegran cnt from comsof.out_feedercables ck join  comsof.kabel k  on ck.cable_id= k.id)
	update comsof.kabel set anzahl_fasern=(select cnt from sel where sel.id=comsof.kabel.id ) where comsof.kabel.netzebene='Haupt-Ebene';
	
with sel as (
	select fas.id, fas.geom,fas.cable_id,fas.p_cl_eq_id, fas.c_cl_eq_id, comsof.out_closures.eq_id par_closure_eq, comsof.out_closures.enc_eqp_id connmodule_anfang from comsof.out_distributioncableentries fas join comsof.out_closures  on  comsof.out_closures.eq_id=fas.p_cl_eq_id )
	,sel2 as (select sel.id, sel.geom, st_length(sel.geom) leng,max(st_length(sel.geom) ) over (partition by sel.cable_id) max_leng, sel.cable_id, sel.connmodule_anfang, comsof.out_closures.enc_eqp_id connmodule_ende  from sel join comsof.out_closures on comsof.out_closures.eq_id=sel.c_cl_eq_id)
	,sel3 as (select distinct cable_id, st_linemerge(geom), Null produkt, 'Kabel' typ, 'Verteiler/Drop', connmodule_anfang, connmodule_ende, 'Grobplanung', 'Eigenausbau', 'Eigentum' , 'HP : Home-Pass', leng, (select destination_cluster from comsof.comsof_metadata) from sel2 where leng = max_leng)
	insert into comsof.kabel (id, geom, produkt_id, typ, netzebene, conn_module_anfang, conn_module_ende, planung_status, foerdert_status,eigentum_status,   homeconnect_status, length, cluster) select * from sel3; 
with sel as (select k.id, ck.cablegran cnt from comsof.out_distributioncables ck join  comsof.kabel k  on ck.cable_id= k.id)
	update comsof.kabel set anzahl_fasern=(select sel.cnt from sel where sel.id=comsof.kabel.id ) where  comsof.kabel.netzebene='Verteiler/Drop';
/*update kabel, the uuid of connection modules*/
with sel as (select  k.id kid,  module.uuid   from comsof.kabel k join comsof.connection_module module on module.id=k.conn_module_anfang)
	update comsof.kabel set conn_module_anfang_uuid= (select sel.uuid from sel where  sel.kid= comsof.kabel.id );
with sel as (select  k.id kid,  module.uuid   from comsof.kabel k join comsof.connection_module module on module.id=k.conn_module_ende)
	update comsof.kabel set conn_module_ende_uuid= (select sel.uuid from sel where  sel.kid= comsof.kabel.id );		

alter table comsof.kabel alter column anzahl_fasern set not null;



/* Fasern: */

Drop table if exists comsof.temp_faser;
Create table comsof.temp_faser (like comsof.out_feedercableentries);
Alter table comsof.temp_faser drop column entry_id;
Alter table comsof.temp_faser add constraint pk_tempfaser primary key(id);
CREATE INDEX inx_temp_faser_geom ON comsof.temp_faser USING GIST(geom);
CREATE INDEX inx_temp_faser_child_id ON comsof.temp_faser(child_id);
CREATE INDEX inx_temp_faser_parent_id ON comsof.temp_faser(parent_id);
Insert into comsof.temp_faser select  entry_id, geom , cable_id, fib_index, child_id, parent_id, c_cl_eq_id,p_cl_eq_id,bot_agg_id, top_agg_id from comsof.out_feedercableentries;
Insert into comsof.temp_faser select  entry_id, geom , cable_id, fib_index, child_id, parent_id, c_cl_eq_id,p_cl_eq_id,bot_agg_id, top_agg_id from comsof.out_distributioncableentries;

insert into comsof.faser (id, geom, kabel_id, netzebene,buendeln_nr , faser_label ,conn_element_anfang, anf_elem_output_nr, anfang_typ,anfang_label, conn_element_ende, end_elem_input_nr ,ende_typ, ende_label,length, cluster)
	select id, st_linemerge(geom), cable_id, 'Haupt-Ebene',1 beundeln, Null fs_label, p_cl_eq_id, Null elem_out_nr, Null anfang_typ, Null label_anf, c_cl_eq_id, null elem_in_nr,
	Null ende_typ, Null label_ende, Null length, (select destination_cluster from comsof.comsof_metadata) clust from comsof.temp_faser;
/*update faser netzebene*/
with sel as (select f.id fid , k.netzebene from comsof.faser f join comsof.kabel k on k.id= f.kabel_id)
	update comsof.faser set netzebene = (select sel.netzebene from sel where sel.fid=comsof.faser.id);

with sel as (select f.id fid , k.uuid from comsof.faser f join comsof.kabel k on f.kabel_id=k.id)
	update comsof.faser set kabel_uuid = (select sel.uuid from sel where sel.fid=comsof.faser.id);

with sel as (select f.id fid , e.uuid from comsof.faser f join comsof.connection_element e on f.conn_element_anfang=e.id)
	update comsof.faser set conn_element_anfang_uuid = (select sel.uuid from sel where sel.fid=comsof.faser.id);
with sel as (select f.id fid , e.uuid from comsof.faser f join comsof.connection_element e on f.conn_element_ende=e.id)
	update comsof.faser set conn_element_ende_uuid = (select sel.uuid from sel where sel.fid=comsof.faser.id);
	
/*############     knotäuse: Rohrabzweigung             ########################################################################################################################################################################################################################################################*/
/* Select the points in "out_acessstructures" with the  type of accessstreucture that the id is not alresedy imported to "knoten"*/
insert into comsof.knoten (id, geom , typ , subtyp , planung_status, foerdert_status, cluster)
	select distinct id, geom, 'Lage', 'Lage, zugaenglich mit einem Kugelmarker', 'Grobplanung',Null , (select destination_cluster from comsof.comsof_metadata)  from comsof.out_accessstructures where type='AccessStructure' and id not in (select id from comsof.knoten);

/*############     Rohre           ########################################################################################################################################################################################################################################################*/
insert into comsof.rohr (id,		geom,	typ,	produkt_id,	planung_status,	foerdert_status,	netzebene,	homeconnect_status,	anzahl_microducts ,cluster)
	select duct_id , st_linemerge(geom), 'Rohrverband' typ,Null produkt, 'Grobplanung' planung_status , Null foerdert,  'Haupt-Ebene' ebene, 'HP : Home-Pass' hc, capacity, (select destination_cluster from comsof.comsof_metadata) clust from comsof.out_feederduct where capacity>1 and st_length(geom)!=0
	union all
	select duct_id , st_linemerge(geom), 'Einzelrohr' typ,Null produkt,  'Grobplanung' planung_status , Null foerdert,  'Haupt-Ebene' ebene, 'HP : Home-Pass' hc, capacity,(select destination_cluster from comsof.comsof_metadata) clust from comsof.out_feederduct where capacity=1 and st_length(geom)!=0
	union all
	select duct_id , st_linemerge(geom), 'Rohrverband' typ,Null produkt,  'Grobplanung' planung_status , Null foerdert,  'Verteiler-Ebene' ebene, 'HP : Home-Pass' hc, capacity,(select destination_cluster from comsof.comsof_metadata) clust from comsof.out_distributionduct where capacity>1 and st_length(geom)!=0
	union all
	select duct_id , st_linemerge(geom), 'Einzelrohr' typ,Null produkt, 'Grobplanung' planung_status , Null foerdert,  'Verteiler-Ebene' ebene, 'HP : Home-Pass' hc, capacity,(select destination_cluster from comsof.comsof_metadata) clust from comsof.out_distributionduct where capacity=1 and st_length(geom)!=0
	union all
	select duct_id , st_linemerge(geom), 'Rohrverband' typ,Null produkt, 'Grobplanung' planung_status , Null foerdert,  'Verteiler-Ebene' ebene, 'HC : Home-Connect' hc, capacity,(select destination_cluster from comsof.comsof_metadata) clust from comsof.out_dropduct where capacity>1 and st_length(geom)!=0
	union all
	select duct_id , st_linemerge(geom), 'Einzelrohr' typ,Null produkt,  'Grobplanung' planung_status , Null foerdert,  'Verteiler/Drop' ebene,Null  hc, capacity,(select destination_cluster from comsof.comsof_metadata) clust from comsof.out_dropduct where capacity=1 and st_length(geom)!=0	
	
/*############     Microducts           ##############################################################################################################################################################################################################################################*/
drop table if exists comsof.temp_microduct;
create table comsof.temp_microduct (
	id serial,
	geom geometry('LINESTRING',25833),
	rohr_id integer,
	micro_nr integer,
	point_anf geometry('POINT',25833),
	anfang_location numeric,
	point_end geometry('POINT',25833),
	ende_location numeric,
	knot_anf integer,
	knot_ende integer,
	stammt_von integer,
	kabel_id integer,
	kabel_geom geometry('LINESTRING',25833),
	bottom_agg_id text,
	zweig integer,
	cluster integer,
	constraint pk_temp_microduct primary key (id)
);
create index inxfk_comsof_temp_microduct_rohr on comsof.temp_microduct(rohr_id);
create index inxfk_comsof_temp_microduct_knot_anf on comsof.temp_microduct(knot_anf);
create index inxfk_comsof_temp_microduct_knot_ende on comsof.temp_microduct(knot_ende);
create index inxfk_comsof_temp_microduct_kabel on comsof.temp_microduct(kabel_id);
CREATE INDEX inx_comsof_temp_microduct_geom ON comsof.temp_microduct USING GIST(geom);
CREATE INDEX inx_comsof_temp_microduct_kabel_geom ON comsof.temp_microduct USING GIST(kabel_geom);
CREATE INDEX inx_comsof_temp_microduct_point_anf ON comsof.temp_microduct USING GIST(point_anf);
CREATE INDEX inx_comsof_temp_microduct_point_end ON comsof.temp_microduct USING GIST(point_end);
	


Do  $$
declare
	itr integer;
	cap integer;
	duct integer;
begin
	/*haupt ducts*/
	For duct in select duct_id from comsof.out_feederduct LOOP
		itr := 1;
		execute( 'select capacity from comsof.out_feederduct where duct_id=$1 and st_length(geom)!=0') into cap using duct;
		while itr<=cap loop
			execute('insert into comsof.temp_microduct(rohr_id, micro_nr ) values ($1 , $2)') using duct, itr; 
			itr := itr+1;
		end loop;
	end loop;
	/*distribution ducts*/
	For duct in select duct_id from comsof.out_distributionduct LOOP
		itr := 1;
		execute( 'select capacity from comsof.out_distributionduct where duct_id=$1 and st_length(geom)!=0') into cap using duct;
		while itr<=cap loop
			execute('insert into comsof.temp_microduct(rohr_id, micro_nr ) values ($1 , $2)') using duct, itr; 
			itr := itr+1;
		end loop;
	end loop;
	/*drop ducts*/
	For duct in select duct_id from comsof.out_dropduct LOOP
		itr := 1;
		execute( 'select capacity from comsof.out_dropduct where duct_id=$1 and st_length(geom)!=0') into cap using duct;
		while itr<=cap loop
			execute('insert into comsof.temp_microduct(rohr_id, micro_nr ) values ($1 , $2)') using duct, itr; 
			itr := itr+1;
		end loop;
	end loop;
END$$;


with sel as (select mic.id id, ab.geom, mic.micro_id,mic.cable_id , ab.duct_id from comsof.out_feedercablesdetail mic join comsof.out_feederductpieces ab on ab.piece_id=mic.piece_id where st_length(ab.geom)!=0)
	,sel2 as (select st_linemerge(st_union(geom)) geom,cable_id, duct_id, micro_id  from sel group by duct_id, cable_id, micro_id order by cable_id, duct_id, micro_id)
	,sel3 as (select geom, st_startpoint(geom) anfang, st_endpoint(geom) ende,cable_id, duct_id, micro_id from sel2)
	update comsof.temp_microduct set geom=sel3.geom, kabel_id=sel3.cable_id, point_anf= sel3.anfang, point_end=sel3.ende from sel3 where rohr_id=sel3.duct_id and micro_nr=(sel3.micro_id+1); /*used microducts*/

with sel as (select mic.id id, ab.geom, mic.micro_id,mic.cable_id , ab.duct_id from comsof.out_distributioncablesdetail mic join comsof.out_distributionductpieces ab on ab.piece_id=mic.piece_id where st_length(ab.geom)!=0)
	,sel2 as (select st_linemerge(st_union(geom)) geom,cable_id, duct_id, micro_id  from sel group by duct_id, cable_id, micro_id order by cable_id, duct_id, micro_id)
	,sel3 as (select geom, st_startpoint(geom) anfang, st_endpoint(geom) ende,cable_id, duct_id, micro_id from sel2)
	update comsof.temp_microduct set geom=sel3.geom, kabel_id=sel3.cable_id, point_anf= sel3.anfang, point_end=sel3.ende from sel3 where rohr_id=sel3.duct_id and micro_nr=(sel3.micro_id+1); /*used microducts*/	

with sel as (select mic.id id, ab.geom, mic.micro_id,mic.cable_id , ab.duct_id from comsof.out_dropcablesdetail mic join comsof.out_dropductpieces ab on ab.piece_id=mic.piece_id where st_length(ab.geom)!=0)
	,sel2 as (select st_linemerge(st_union(geom)) geom,cable_id, duct_id, micro_id  from sel group by duct_id, cable_id, micro_id order by cable_id, duct_id, micro_id)
	,sel3 as (select geom, st_startpoint(geom) anfang, st_endpoint(geom) ende,cable_id, duct_id, micro_id from sel2)
	update comsof.temp_microduct set geom=sel3.geom, kabel_id=sel3.cable_id, point_anf= sel3.anfang, point_end=sel3.ende from sel3 where rohr_id=sel3.duct_id and micro_nr=(sel3.micro_id+1); /*used microducts*/	

update comsof.temp_microduct set kabel_geom=(select geom from comsof.kabel where comsof.kabel.id=comsof.temp_microduct.kabel_id);	
update comsof.temp_microduct set anfang_location=ST_LineLocatePoint(kabel_geom, point_anf) , ende_location=ST_LineLocatePoint(kabel_geom, point_end);
update comsof.temp_microduct set 
	knot_anf=(select case 
		when anfang_location>=ende_location Then
			(select id from comsof.knoten where st_intersects(comsof.knoten.geom, comsof.temp_microduct.point_anf))
		else
			(select id from comsof.knoten where st_intersects(comsof.knoten.geom, comsof.temp_microduct.point_end))
		end)
	,knot_ende=(select case 
		when anfang_location>=ende_location Then
			(select id from comsof.knoten where st_intersects(comsof.knoten.geom, comsof.temp_microduct.point_end))
		else
			(select id from comsof.knoten where st_intersects(comsof.knoten.geom, comsof.temp_microduct.point_anf))
		end);
/*For the reserved microducts, not to have Null values for knot_anf and geom*/
update comsof.temp_microduct set knot_anf= (select knot_anf from comsof.temp_microduct sel  where sel.rohr_id=comsof.temp_microduct.rohr_id  and sel.knot_anf is not null limit 1) where comsof.temp_microduct.knot_anf is null;
update comsof.temp_microduct set geom= (select geom from comsof.rohr where comsof.rohr.id=comsof.temp_microduct.rohr_id) where comsof.temp_microduct.geom is null ;	

update comsof.temp_microduct set cluster=(select destination_cluster from comsof.comsof_metadata);

with sel as(
	select * , case when micro_nr=max then lag(id,1) over (order by rohr_id ,micro_nr asc) else stammt_von end von from (
		select *,  max(micro_nr) over (partition by rohr_id)  from (
			select id, rohr_id, micro_nr , stammt_von ,  knot_anf g_anf , knot_ende g_end from comsof.temp_microduct where id in (
				select ids from(
					select unnest(ids) ids ,kabel_id, rohr_id ,cnt from (
						select array_agg(id) ids, kabel_id, rohr_id ,count(*)  cnt from comsof.temp_microduct group by kabel_id, rohr_id  order by cnt desc 
						) sel1 where sel1.kabel_id is not null and cnt>1
				) sel2
			) order by rohr_id, micro_nr
		)sel3 
	)sel4
	) update comsof.temp_microduct set knot_anf=(select g_end from sel where sel.id=comsof.temp_microduct.id) , knot_ende=(select g_anf from sel where sel.id=comsof.temp_microduct.id)/*, stammt_von=(select von from sel where sel.id=comsof.temp_microduct.id)*/ where id in (select id from sel);	

--update comsof.temp_microduct set  stammt_von= (select id from comsof.temp_microduct sel where comsof.temp_microduct.kabel_id=sel.kabel_id and comsof.temp_microduct.knot_anf=sel.knot_ende order by micro_nr asc limit 1);	


--fix anfang and ende for the microducts that are in the same rohrverband
with sel as(
	select * , case when micro_nr=max then lag(id,1) over (order by rohr_id ,micro_nr asc) else stammt_von end von from (
		select *,  max(micro_nr) over (partition by rohr_id)  from (
			select id, rohr_id, micro_nr , stammt_von ,  knot_anf g_anf , knot_ende g_end from comsof.temp_microduct where id in (
				select ids from(
					select unnest(ids) ids ,kabel_id, rohr_id ,cnt from (
						select array_agg(id) ids, kabel_id, rohr_id ,count(*)  cnt from comsof.temp_microduct group by kabel_id, rohr_id  order by cnt desc 
						) sel1 where sel1.kabel_id is not null and cnt>1
				) sel2
			) order by rohr_id, micro_nr
		)sel3 
	)sel4
	) 
	update comsof.temp_microduct set 
		knot_anf=(select case when sel.micro_nr=sel.max  then g_end else g_anf end from sel where sel.id=comsof.temp_microduct.id ) 
		, knot_ende=(select case when sel.micro_nr=sel.max  then g_anf else g_end end from sel where sel.id=comsof.temp_microduct.id )
		--, stammt_von=(select von from sel where sel.id=comsof.temp_microduct.id ) 
	where id in (select id from sel);	

-- update stammt_von
update comsof.temp_microduct  m set  
	stammt_von= (select id from comsof.temp_microduct sel where m.kabel_id=sel.kabel_id and m.knot_anf=sel.knot_ende 
								and not (sel.rohr_id=m.rohr_id and sel.micro_nr>m.micro_nr) order by micro_nr asc limit 1) where stammt_von is  null;

/*  ###   Feed Microducts  ##################*/
insert into comsof.microduct (id,geom, rohr_id, microduct_nr, knoten_anfang, knoten_ende, stammt_von, kabel_id, bottom_agg_id, zweig, cluster, netzebene)
	select id, geom, rohr_id, micro_nr, knot_anf, knot_ende, stammt_von, kabel_id, bottom_agg_id, zweig, cluster, 'Haupt-Ebene' from comsof.temp_microduct;

/*update netzebene*/
with sel as (select m.id, r.netzebene from comsof.microduct m join comsof.rohr r on r.id=m.rohr_id)
	update comsof.microduct set netzebene=(select netzebene from sel where sel.id=comsof.microduct.id);

/* update uuids */
with sel as (select m.id, r.uuid from comsof.microduct m join comsof.rohr r on r.id=m.rohr_id)
	update comsof.microduct set rohr_uuid=(select uuid from sel where sel.id=comsof.microduct.id);
with sel as (select m.id, g.uuid from comsof.microduct m join comsof.knoten g on g.id=m.knoten_anfang)
	update comsof.microduct set knoten_anfang_uuid=(select uuid from sel where sel.id=comsof.microduct.id);
with sel as (select m.id, g.uuid from comsof.microduct m join comsof.knoten g on g.id=m.knoten_ende)
	update comsof.microduct set knoten_ende_uuid=(select uuid from sel where sel.id=comsof.microduct.id);
with sel as (select m.id, k.uuid from comsof.microduct m join comsof.kabel k on k.id=m.kabel_id)
	update comsof.microduct set kabel_uuid=(select uuid from sel where sel.id=comsof.microduct.id);
with sel as (select m.id, r.uuid from comsof.microduct m join comsof.microduct r on r.id=m.stammt_von)
	update comsof.microduct set stammt_von_uuid=(select uuid from sel where sel.id=comsof.microduct.id);

-- Update conn_unit_anfang/ende
with kabel as(
	select sel.id id, sel.conn_module_anfang_uuid , (select knoten_uuid from comsof.connection_module where id=sel.conn_module_anfang) knoten_anfang
		,sel.conn_module_ende_uuid, (select knoten_uuid from comsof.connection_module where id=sel.conn_module_ende) knoten_ende
	from (select * from comsof.kabel) sel)
	, sel2 as (select mic.id microduct_id, knoten_anfang_uuid micro_knoten_anf , knoten_ende_uuid micro_knoten_ende, kabel.knoten_anfang kabel_knoten_anfang,  kabel.conn_module_anfang_uuid kabel_module_anfang, kabel.knoten_ende kabel_knoten_ende,  kabel.conn_module_ende_uuid kabel_module_ende from comsof.microduct mic join kabel on mic.kabel_id= kabel.id)
	--select * from sel2
	,sel3 as(select microduct_id
			,case when micro_knoten_anf=kabel_knoten_anfang then kabel_module_anfang when micro_knoten_anf=kabel_knoten_ende then kabel_module_ende else Null end mod_anf
			,case when micro_knoten_ende=kabel_knoten_anfang then kabel_module_anfang when micro_knoten_ende=kabel_knoten_ende then kabel_module_ende else Null end mod_ende
	from sel2)
	update comsof.microduct set conn_module_anfang_uuid = (select mod_anf from sel3 where microduct_id=id), conn_module_ende_uuid = (select mod_ende from sel3 where microduct_id=id);

with recursive tr AS(
		select id, rohr_id, microduct_nr, stammt_von_uuid , knoten_ende knot_ende_as_botton_aggid, (select subtyp from comsof.knoten  where id=knoten_ende) ende from comsof.microduct where knoten_ende in (select id from comsof.knoten where subtyp in ('POP', 'Mini-POP/MFG', 'GF_NVT', 'KVZ', 'Abschlusspunkt','Ziehschacht / Schacht an grossen Knotenpunkten' ) ) 
	union
		select m.id, m.rohr_id, m.microduct_nr,m.stammt_von_uuid , tr.knot_ende_as_botton_aggid ,tr.ende from comsof.microduct m inner join tr on m.uuid=tr.stammt_von_uuid and m.knoten_ende NOT in (select id from comsof.knoten where subtyp in ('POP', 'Mini-POP/MFG', 'GF_NVT', 'KVZ', 'Abschlusspunkt','Ziehschacht / Schacht an grossen Knotenpunkten' ) ) 
	)--select id, count(id )cnt from tr group by id order by cnt desc	 --the frequency of all should be 1
	update comsof.microduct set bottom_agg_id=(select knot_ende_as_botton_aggid::text from tr where tr.id=comsof.microduct.id);-- the smae number of the microduct that have kabel inside
	

/*############     Trasse           #################################################################################################################*/
with sel1 as ( select * from comsof.out_usedsegments where id in (select id from comsof.out_feederroutes) )
	, sel2 as (select id , st_linemerge(geom), case when crossing='T' then 'Querung' Else 'Laengstrasse' end ,
		case when crossing='T' then 'Pressbohrung/Bodenverdraengung' Else 'Klassischer Tiefbau (Ausschachtung)' end, Null,
		0.6, 'Unbefestigt', 'Unbekannt', Null, 'Grobplanung', 'Haupt-Ebene' , 'HP : Home-Pass', (select destination_cluster from comsof.comsof_metadata)
		from sel1 where st_length(geom)!=0)
		Insert into comsof.trasse (id , geom, typ ,trassenbauverfahren, sonst_bauverfahren, verlege_tief_m, oberflaeche, widmung, foerdert_status, planung_status,netzebene, homeconnect_status ,cluster) select * from sel2;

with sel1 as ( select * from comsof.out_usedsegments where id in (select id from comsof.out_distributionroutes) and id not in (select id from comsof.trasse) )
	, sel2 as (select id , st_linemerge(geom), case when crossing='T' then 'Querung' Else 'Laengstrasse'end ,
		case when crossing='T' then 'Pressbohrung/Bodenverdraengung' Else 'Klassischer Tiefbau (Ausschachtung)' end, Null,
		0.6, 'Unbefestigt', 'Unbekannt', Null, 'Grobplanung', 'Verteiler-Ebene' , Null, (select destination_cluster from comsof.comsof_metadata)
		from sel1 where st_length(geom)!=0)
		Insert into comsof.trasse (id , geom, typ ,trassenbauverfahren, sonst_bauverfahren, verlege_tief_m, oberflaeche, widmung, foerdert_status, planung_status,netzebene, homeconnect_status ,cluster) select * from sel2;

with sel1 as ( select * from comsof.out_usedsegments where id in (select id from comsof.out_droproutes) and id not in (select id from comsof.trasse) )
	, sel2 as (select id , st_linemerge(geom),'Hausanschlusstrasse',
		'Klassischer Tiefbau (Ausschachtung)', Null,
		0.6, 'Unbefestigt', 'Unbekannt', Null, 'Grobplanung', 'Verteiler/Drop' , Null, (select destination_cluster from comsof.comsof_metadata)
		from sel1 where st_length(geom)!=0)
		Insert into comsof.trasse (id , geom, typ ,trassenbauverfahren, sonst_bauverfahren, verlege_tief_m, oberflaeche, widmung, foerdert_status, planung_status,netzebene, homeconnect_status ,cluster) select * from sel2;	

/*############     schutzrohr           #################################################################################################################*/
 /*update gahäuse for start and end of schutzrohr*/
 /*We do not need to link schutzrohr directly with knoten. only the point-generation trigger should be run.*/
with sel1 as (select source_id id from comsof.out_usedsegments where crossing='T' and st_length(geom)!=0
		union
		select target_id id from comsof.out_usedsegments where crossing='T' and st_length(geom)!=0)
	, sel2 as (select id , geom, 'Lage', 'Lage ohne Kugelmarker', 'Grobplanung', Null, Null, (select destination_cluster from comsof.comsof_metadata)  from comsof.out_nodes where id in (select id from sel1 where id not in (select id from comsof.knoten)) )
	insert into comsof.knoten( id, geom, typ ,subtyp, planung_status,foerdert_status,produkt_id , cluster) select * from sel2;

insert into comsof.schutzrohr (id, geom , produkt_id, planung_status, foerdert_status, cluster)
	select id, geom , Null, planung_status, foerdert_status, cluster from comsof.trasse where typ='Querung';


/*update rohr-schutzrohr*/
insert into comsof.rohr_schutzrohr (schutzrohr_id, rohr_id, cluster)
	select s.id, r.id , (select destination_cluster from comsof.comsof_metadata)  from comsof.schutzrohr s join comsof.rohr r on st_contains(r.geom, s.geom) order by s.id, r.id;
with sel as	(select s.schutzrohr_id sid , s.rohr_id rid, d.uuid from comsof.rohr_schutzrohr s join comsof.schutzrohr d on d.id=s.schutzrohr_id)
	update  comsof.rohr_schutzrohr set  schutzrohr_uuid = (select uuid from  sel where sel.sid=comsof.rohr_schutzrohr.schutzrohr_id and sel.rid=comsof.rohr_schutzrohr.rohr_id);
with sel as	(select s.schutzrohr_id sid , s.rohr_id rid, d.uuid from comsof.rohr_schutzrohr s join comsof.rohr d on d.id=s.rohr_id)
	update  comsof.rohr_schutzrohr set  rohr_uuid = (select uuid from  sel where sel.sid=comsof.rohr_schutzrohr.schutzrohr_id and sel.rid=comsof.rohr_schutzrohr.rohr_id);
	
/*############     strecke           #################################################################################################################*/
Insert into comsof.strecke (_uuid,typ,cluster)
	select  uuid, 'Trasse', (select destination_cluster from comsof.comsof_metadata) from comsof.trasse
	union all
	select  uuid, 'Microduct', (select destination_cluster from comsof.comsof_metadata) from comsof.microduct
	union all
	select  uuid, 'Schutzrohr', (select destination_cluster from comsof.comsof_metadata) from comsof.schutzrohr;	

	



--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---    P0/2:
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*File name: Tables.sql
Implementation of Tables in Model A.
Notcie that the Following SQL should have benn run first:

prerequisites:
	- 01_Enums_Domains.sql
	- 01_Functions_and_triggers.sql

DNS-NET GIS group
	Last Update: 15-10-2020 
	Deployed on : 17-03-2021 
*/

/*LIST of Tables:
	_cluster
*/

/* Drop if esixts #############################################################################################*/

DROP TABLE IF EXISTS prj_langerwisch.linear_object cascade;
DROP TABLE IF EXISTS prj_langerwisch.strecke_line cascade;
DROP TABLE IF EXISTS prj_langerwisch.strecke cascade;
DROP TABLE IF EXISTS prj_langerwisch.rohr_schutzrohr;
DROP TABLE IF EXISTS prj_langerwisch.schutzrohr;
DROP TABLE IF EXISTS prj_langerwisch.trasse;
DROP TABLE IF EXISTS prj_langerwisch.microduct;
DROP TABLE IF EXISTS prj_langerwisch.rohr cascade;
DROP TABLE IF EXISTS prj_langerwisch.kabel cascade;
DROP TABLE IF EXISTS prj_langerwisch.faser;
DROP TABLE IF EXISTS prj_langerwisch.connection_element;
DROP TABLE IF EXISTS prj_langerwisch.connection_unit;
DROP TABLE IF EXISTS prj_langerwisch.connection_module;
DROP TABLE IF EXISTS prj_langerwisch.abschlusspunkte_kunden;
DROP TABLE IF EXISTS prj_langerwisch.adresse_abschluss;
DROP TABLE IF EXISTS prj_langerwisch.abschlusspunkte;
DROP TABLE IF EXISTS prj_langerwisch.knoten;





----/*###	TABLE CREATION	###########################################################################################################################*/



CREATE TABLE prj_langerwisch.knoten (
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
	CONSTRAINT pk_prj_langerwisch_knoten PRIMARY KEY(id)
);
ALTER TABLE prj_langerwisch.knoten ADD CONSTRAINT fk_prj_langerwisch_knoten_typ FOREIGN KEY (typ) REFERENCES enum_knoten_typ(val) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.knoten ADD CONSTRAINT fk_prj_langerwisch_knoten_subtyp FOREIGN KEY (subtyp) REFERENCES enum_knoten_subtyp(val)on UPDATE CASCADE;
ALTER TABLE prj_langerwisch.knoten ADD CONSTRAINT fk_prj_langerwisch_knoten_status FOREIGN KEY(planung_status) REFERENCES enum_planungsstatus(val) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.knoten ADD CONSTRAINT fk_prj_langerwisch_knoten_foerdert FOREIGN KEY (foerdert_status) REFERENCES enum_foerdertstatus(val) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.knoten ADD CONSTRAINT fk_prj_langerwisch_knoten_produkt FOREIGN KEY(produkt_id) REFERENCES _produkt_katalog(_produkt) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.knoten ADD CONSTRAINT fk_prj_langerwisch_knoten_cluster FOREIGN KEY(cluster) REFERENCES _cluster(id) ON UPDATE CASCADE;
CREATE INDEX inxfk_prj_langerwisch_knoten_produktid ON prj_langerwisch.knoten(produkt_id);
CREATE INDEX inxfk_prj_langerwisch_knoten_cluster ON prj_langerwisch.knoten(cluster);
CREATE INDEX inx_prj_langerwisch_knoten_geom ON prj_langerwisch.knoten USING GIST(geom);



CREATE TABLE prj_langerwisch.abschlusspunkte(
	id uuid DEFAULT dns_netzwerk_uuid('abschlusspunkte'),
	geom geometry('POINT',25833),
	knoten_id uuid NOT NULL,
	typ text NOT NULL,
	einbauort text,
	homeconnect_status text,
	cluster integer,
	CONSTRAINT pk_prj_langerwisch_abschlusspunkte PRIMARY KEY(id)
);
ALTER TABLE prj_langerwisch.abschlusspunkte ADD CONSTRAINT fk_prj_langerwisch_abschlusspunkte_knoten FOREIGN KEY(knoten_id) REFERENCES prj_langerwisch.knoten(id) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.abschlusspunkte ADD CONSTRAINT fk_prj_langerwisch_abschlusspunkte_typ FOREIGN KEY(typ) REFERENCES enum_abschlusspunkte_typ(val) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.abschlusspunkte ADD CONSTRAINT fk_prj_langerwisch_abschlusspunkte_einabuort FOREIGN KEY(einbauort) REFERENCES enum_abschlusspunkte_einbauort(val) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.abschlusspunkte ADD CONSTRAINT fk_prj_langerwisch_abschlusspunkte_hc FOREIGN KEY(homeconnect_status) REFERENCES enum_hc_status(val) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.abschlusspunkte ADD CONSTRAINT fk_prj_langerwisch_abschlusspunkte_cluster FOREIGN KEY (cluster) REFERENCES _cluster(id) ON UPDATE CASCADE;
CREATE INDEX inx_prj_langerwisch_abschlusspunkte_knotenid ON prj_langerwisch.abschlusspunkte(knoten_id);
CREATE INDEX inx_prj_langerwisch_abschlusspunkte_cluster ON prj_langerwisch.abschlusspunkte(cluster);
CREATE INDEX inx_prj_langerwisch_abschlusspunkte_geom ON prj_langerwisch.abschlusspunkte USING GIST(geom);



CREATE TABLE prj_langerwisch.adresse_abschluss(
	adresse_id uuid,
	abschlusspunkte_id uuid,
	cluster integer,
	CONSTRAINT pk_prj_langerwisch_adresse_abschluss PRIMARY KEY(adresse_id, abschlusspunkte_id)
);
ALTER TABLE prj_langerwisch.adresse_abschluss ADD CONSTRAINT fk_prj_langerwisch_adresseabschluss_adresse FOREIGN KEY (adresse_id) REFERENCES adressen.adressen(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE prj_langerwisch.adresse_abschluss ADD CONSTRAINT fk_prj_langerwisch_adresseabschluss_abschluss FOREIGN KEY (abschlusspunkte_id)REFERENCES prj_langerwisch.abschlusspunkte(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE prj_langerwisch.adresse_abschluss ADD CONSTRAINT fk_prj_langerwisch_adresseabschluss_cluster FOREIGN KEY (cluster) REFERENCES _cluster(id) ON UPDATE CASCADE;
CREATE INDEX inxfk_prj_langerwisch_adresseabschluss_adresse ON prj_langerwisch.adresse_abschluss(adresse_id);
CREATE INDEX inx_prj_langerwisch_adresseabschluss_cluster ON prj_langerwisch.adresse_abschluss(cluster);
CREATE INDEX inxfk_prj_langerwisch_adresseabschluss_abschlu ON prj_langerwisch.adresse_abschluss(abschlusspunkte_id);




CREATE TABLE prj_langerwisch.abschlusspunkte_kunden (
	id uuid DEFAULT dns_netzwerk_uuid('attribute'),
	abschlusspunkte_id uuid NOT NULL,
	sid varchar(25) NOT NULL,
	vertriebsstatus text NOT NULL,
	active text,
	cluster integer,
	CONSTRAINT pk_prj_langerwisch_abschlusspunkte_kunden PRIMARY KEY (id)
);
ALTER TABLE prj_langerwisch.abschlusspunkte_kunden ADD CONSTRAINT fk_prj_langerwisch_abschlusspunktekunden_abschlusspunkte FOREIGN KEY (abschlusspunkte_id) REFERENCES prj_langerwisch.abschlusspunkte(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE prj_langerwisch.abschlusspunkte_kunden ADD CONSTRAINT fk_prj_langerwisch_abschlusspunktekunden_vertriebsstatus FOREIGN KEY (vertriebsstatus) REFERENCES enum_vertriebsstatus(val) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.abschlusspunkte_kunden ADD CONSTRAINT fk_prj_langerwisch_abschlusspunktekunden_active FOREIGN KEY (active) REFERENCES enum_ja_nein(val) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.abschlusspunkte_kunden ADD CONSTRAINT fk_prj_langerwisch_abschlusspunktekunden_cluster FOREIGN KEY (cluster) REFERENCES _cluster(id) ON UPDATE CASCADE;
CREATE INDEX inxfk_prj_langerwisch_abschlusspunktekunden_abschlusspunkte ON prj_langerwisch.abschlusspunkte_kunden(abschlusspunkte_id);
CREATE INDEX inx_prj_langerwisch_abschlusspunktekunden_cluster ON prj_langerwisch.abschlusspunkte_kunden(cluster);


CREATE TABLE prj_langerwisch.connection_module (
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
	CONSTRAINT pk_prj_langerwisch_connection_module PRIMARY KEY (id)
);
ALTER TABLE prj_langerwisch.connection_module ADD CONSTRAINT fk_prj_langerwisch_connectionmodule_typ FOREIGN KEY (typ) REFERENCES enum_connmodule_typ(val) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.connection_module ADD CONSTRAINT fk_prj_langerwisch_connectionmodule_produkt FOREIGN KEY(produkt_id) REFERENCES _produkt_katalog(_produkt) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.connection_module ADD CONSTRAINT fk_prj_langerwisch_connectionmodule_knoten FOREIGN KEY (knoten_id) REFERENCES prj_langerwisch.knoten(id) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.connection_module ADD CONSTRAINT fk_prj_langerwisch_connectionmodule_netzebene_quel FOREIGN KEY (netzebene_quelle) REFERENCES enum_netzebene(val) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.connection_module ADD CONSTRAINT fk_prj_langerwisch_connectionmodule_netzebene_ziel FOREIGN KEY (netzebene_ziel) REFERENCES enum_netzebene(val) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.connection_module ADD CONSTRAINT fk_prj_langerwisch_connectionmodule_eigentum FOREIGN KEY (eigentum_status) REFERENCES enum_eigentum(val) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.connection_module ADD CONSTRAINT fk_prj_langerwisch_connectionmodule_foerdert FOREIGN KEY (foerdert_status) REFERENCES enum_foerdertstatus(val) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.connection_module ADD CONSTRAINT fk_prj_langerwisch_connectionmodule_cluster FOREIGN KEY (cluster) REFERENCES _cluster(id) ON UPDATE CASCADE;
alter table prj_langerwisch.connection_module ADD Constraint unq_prj_langerwisch_connectionmodule_id_knoten unique (id,knoten_id ); -- it is referenced as a foreign key in microdukt.
CREATE INDEX inxfk_prj_langerwisch_connmodule_knotenid ON prj_langerwisch.connection_module(knoten_id);
CREATE INDEX inxfk_prj_langerwisch_connmodule_produktid ON prj_langerwisch.connection_module(produkt_id);
CREATE INDEX inx_prj_langerwisch_connmodule_cluster ON prj_langerwisch.connection_module(cluster);


CREATE TABLE prj_langerwisch.connection_unit (
	id uuid DEFAULT dns_netzwerk_uuid('connection_unit'),
	conn_module_id uuid NOT NULL,
	produkt_id text,
	letzten_datum_mod date,
	cluster integer,
	CONSTRAINT pk_prj_langerwisch_connection_unit PRIMARY KEY (id) 
);
ALTER TABLE prj_langerwisch.connection_unit ADD CONSTRAINT fk_prj_langerwisch_connectionunit_connmodule FOREIGN KEY(conn_module_id) REFERENCES prj_langerwisch.connection_module(id) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.connection_unit ADD CONSTRAINT fk_prj_langerwisch_connectionunit_produkt FOREIGN KEY(produkt_id) REFERENCES _produkt_katalog(_produkt) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.connection_unit ADD CONSTRAINT fk_prj_langerwisch_connectionunit_cluster FOREIGN KEY(cluster) REFERENCES _cluster(id)ON UPDATE CASCADE;
CREATE INDEX inxfk_prj_langerwisch_connunit_connmoduleid ON prj_langerwisch.connection_unit(conn_module_id);
CREATE INDEX inxfk_prj_langerwisch_connunit_produktid ON prj_langerwisch.connection_unit(produkt_id);
CREATE INDEX inx_prj_langerwisch_connunit_cluster ON prj_langerwisch.connection_unit(cluster);


CREATE TABLE prj_langerwisch.connection_element(
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
	CONSTRAINT pk_prj_langerwisch_connectionelement PRIMARY KEY(id)
);
ALTER TABLE prj_langerwisch.connection_element ADD CONSTRAINT fk_prj_langerwisch_connectionelem_unit FOREIGN KEY (conn_unit_id) REFERENCES prj_langerwisch.connection_unit(id) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.connection_element ADD CONSTRAINT fk_prj_langerwisch_connectionelem_produkt FOREIGN KEY(produkt_id) REFERENCES _produkt_katalog(_produkt) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.connection_element ADD CONSTRAINT fk_prj_langerwisch_connectionelem_typ FOREIGN KEY (typ) REFERENCES enum_connelement_typ(val) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.connection_element ADD CONSTRAINT fk_prj_langerwisch_connectionelem_subtyp FOREIGN KEY (subtyp) REFERENCES enum_connelement_subtyp(val) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.connection_element ADD CONSTRAINT fk_prj_langerwisch_connectionelem_cluster FOREIGN KEY (cluster) REFERENCES _cluster(id) ON UPDATE CASCADE;
CREATE INDEX inxfk_prj_langerwisch_connelement_connunitid ON prj_langerwisch.connection_element(conn_unit_id);
CREATE INDEX inxfk_prj_langerwisch_connelement_produktid ON prj_langerwisch.connection_element(produkt_id);
CREATE INDEX inx_prj_langerwisch_connelement_cluster ON prj_langerwisch.connection_element(cluster);


CREATE TABLE prj_langerwisch.kabel (
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
	CONSTRAINT pk_prj_langerwisch_kabel PRIMARY KEY (id)
);
ALTER TABLE prj_langerwisch.kabel ADD CONSTRAINT fk_prj_langerwisch_kabel_typ FOREIGN KEY (typ) REFERENCES enum_kabel_typ(val) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.kabel ADD CONSTRAINT fk_prj_langerwisch_kabel_produkt FOREIGN KEY(produkt_id) REFERENCES _produkt_katalog(_produkt) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.kabel ADD CONSTRAINT fk_prj_langerwisch_kabel_netzebene FOREIGN KEY (netzebene) REFERENCES enum_netzebene(val) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.kabel ADD CONSTRAINT fk_prj_langerwisch_kabel_conn_module_anfang FOREIGN KEY (conn_module_anfang) REFERENCES prj_langerwisch.connection_module(id) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.kabel ADD CONSTRAINT fk_prj_langerwisch_kabel_conn_module_ende FOREIGN KEY (conn_module_ende) REFERENCES prj_langerwisch.connection_module(id) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.kabel ADD CONSTRAINT fk_prj_langerwisch_kabel_status FOREIGN KEY(planung_status) REFERENCES enum_planungsstatus(val) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.kabel ADD CONSTRAINT fk_prj_langerwisch_kabel_foerdert FOREIGN KEY (foerdert_status) REFERENCES enum_foerdertstatus(val) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.kabel ADD CONSTRAINT fk_prj_langerwisch_kabel_eigentum FOREIGN KEY(eigentum_status) REFERENCES enum_eigentum(val) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.kabel ADD CONSTRAINT fk_prj_langerwisch_kabel_hc FOREIGN KEY(homeconnect_status) REFERENCES enum_hc_status(val) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.kabel ADD CONSTRAINT fk_prj_langerwisch_kabel_cluster FOREIGN KEY (cluster) REFERENCES _cluster(id) ON UPDATE CASCADE;
alter table prj_langerwisch.kabel ADD CONSTRAINT fk_prj_langerwisch_kabel_produkt_anzahlfaser FOREIGN key (produkt_id, anzahl_fasern) references pr_kabel(produkt,anzahl_faser) on update cascade; -- control the numebr of rohr with produkt
CREATE INDEX inxfk_prj_langerwisch_kabel_produktid ON prj_langerwisch.kabel(produkt_id);
CREATE INDEX inxfk_prj_langerwisch_kabel_connmodule_anfang ON prj_langerwisch.kabel(conn_module_anfang);
CREATE INDEX inxfk_prj_langerwisch_kabel_connmodule_ende ON prj_langerwisch.kabel(conn_module_ende);
CREATE INDEX inx_prj_langerwisch_kabel_cluster ON prj_langerwisch.kabel(cluster);
CREATE INDEX inx_prj_langerwisch_kabel_geom ON prj_langerwisch.kabel USING GIST(geom);


CREATE TABLE prj_langerwisch.faser (
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
	CONSTRAINT pk_prj_langerwisch_faser PRIMARY KEY (id)
);
ALTER TABLE prj_langerwisch.faser ADD CONSTRAINT fk_prj_langerwisch_faser_kabel FOREIGN KEY (kabel_id) REFERENCES prj_langerwisch.kabel(id)on UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE prj_langerwisch.faser ADD CONSTRAINT fk_prj_langerwisch_faser_netzebene FOREIGN KEY (netzebene) REFERENCES enum_netzebene(val) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.faser ADD CONSTRAINT fk_prj_langerwisch_faser_connelement_anfang FOREIGN KEY (conn_element_anfang) REFERENCES prj_langerwisch.connection_element(id) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.faser ADD CONSTRAINT fk_prj_langerwisch_faser_connelement_ende FOREIGN KEY (conn_element_ende) REFERENCES prj_langerwisch.connection_element(id) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.faser ADD CONSTRAINT fk_prj_langerwisch_faser_input_type FOREIGN KEY (anfang_typ) REFERENCES enum_faserconn(val) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.faser ADD CONSTRAINT fk_prj_langerwisch_faser_output_type FOREIGN KEY (ende_typ) REFERENCES enum_faserconn(val) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.faser ADD CONSTRAINT fk_prj_langerwisch_faser_cluster FOREIGN KEY (cluster) REFERENCES _cluster(id) ON UPDATE CASCADE;
CREATE INDEX inxfk_prj_langerwisch_faser_kabel_id ON prj_langerwisch.faser(kabel_id);
CREATE INDEX inxfk_prj_langerwisch_faser_connelement_anfang ON prj_langerwisch.faser(conn_element_anfang);
CREATE INDEX inxfk_prj_langerwisch_faser_connelement_ende ON prj_langerwisch.faser(conn_element_ende);
CREATE INDEX inx_prj_langerwisch_faser_cluster ON prj_langerwisch.faser(cluster);
CREATE INDEX inx_prj_langerwisch_faser_geom ON prj_langerwisch.faser USING GIST(geom);


CREATE TABLE prj_langerwisch.rohr (
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
	CONSTRAINT pk_prj_langerwisch_rohr PRIMARY KEY (id)
);
ALTER TABLE prj_langerwisch.rohr ADD CONSTRAINT fk_prj_langerwisch_rohr_typ FOREIGN KEY (typ) REFERENCES enum_rohr_typ(val) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.rohr ADD CONSTRAINT fk_prj_langerwisch_rohr_produkt FOREIGN KEY(produkt_id) REFERENCES _produkt_katalog(_produkt) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.rohr ADD CONSTRAINT fk_prj_langerwisch_rohr_mantel_farbe FOREIGN KEY(mantel_farbe) REFERENCES enum_farbe(val) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.rohr ADD CONSTRAINT fk_prj_langerwisch_rohr_status FOREIGN KEY (planung_status) REFERENCES enum_planungsstatus(val) ON UPDATE CASCADE; 
ALTER TABLE prj_langerwisch.rohr ADD CONSTRAINT fk_prj_langerwisch_rohr_foerdert FOREIGN KEY (foerdert_status) REFERENCES enum_foerdertstatus(val) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.rohr ADD CONSTRAINT fk_prj_langerwisch_rohr_netzebene FOREIGN KEY (netzebene) REFERENCES enum_netzebene(val) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.rohr ADD CONSTRAINT fk_prj_langerwisch_rohr_hc_status FOREIGN KEY (homeconnect_status) REFERENCES enum_hc_status(val) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.rohr ADD CONSTRAINT fk_prj_langerwisch_rohr_cluster FOREIGN KEY (cluster) REFERENCES _cluster(id) ON UPDATE CASCADE;
alter table prj_langerwisch.rohr ADD CONSTRAINT fk_prj_langerwisch_rohr_produkt_anzahlmicroduct FOREIGN key (produkt_id, anzahl_microducts) references pr_rohr(produkt,anzahl_microducts) on update cascade;-- control the numebr of rohr with produkt
CREATE INDEX inxfk_prj_langerwisch_rohr_produktid ON prj_langerwisch.rohr(produkt_id);
CREATE INDEX inx_prj_langerwisch_rohr_topaggid on prj_langerwisch.rohr(top_agg_id);
CREATE INDEX inx_prj_langerwisch_rohr_cluster ON prj_langerwisch.rohr(cluster);
CREATE INDEX inx_prj_langerwisch_rohr_geom ON prj_langerwisch.rohr USING GIST(geom);


CREATE TABLE prj_langerwisch.microduct (
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
	CONSTRAINT pk_prj_langerwisch_microduct PRIMARY KEY (id)
);
ALTER TABLE prj_langerwisch.microduct ADD CONSTRAINT fk_prj_langerwisch_microduct_rohr FOREIGN KEY (rohr_id) REFERENCES prj_langerwisch.rohr(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE prj_langerwisch.microduct ADD CONSTRAINT fk_prj_langerwisch_microduct_knoten_anfang FOREIGN KEY (knoten_anfang) REFERENCES prj_langerwisch.knoten(id) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.microduct ADD CONSTRAINT fk_prj_langerwisch_microduct_knoten_ende FOREIGN KEY (knoten_ende) REFERENCES prj_langerwisch.knoten(id) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.microduct ADD CONSTRAINT fk_prj_langerwisch_microduct_stammtvon FOREIGN KEY (stammt_von) REFERENCES prj_langerwisch.microduct(id) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.microduct ADD CONSTRAINT fk_prj_langerwisch_microduct_kabel_id FOREIGN KEY (kabel_id) REFERENCES prj_langerwisch.kabel(id) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.microduct ADD CONSTRAINT fk_prj_langerwisch_microduct_netzebene FOREIGN KEY (netzebene) REFERENCES enum_netzebene(val) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.microduct ADD CONSTRAINT fk_prj_langerwisch_microduct_cluster FOREIGN KEY (cluster) REFERENCES _cluster(id) ON UPDATE CASCADE;
--alter table prj_langerwisch.microduct ADD constraint fk_prj_langerwisch_microduct_connmodule_anf FOREIGN KEY (knoten_anfang, conn_module_anfang) references prj_langerwisch.connection_module (id,knoten_id) on update cascade;
--alter table prj_langerwisch.microduct ADD constraint fk_prj_langerwisch_microduct_connmodule_end FOREIGN KEY (knoten_ende, conn_module_ende) references prj_langerwisch.connection_module (id, knoten_id) on update cascade;
alter table prj_langerwisch.microduct ADD constraint fk_prj_langerwisch_microduct_connmodule_anf FOREIGN KEY (knoten_anfang, conn_module_anfang) references prj_langerwisch.connection_module (knoten_id, id) on update cascade;
alter table prj_langerwisch.microduct ADD constraint fk_prj_langerwisch_microduct_connmodule_end FOREIGN KEY (knoten_ende, conn_module_ende) references prj_langerwisch.connection_module (knoten_id, id) on update cascade;
CREATE INDEX inxfk_prj_langerwisch_microduct_rohr ON prj_langerwisch.microduct(rohr_id);
CREATE INDEX inxfk_prj_langerwisch_microduct_knot_anf ON prj_langerwisch.microduct(knoten_anfang);
CREATE INDEX inxfk_prj_langerwisch_microduct_knot_ende ON prj_langerwisch.microduct(knoten_ende);
CREATE INDEX inxfk_prj_langerwisch_microduct_stammtvon ON prj_langerwisch.microduct(stammt_von);
CREATE INDEX inx_prj_langerwisch_microduct_btnaggid on prj_langerwisch.microduct(bottom_agg_id);
CREATE INDEX inxfk_prj_langerwisch_microduct_kabelid ON prj_langerwisch.microduct(kabel_id);
CREATE INDEX inx_prj_langerwisch_microduct_cluster ON prj_langerwisch.microduct(cluster);
CREATE INDEX inx_prj_langerwisch_microduct_geom ON prj_langerwisch.microduct USING GIST(geom);



CREATE TABLE prj_langerwisch.trasse (
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
	CONSTRAINT pk_prj_langerwisch_trasse PRIMARY KEY (id)
);
ALTER TABLE prj_langerwisch.trasse ADD CONSTRAINT fk_prj_langerwisch_trasse_typ FOREIGN KEY (typ) REFERENCES enum_trasse_typ (val) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.trasse ADD CONSTRAINT fk_prj_langerwisch_trasse_bauverfahr FOREIGN KEY (trassenbauverfahren) REFERENCES enum_trassenbauverfahren(val) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.trasse ADD CONSTRAINT fk_prj_langerwisch_trasse_oberflaeche FOREIGN KEY (oberflaeche) REFERENCES enum_trasse_oberflaeche(val) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.trasse ADD CONSTRAINT fk_prj_langerwisch_trasse_widmung FOREIGN KEY (widmung) REFERENCES enum_widmung(val) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.trasse ADD CONSTRAINT fk_prj_langerwisch_trasse_foerdert FOREIGN KEY (foerdert_status) REFERENCES enum_foerdertstatus ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.trasse ADD CONSTRAINT fk_prj_langerwisch_trasse_status FOREIGN KEY (planung_status) REFERENCES enum_planungsstatus ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.trasse ADD CONSTRAINT fk_prj_langerwisch_trasse_netzebene FOREIGN KEY (netzebene) REFERENCES enum_netzebene(val) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.trasse ADD CONSTRAINT fk_prj_langerwisch_trasse_hc_status FOREIGN KEY (homeconnect_status) REFERENCES enum_hc_status(val) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.trasse ADD CONSTRAINT fk_prj_langerwisch_trasse_cluster FOREIGN KEY (cluster) REFERENCES _cluster(id) ON UPDATE CASCADE;
CREATE INDEX inx_prj_langerwisch_trasse_cluster ON prj_langerwisch.trasse(cluster);
CREATE INDEX inx_prj_langerwisch_trasse_geom ON prj_langerwisch.trasse USING GIST(geom);


CREATE TABLE prj_langerwisch.schutzrohr (
	id uuid DEFAULT dns_netzwerk_uuid('schutzrohr'),
	geom geometry('LINESTRING', 25833) NOT NULL,
	produkt_id text,
	foerdert_status text,-- NOT NULL,
	planung_status text NOT NULL,
	aggregation_id text,
	cluster integer,	
	constraint pk_prj_langerwisch_schutzrohr PRIMARY KEY (id)
);
ALTER TABLE prj_langerwisch.schutzrohr ADD CONSTRAINT fk_prj_langerwisch_schutzrohr_produkt FOREIGN KEY(produkt_id) REFERENCES _produkt_katalog(_produkt) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.schutzrohr ADD CONSTRAINT fk_prj_langerwisch_schutzrohr_status FOREIGN KEY (planung_status) REFERENCES enum_planungsstatus(val) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.schutzrohr ADD CONSTRAINT fk_prj_langerwisch_schutzrohr_foerdert FOREIGN KEY (foerdert_status) REFERENCES enum_foerdertstatus(val) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.schutzrohr ADD CONSTRAINT fk_prj_langerwisch_schutzrohr_custer FOREIGN KEY (cluster) REFERENCES _cluster(id) ON UPDATE CASCADE;
CREATE INDEX inxfk_prj_langerwisch_schutzrohr_produktid ON prj_langerwisch.schutzrohr(produkt_id);
CREATE INDEX inx_prj_langerwisch_schutzrohr_cluster ON prj_langerwisch.schutzrohr(cluster);
CREATE INDEX inx_prj_langerwisch_schutzrohr_geom ON prj_langerwisch.schutzrohr USING GIST(geom);



CREATE TABLE prj_langerwisch.rohr_schutzrohr (
	schutzrohr_id uuid Not NUll,
	rohr_id uuid,
	cluster integer,	
	CONSTRAINT pk_prj_langerwisch_rohr_schutzrohr PRIMARY KEY (schutzrohr_id,rohr_id)
);
ALTER TABLE prj_langerwisch.rohr_schutzrohr ADD CONSTRAINT fk_prj_langerwisch_rohr_schutzrohr_schutz_id FOREIGN KEY (schutzrohr_id) REFERENCES prj_langerwisch.schutzrohr(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE prj_langerwisch.rohr_schutzrohr ADD CONSTRAINT fk_prj_langerwisch_rohr_schutzrohr_rohr_id FOREIGN KEY (rohr_id) REFERENCES prj_langerwisch.rohr(id) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.rohr_schutzrohr ADD CONSTRAINT fk_prj_langerwisch_rohr_schutzrohr_custer FOREIGN KEY (cluster) REFERENCES _cluster(id) ON UPDATE CASCADE;
CREATE INDEX inxfk_prj_langerwisch_rohr_schutzrohr_schutz ON prj_langerwisch.rohr_schutzrohr(schutzrohr_id);
CREATE INDEX inxfk_prj_langerwisch_rohr_schutzrohr_rohr ON prj_langerwisch.rohr_schutzrohr(rohr_id);
CREATE INDEX inx_prj_langerwisch_rohr_schutzrohr_cluster ON prj_langerwisch.rohr_schutzrohr(cluster);


CREATE TABLE prj_langerwisch.strecke (
	_id uuid, -- DEFAULT dns_netzwerk_uuid('strecke'),
	typ text NOT NULL,
	cluster integer,
	CONSTRAINT pk_prj_langerwisch_strecke PRIMARY KEY (_id) 
);
ALTER TABLE prj_langerwisch.strecke ADD CONSTRAINT fk_prj_langerwisch_strecke_strecketyp FOREIGN KEY (typ) REFERENCES enum_strecke_typ(val) ON UPDATE CASCADE;
ALTER TABLE prj_langerwisch.strecke ADD CONSTRAINT fk_prj_langerwisch_strecke_cluster FOREIGN KEY (cluster) REFERENCES _cluster(id) ON UPDATE CASCADE;
CREATE INDEX inx_prj_langerwisch_strecke_cluster ON prj_langerwisch.strecke(cluster);



CREATE TABLE prj_langerwisch.linear_object (
	id uuid DEFAULT dns_netzwerk_uuid('linear_object'),
	geom geometry('Linestring',25833) NOT NULL,
	cluster integer,
	CONSTRAINT pk_prj_langerwisch_linear_object PRIMARY KEY (id)
);
ALTER TABLE prj_langerwisch.linear_object ADD CONSTRAINT fk_prj_langerwisch_linearobject_cluster FOREIGN KEY (cluster) REFERENCES _cluster(id) ON UPDATE CASCADE;
CREATE INDEX inx_prj_langerwisch_linearobject_cluster ON prj_langerwisch.linear_object(cluster);
CREATE INDEX inx_prj_langerwisch_linearobject_geom ON prj_langerwisch.linear_object USING GIST(geom);





CREATE TABLE prj_langerwisch.strecke_line (
	strecke_id uuid,
	segment_id uuid,
	cluster integer,
	CONSTRAINT pk_prj_langerwisch_strecke_line PRIMARY KEY (strecke_id, segment_id)
);
ALTER TABLE prj_langerwisch.strecke_line ADD CONSTRAINT fk_prj_langerwisch_streckeline_streckeid FOREIGN KEY (strecke_id) REFERENCES prj_langerwisch.strecke(_id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE prj_langerwisch.strecke_line ADD CONSTRAINT fk_prj_langerwisch_streckeline_segmentid FOREIGN KEY (segment_id) REFERENCES prj_langerwisch.linear_object(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE prj_langerwisch.strecke_line ADD CONSTRAINT fk_prj_langerwisch_streckeline_cluster FOREIGN KEY (cluster) REFERENCES _cluster(id) ON UPDATE CASCADE;
CREATE INDEX inxfk_prj_langerwisch_streckeline_streckeid ON prj_langerwisch.strecke_line(strecke_id);
CREATE INDEX inxfk_prj_langerwisch_streckeline_segmentid ON prj_langerwisch.strecke_line(segment_id);
CREATE INDEX inx_prj_langerwisch_streckeline_cluster ON prj_langerwisch.strecke_line(cluster);










































--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---    c4:
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- knoten label prefix:
update comsof.knoten set label_prefix=
	case
		when subtyp='Backbone-Uebergabepunkt' Then 'P'
		when subtyp='POP' THEN 'P'
		when subtyp='Mini-POP/MFG' THEN 'M'
		when subtyp='GF_NVT' THEN 'N'
		when subtyp='KVZ' THEN 'N'
		when subtyp='Abschlusspunkt' THEN 'H'
		when subtyp='Ziehschacht / Schacht an grossen Knotenpunkten' THEN 'S'
	end || (select onb_onkz from _cluster where id = (select distinct cluster from comsof.knoten))::text;

-- knoten vid for anschluss punkte:
update comsof.knoten kn set label_wert=  '01.'||sel.vid::text 
from (
		select ind.vid, addab.abschlusspunkte_uuid, ab.knoten_uuid from comsof.in_demandpoints ind join comsof.adresse_abschluss  addab on addab.adresse_id=uuid(ind._id) join comsof.abschlusspunkte ab on ab.uuid=addab.abschlusspunkte_uuid
	) sel
where sel.knoten_uuid = kn.uuid;

--fro nvt and pop annd schacht => manually
update comsof.knoten set bez= label_prefix||'/'||label_wert
	where  label_prefix is not null and typ is not null;







update comsof.knoten set bez='M33200/02' where subtyp='POP';





--								update comsof.knoten set bez prefix and wert where subtyp='GF_NVT'   => manually 
/*Update Rohr Farbe*/
update comsof.rohr set mantel_farbe='sw' where typ='Rohrverband' and anzahl_microducts=24;
update comsof.rohr set mantel_farbe='or' where typ='Rohrverband' and anzahl_microducts=12;
update comsof.rohr set mantel_farbe='gn' where typ='Rohrverband' and anzahl_microducts=4;
update comsof.rohr set mantel_farbe='rs' where typ='Einzelrohr';




 /*update produkt info*/
update comsof.kabel set produkt_id = (select produkt from pr_kabel where id=1) where anzahl_fasern=144 and netzebene = 'Haupt-Ebene';
update comsof.kabel set produkt_id = (select produkt from pr_kabel where id=2) where anzahl_fasern=48 and netzebene in ( 'Verteiler-Ebene', 'Verteiler/Drop');
update comsof.kabel set produkt_id = (select produkt from pr_kabel where id=3) where anzahl_fasern=24 and netzebene in ( 'Verteiler-Ebene', 'Verteiler/Drop');
update comsof.kabel set produkt_id = (select produkt from pr_kabel where id=4) where anzahl_fasern=12 and netzebene in ( 'Verteiler-Ebene', 'Verteiler/Drop');

update comsof.rohr set produkt_id= (select produkt from pr_rohr where id=1) where anzahl_microducts = 4 and netzebene='Haupt-Ebene';
update comsof.rohr set produkt_id= (select produkt from pr_rohr where id=2) where anzahl_microducts = 24 and netzebene in ('Verteiler-Ebene', 'Haupt-Verteiler-Ebene', 'Verteiler/Drop');
update comsof.rohr set produkt_id= (select produkt from pr_rohr where id=3) where anzahl_microducts = 12 and netzebene in ('Verteiler-Ebene', 'Haupt-Verteiler-Ebene', 'Verteiler/Drop');
update comsof.rohr set produkt_id= (select produkt from pr_rohr where id=4) where anzahl_microducts = 1 and netzebene in ('Verteiler-Ebene', 'Haupt-Verteiler-Ebene', 'Verteiler/Drop');

update comsof.knoten set produkt_id = 'FTTH Abschlußbox AP (unbestückt) Typ M' where subtyp = 'Abschlusspunkt';
update comsof.connection_module set produkt_id = 'FTTH Abschlußbox AP (unbestückt) Typ M' where netzebene_ziel = 'In-House-Ebene' ;
update comsof.connection_unit set produkt_id = 'FTTH Abschlußbox AP (unbestückt) Typ M' where conn_module_id in (select id from comsof.connection_module where produkt_id = 'FTTH Abschlußbox AP (unbestückt) Typ M') ;
update comsof.connection_element set produkt_id = 'FTTH Abschlußbox AP (unbestückt) Typ M' where conn_unit_id in (select id from comsof.connection_unit where produkt_id = 'FTTH Abschlußbox AP (unbestückt) Typ M') ;



update  comsof.rohr set bez = (select nam from 
	(select id, case when typ='Rohrverband' then 'MRV' when typ='Einzelrohr' then'ER' end||(select onb_onkz from _cluster where cluster =_cluster.id)||'/'|| right((100000+row_number() over (order by id))::text,5) nam from comsof.rohr) sel
	where sel.id= comsof.rohr.id);

update comsof.microduct set bez = (select bez from comsof.rohr r where r.id=rohr_id )||'/'||right((microduct_nr+100)::text,2);

--TO DO Microduct Bez






--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---    c5:
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*
This SQL code is to convert from the intermediate tables To model_A
prerequisit:
	- C4_Project_postprocess.sql
	- P0_Model_A__Tables_.sql
	- P0_Project_PreProcess.sql
DNS GIS-Group
16-10-2020
*/

---- Knoten
INSERT INTO prj_langerwisch.knoten (id, bez, geom, typ, subtyp, planung_status, foerdert_status, produkt_id, label_prefix, label_wert,cluster)
	select 
		uuid, bez, geom,typ,subtyp,planung_status,foerdert_status,produkt_id, label_prefix, label_wert,cluster
	from comsof.knoten;	


---- Abschlusspunkte
INSERT INTO prj_langerwisch.abschlusspunkte (id,geom,knoten_id,typ,einbauort,homeconnect_status,cluster)
	select 
		uuid,geom,knoten_uuid,typ,einbauort,homeconnect_status,cluster
	from comsof.abschlusspunkte;	

-- in order to feed dv_abschluss the table adresse_abschluss should get feed after microducts.	
-- ---- adresse_abschluss
-- INSERT INTO prj_langerwisch.adresse_abschluss (adresse_id, abschlusspunkte_id, cluster)
-- 	select 
-- 		adresse_id,abschlusspunkte_uuid,cluster
-- 	from comsof.adresse_abschluss;	

---- Connection_module
INSERT INTO prj_langerwisch.connection_module (id,typ,produkt_id,knoten_id,netzebene_quelle,netzebene_ziel,eigentum_status,foerdert_status, planung_status,cluster)
	select 
		uuid,typ,produkt_id,knoten_uuid,netzebene_quelle,netzebene_ziel,eigentum_status,foerdert_status,planung_status,cluster
	from comsof.connection_module;	
	
---- connection_unit
INSERT INTO prj_langerwisch.connection_unit(id,conn_module_id,produkt_id,letzten_datum_mod,cluster)
	select 
	uuid,conn_module_uuid,produkt_id,letzten_datum_mod,cluster
	from comsof.connection_unit;	

---- Connection_element
INSERT INTO prj_langerwisch.connection_element(id,conn_unit_id,produkt_id,typ,subtyp,installation_ziele,installation_spalte,label,mehrdetail,cluster)
	select 
		uuid,conn_unit_uuid,produkt_id,typ,subtyp,installation_ziele,installation_spalte,label,mehrdetail,cluster
	from comsof.connection_element;	

---- Kabel
INSERT INTO prj_langerwisch.kabel (id,bez,geom,produkt_id, anzahl_fasern,typ,netzebene,conn_module_anfang,conn_module_ende,planung_status,foerdert_status,eigentum_status,homeconnect_status,length,cluster)
	select 
		uuid,bez,geom,produkt_id, anzahl_fasern,typ,netzebene,conn_module_anfang_uuid,conn_module_ende_uuid,planung_status,foerdert_status,eigentum_status,homeconnect_status,length,cluster
	from comsof.kabel;

---- Faser
INSERT INTO prj_langerwisch.faser (id , bez,geom,kabel_id,netzebene, buendeln_nr,faser_label,conn_element_anfang,anf_elem_output_nr,anfang_typ,anfang_label,conn_element_ende,end_elem_input_nr,ende_typ,ende_label,length,external_id,cluster)
	select 
		uuid, bez, geom,kabel_uuid,netzebene, buendeln_nr,faser_label,conn_element_anfang_uuid,anf_elem_output_nr,anfang_typ,anfang_label,conn_element_ende_uuid,end_elem_input_nr,ende_typ,ende_label,length,external_id,cluster
	from comsof.faser;	
	
---- Rohr
INSERT INTO prj_langerwisch.rohr (id,bez,geom,typ,produkt_id, anzahl_microducts,mantel_farbe,mantel_label,planung_status,foerdert_status,netzebene,homeconnect_status,cluster)
	select 
		uuid,bez,geom,typ,produkt_id, anzahl_microducts, mantel_farbe,mantel_label,planung_status,foerdert_status,netzebene,homeconnect_status,cluster
	from comsof.rohr;

---- Microduct
INSERT INTO prj_langerwisch.microduct(id,bez,geom,rohr_id,microduct_nr,knoten_anfang,   conn_module_anfang, conn_module_anfang_label,knoten_ende ,conn_module_ende, conn_module_ende_label,stammt_von, bottom_agg_id, zweig, kabel_id,netzebene, bez_wert,cluster) 
	select 
		uuid,bez,geom,rohr_uuid,microduct_nr,knoten_anfang_uuid, conn_module_anfang_uuid ,conn_module_anfang_label,knoten_ende_uuid, conn_module_ende_uuid, conn_module_ende_label,stammt_von_uuid, (select uuid::text from comsof.knoten kn where kn.id=bottom_agg_id::int), zweig,kabel_uuid,netzebene, bez_wert,cluster
	from comsof.microduct;

	
---- adresse_abschluss
INSERT INTO prj_langerwisch.adresse_abschluss (adresse_id, abschlusspunkte_id, cluster)
	select 
		adresse_id,abschlusspunkte_uuid,cluster
	from comsof.adresse_abschluss;		
	
	
---- Trasse
INSERT INTO prj_langerwisch.trasse(id,geom,typ,trassenbauverfahren,sonst_bauverfahren,verlege_tief_m,oberflaeche,widmung,foerdert_status,planung_status,homeconnect_status,netzebene,cluster)
	select 
		uuid,geom,typ,trassenbauverfahren,sonst_bauverfahren,verlege_tief_m,oberflaeche,widmung,foerdert_status,planung_status,homeconnect_status,netzebene,cluster
	from comsof.trasse;		

---- Schutzrohr
INSERT INTO prj_langerwisch.schutzrohr (id,geom,produkt_id,foerdert_status,planung_status,aggregation_id,cluster)
	select 
		uuid,geom,produkt_id,foerdert_status,planung_status,aggregation_id,cluster
	from comsof.schutzrohr;	
	
---- rohr_schutzrohr
INSERT INTO prj_langerwisch.rohr_schutzrohr (schutzrohr_id,rohr_id,cluster)
	select 
		schutzrohr_uuid,rohr_uuid,cluster
	from comsof.rohr_schutzrohr;
	
---- strecke
INSERT INTO prj_langerwisch.strecke (_id,typ,cluster)
	select 
		_uuid,typ,cluster
	from comsof.strecke;	
	












