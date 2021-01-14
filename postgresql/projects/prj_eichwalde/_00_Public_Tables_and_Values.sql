/*To generate and feed tables used for all schmas

	On Each new Project in the schema of that project
Version 15-10-2020
*/
/* Drop if esixts #############################################################################################*/
DROP TABLE IF EXISTS _cluster;
DROP TABLE IF EXISTS pr_rohr;
DROP TABLE IF EXISTS pr_kabel;
DROP TABLE IF EXISTS pr_connection_unit;
DROP TABLE IF EXISTS _farbcode;
DROP TABLE IF EXISTS _produkt_katalog;


/* Table Definitions #############################################################################################*/
CREATE TABLE _cluster(
	id SERIAL,
	cluster_name text,
	project_name text,
	cluster_parent integer,
	onb_onkz text,-- as prefix to bezeichnung
	gemeindeschluessel dom_8_digit_string[],
	bezirk_nr dom_2_digit_string[],
	zubringerpunkt text, --bezeichnung of the main feeder point in this cluster.
	version text Default '1.0',
	beschreibung text,
	crs_epsg varchar(5) NOT NULL Default '25833',
	schema_name text Not Null, -- the name of the schama that the project is stored on
	bbox_wkt text,
	CONSTRAINT pk_cluster PRIMARY KEY (id),
	CONSTRAINT fk_cluster_epsg FOREIGN KEY (crs_epsg) REFERENCES enum_epsg(val) ON UPDATE CASCADE,
	CONSTRAINT fk_cluster_clusterparent FOREIGN KEY (cluster_parent) REFERENCES _cluster(id) /*ON DELETE CASCADE*/ ON UPDATE CASCADE
);
--alter table _cluster drop constraint fk_cluster_clusterparent , add constraint fk_cluster_clusterparent FOREIGN KEY (cluster_parent) REFERENCES _cluster(id)ON UPDATE CASCADE;
CREATE INDEX inx_cluster_clustername ON _cluster(cluster_name);
--CREATE INDEX inx_cluster_bbox ON _cluster USING GIST(bbox);

CREATE TABLE _farbcode (
	standard text,
	code integer,
	farbe text NOT NULL,
	description text,
	CONSTRAINT pk_farbcode PRIMARY KEY (standard, code)
);
CREATE UNIQuE INDEX inxunq_farbcode_frabe ON _farbcode(standard,farbe);

CREATE TABLE pr_rohr (
	id serial,
	produkt text  Not Null,
	typ  text Not Null, /*references enum_produkt_rohr_typ*/
	anzahl_microducts dom_zahl Not Null,
	abmessung  text, /*e.g.  '10 x 7 x 1,5 + 1 x 16 x 2,0'*/
	dns_intern_artikelnr text, /*Artikel Id in the DNS Intern system*/
	--mantel_farbe text, /*references enum_farbe*/
	max_einblusdruck numeric, /*Bar*/
	farbcode text Not NULL DEFAULT 'DIN_VDE_0888',
	CONSTRAINT pk_prrohr PRIMARY KEY (id),
	CONSTRAINT fk_prrohr_typ FOREIGN KEY (typ) REFERENCES enum_produkt_rohr_typ(val) ON UPDATE CASCADE
	--,constraint fk_prrohr_mantelfarbe foreign key (mantel_farbe) references enum_farbe On Update cascade
);
CREATE UNIQUE INDEX inx_unq_prrohr_produkt ON pr_rohr(produkt);
alter table pr_rohr add constraint inq_prrohr_produkt_anzahlmicroducts unique (produkt, anzahl_microducts); -- is referenced as foreign key. it should have unique contraint
	
CREATE TABLE pr_kabel (
	id serial,
	produkt text Not Null,
	/*Copper*/
	leiter text CHECK (leiter IN ('GOF (Silica Glass Optical Fiber)','POF (Plastic Optical Fiber)','Copper')),
	strad_typ text CHECK (strad_typ IN ('Einmodenfaser (SMF)'/*E*/, 'Mehrmodenfaser Gradienternindex(Glaskern/Glasmatnel)'/*G*/, 'Mehrmodenfaser Gradienternindex(Glaskern/Kunststoffmantel)'/*GK*/, 'Mehrmodenfaser Stufenindex(Glaskern/Kunststoffmantel)'/*K*/, 'Mehrmodenfaser Stufenindex(Glaskern/Glasmantel)'/*P*/, 'Mehrmodenfaser Stufenindex(Kunststoffkern/Kunststoffmantel)'/*S*/, 'Copper', 'Twisted pair cable')),
	strand_class text CHECK (strand_class IN ('OS1','OS2','OM1','OM2','OM3','OM4','OM5')),
	einsatzbereich text CHECK (einsatzbereich IN ('Aussenkabel'/*A*/,'Universalkabel'/*A/I*/, 'Patchkabel', 'Innenkabel'/*J*/)),
	ader text CHECK (ader IN ('Compact Tube'/*(CT)*/, 'Buendelader, gefuellt'/*D*/, 'Buendelader, ungefuellt'/*B*/)),
	fuellung_kabelseele text CHECK (fuellung_kabelseele IN ('Fuellung mit Petrolat'/*F*/, 'Trockenes Quellmittel'/*Q*/, 'Feststoffanteilen'/*(OF)*/)),
	aussen_mantel text CHECK (aussen_mantel IN ('LSOH'/*H*/, 'PE' /*(2Y)*/, 'PVC'/*Y*/)),
	bewehrung text CHECK (bewehrung IN ('Bewehrung'/*B*/, 'Metallenes Zug-/Stuetzelement in der Kabelseelle' /*(ZS)*/,'Nichtmetallische Zugentlastungselement'/*(ZN)*/)),
	anzahl_buendeladern integer CHECK (anzahl_buendeladern IN (1, 2, 4, 6, 12, 24 )),
	faser_je_buendel integer CHECK (faser_je_buendel IN (1, 4, 6, 12)),
	anzahl_faser integer not null,
	--anzahl_buendeladern text CHECK (anzahl_buendeladern IN ('1x', '2x', '4x', '6x','12x', '24x' )),
	--faser_je_buendel text CHECK (faser_je_buendel IN ('4','6','12')),
	kern_durchmesser integer,/*in Micrometer*/
	mantel_durchmesser integer,/*in Micrometer*/
	daempfungskoefizient numeric, /*dB/Km*/
	bandbereite_Dispersion integer,/*Bandbreite in MHz.Km / Dispersion ps/nm.Km*/
	wellen_laenge integer CHECK (wellen_laenge in (850/*B*/, 1310/*F*/, 1550/*H*/)), 
	verseilung text CHECK (verseilung IN ('Lagenverseilung'/*LG*/, 'SZ-Verseilung'/*SZ*/)),
	farbcode text Not NULL DEFAULT 'DIN_VDE_0888',
	dns_intern_artikelnr text, /*Artikel Id in the DNS Intern system*/
	max_length numeric,
	CONSTRAINT pk_prkabel PRIMARY KEY (id)
);
alter table pr_kabel add constraint inq_prkabel_produkt_anzahlmicroducts unique (produkt, anzahl_faser); -- is referenced as foreign key. it should have unique contraint
CREATE UNIQUE INDEX inx_unq_prkabel_produkt ON pr_kabel(produkt); 
create or replace function tr_pr_kabel_anzalfaser() returns trigger as $$ begin new.anzahl_faser:=new.anzahl_buendeladern*new.faser_je_buendel; return new; End; $$LAnguage plpgsql;
drop trigger if exists tr_pr_kabel_anzalfaser on pr_kabel;
create trigger tr_pr_kabel_anzalfaser 
	BEFORe insert or update on pr_kabel
		for each row
			execute procedure tr_pr_kabel_anzalfaser();


create table pr_connection_unit(
/*temporary*/
	id serial,
	produkt text Not Null,
	anzal_connection_module dom_zahl,
	typ text,
	typ_input text,
	anzahl_input_kabel dom_zahl,
	typ_output text,
	anzahl_output_kabel dom_zahl,
	dns_intern_artikelnr text,
	CONSTRAINT pk_prconnectionunit PRIMARY KEY (id)
);
CREATE UNIQUE INDEX inx_unq_prconnectiounit_produkt ON pr_connection_unit(produkt);

CREATE TABLE _produkt_katalog (
	id serial,
	_produkt text,
	typ text,
	CONSTRAINT pk_produkt_katalog PRIMARY KEY (id)
);
CREATE UNIQUE INDEX inx_unq_produktkatalog_produkt ON _produkt_katalog(_produkt);
/*#todo Trigger to copy id in  _produkt_katalog*/



-- Rules
CREATE OR REPLACE RULE rule_prrohr_insert 
	AS ON INSERT TO pr_rohr 
		DO ALSO (INSERT INTO _produkt_katalog(_produkt,typ) values(new.produkt, 'rohr'));
CREATE OR REPLACE RULE rule_prrohr_delete 
	AS ON DELETE TO pr_rohr 
		DO ALSO (DELETE FROM _produkt_katalog WHERE _produkt=old.produkt);	
CREATE OR REPLACE RULE rule_prrohr_update
	AS ON UPDATE TO pr_rohr 
		DO ALSO (update _produkt_katalog set _produkt=new.produkt where _produkt=old.produkt);	
create or replace function tr_prrohr_truncate() returns trigger as $$
Begin
	EXECUTE('DELETE FROM _produkt_katalog where lower(typ)=lower($1);') using 'rohr';
	RETURN OLD;
END;
$$ LANGUAGE PLPGSQL;
DROP TRIGGER IF EXISTS  tr_prrohr_truncate ON pr_rohr; 
CREATE TRIGGER tr_prrohr_truncate
	AFTER TRUNCATE ON pr_rohr
			EXECUTE PROCEDURE tr_prrohr_truncate();


CREATE OR REPLACE RULE rule_prkabel_insert 
	AS ON INSERT TO pr_kabel 
		DO ALSO (INSERT INTO _produkt_katalog(_produkt,typ) values(new.produkt, 'kabel'));
CREATE OR REPLACE RULE rule_prkabel_delete 
	AS ON DELETE TO pr_kabel 
		DO ALSO (DELETE FROM _produkt_katalog WHERE _produkt=old.produkt);	
CREATE OR REPLACE RULE rule_prkabel_update
	AS ON UPDATE TO pr_kabel 
		DO ALSO (update _produkt_katalog set _produkt=new.produkt where _produkt=old.produkt);	
create or replace function tr_prkabel_truncate() returns trigger as $$
Begin
	EXECUTE('DELETE FROM _produkt_katalog where lower(typ)=lower($1);') using 'kabel';
	RETURN OLD;
END;
$$ LANGUAGE PLPGSQL;
DROP TRIGGER IF EXISTS  tr_prkabel_truncate ON pr_kabel; 
CREATE TRIGGER tr_prkabel_truncate
	AFTER TRUNCATE ON pr_kabel
			EXECUTE PROCEDURE tr_prkabel_truncate();




CREATE OR REPLACE RULE rule_prconnectionunit_insert 
	AS ON INSERT TO pr_connection_unit 
		DO ALSO (INSERT INTO _produkt_katalog(_produkt,typ) values(new.produkt, 'connection_unit'));
CREATE OR REPLACE RULE rule_prconnectionunit_delete 
	AS ON DELETE TO pr_connection_unit 
		DO ALSO (DELETE FROM _produkt_katalog WHERE _produkt=old.produkt);	
CREATE OR REPLACE RULE rule_prconnectionunit_update
	AS ON UPDATE TO pr_connection_unit 
		DO ALSO (update _produkt_katalog set _produkt=new.produkt where _produkt=old.produkt);	
create or replace function tr_prconnectionunit_truncate() returns trigger as $$
Begin
	EXECUTE('DELETE FROM _produkt_katalog where lower(typ)=lower($1);') using 'connection_unit';
	RETURN OLD;
END;
$$ LANGUAGE PLPGSQL;
DROP TRIGGER IF EXISTS  tr_prconnectionunit_truncate ON pr_connection_unit; 
CREATE TRIGGER tr_prconnectionunit_truncate
	AFTER TRUNCATE ON pr_connection_unit
			EXECUTE PROCEDURE tr_prconnectionunit_truncate();		



---- Feeding the general tables


INSERT INTO _farbcode(standard, code, farbe, description) Values ('DIN_VDE_0888', 1, 'rt', 'rot');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('DIN_VDE_0888', 2, 'gn', 'gruen');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('DIN_VDE_0888', 3, 'bl', 'blau');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('DIN_VDE_0888', 4, 'ge', 'gelb');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('DIN_VDE_0888', 5, 'ws', 'weiss');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('DIN_VDE_0888', 6, 'gr', 'grau');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('DIN_VDE_0888', 7, 'br', 'braun');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('DIN_VDE_0888', 8, 'vi', 'violett');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('DIN_VDE_0888', 9, 'tk', 'tuerkis');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('DIN_VDE_0888', 10, 'sw', 'schwarz');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('DIN_VDE_0888', 11, 'or', 'orange');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('DIN_VDE_0888', 12, 'rs', 'rosa');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('DIN_VDE_0888', 13, 'rt+', 'rot_markiert');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('DIN_VDE_0888', 14, 'gn+', 'gruen_markiert');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('DIN_VDE_0888', 15, 'bl+', 'blau_markiert');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('DIN_VDE_0888', 16, 'ge+', 'gelb_markiert');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('DIN_VDE_0888', 17, 'ws+', 'weiss_markiert');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('DIN_VDE_0888', 18, 'gr+', 'grau_markiert');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('DIN_VDE_0888', 19, 'br+', 'braun_markiert');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('DIN_VDE_0888', 20, 'vi+', 'violett_markiert');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('DIN_VDE_0888', 21, 'tk+', 'tuerkis_markiert');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('DIN_VDE_0888', 22, 'sw+', 'schwarz_markiert');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('DIN_VDE_0888', 23, 'or+', 'orange_markiert');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('DIN_VDE_0888', 24, 'rs+', 'rosa_markiert');

INSERT INTO _farbcode(standard, code, farbe, description) Values ('2-Farbiger_Standard', 1, 'rt/ge','rot/gelb');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('2-Farbiger_Standard', 2, 'rt/gn', 'rot/gruen');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('2-Farbiger_Standard', 3, 'rt/bl', 'rot/blau');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('2-Farbiger_Standard', 4, 'rt/vi', 'rot/viollet');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('2-Farbiger_Standard', 5, 'rt/gr', 'rot/grau');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('2-Farbiger_Standard', 6, 'ge/bl', 'gelb/blau');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('2-Farbiger_Standard', 7, 'ge/vi', 'gelb/viollet');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('2-Farbiger_Standard', 8, 'ge/gr', 'gelb/grau');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('2-Farbiger_Standard', 9, 'gr/bl', 'gruen/balu');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('2-Farbiger_Standard', 10, 'gn/vi', 'gruen/viollet');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('2-Farbiger_Standard', 11, 'gn/gr', 'gruen/grau');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('2-Farbiger_Standard', 12, 'br/bl', 'braun/blau');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('2-Farbiger_Standard', 13, 'br/vi', 'braun/viollet');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('2-Farbiger_Standard', 14, 'br/gr', 'braun/grau');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('2-Farbiger_Standard', 15, 'br/gn', 'braun/gruen');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('2-Farbiger_Standard', 16, 'br/ge', 'braun/gelb');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('2-Farbiger_Standard', 17, 'br/rt', 'braun/rot');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('2-Farbiger_Standard', 18, 'sw/rt', 'schwarz/rot');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('2-Farbiger_Standard', 19, 'sw/ge', 'schwarz/gelb');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('2-Farbiger_Standard', 20, 'sw/gn', 'schwarz/gruen');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('2-Farbiger_Standard', 21, 'sw/bl', 'schwarz/blau');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('2-Farbiger_Standard', 22, 'sw/vi', 'schwarz/viollet');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('2-Farbiger_Standard', 23, 'sw/gr', 'schwarz/grau');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('2-Farbiger_Standard', 24, 'sw/br', 'schwarz/braun');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('2-Farbiger_Standard', 25, 'rt/rt', 'rot/rot');

INSERT INTO _farbcode(standard, code, farbe, description) Values ('Swisscom', 1, 'rt', 'rot');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('Swisscom', 2, 'gn', 'gruen');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('Swisscom', 3, 'ge', 'gelb');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('Swisscom', 4, 'bl', 'blau');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('Swisscom', 5, 'ws', 'weiss');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('Swisscom', 6, 'vi', 'violett');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('Swisscom', 7, 'or', 'orange');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('Swisscom', 8, 'sw', 'schwarz');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('Swisscom', 9, 'gr', 'grau');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('Swisscom', 10, 'br', 'braun');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('Swisscom', 11, 'rs', 'rosa');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('Swisscom', 12, 'tk', 'tuerkis');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('Swisscom', 13, 'rt+', 'rot_markiert');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('Swisscom', 14, 'gn+', 'gruen_markiert');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('Swisscom', 15, 'ge+', 'gelb_markiert');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('Swisscom', 16, 'bl+', 'blau_markiert');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('Swisscom', 17, 'ws+', 'weiss_markiert');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('Swisscom', 18, 'vi+', 'violett_markiert');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('Swisscom', 19, 'or+', 'orange_markiert');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('Swisscom', 20, 'sw+', 'schwarz_markiert');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('Swisscom', 21, 'gr+', 'grau_markiert');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('Swisscom', 22, 'br+', 'braun_markiert');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('Swisscom', 23, 'rs+', 'rosa_markiert');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('Swisscom', 24, 'tk+', 'tuerkis_markiert');

INSERT INTO _farbcode(standard, code, farbe, description) Values ('ISO', 1, 'bl', 'blau');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('ISO', 2, 'or', 'orange');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('ISO', 3, 'gn', 'gruen');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('ISO', 4, 'rt', 'rot');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('ISO', 5, 'gr', 'grau');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('ISO', 6, 'ge', 'gelb');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('ISO', 7, 'br', 'braun');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('ISO', 8, 'vi', 'violett');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('ISO', 9, 'ws', 'weiss');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('ISO', 10, 'sw', 'schwarz');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('ISO', 11, 'rs', 'rosa');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('ISO', 12, 'tk', 'tuerkis');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('ISO', 13, 'bl+', 'blau_markiert');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('ISO', 14, 'or+', 'orange_markiert');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('ISO', 15, 'gn+', 'gruen_markiert');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('ISO', 16, 'rt+', 'rot_markiert');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('ISO', 17, 'gr+', 'grau_markiert');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('ISO', 18, 'ge+', 'gelb_markiert');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('ISO', 19, 'br+', 'braun_markiert');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('ISO', 20, 'vi+', 'violett_markiert');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('ISO', 21, 'ws+', 'weiss_markiert');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('ISO', 22, 'sw+', 'schwarz_markiert');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('ISO', 23, 'rs+', 'rosa_markiert');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('ISO', 24, 'tk+', 'tuerkis_markiert');

INSERT INTO _farbcode(standard, code, farbe, description) Values ('IEC 60794-2', 1, 'bl', 'blau');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('IEC 60794-2', 2, 'ge', 'gelb');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('IEC 60794-2', 3, 'rt', 'rot');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('IEC 60794-2', 4, 'ws', 'weiss');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('IEC 60794-2', 5, 'gn', 'gruen');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('IEC 60794-2', 6, 'vi', 'violett');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('IEC 60794-2', 7, 'or', 'orange');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('IEC 60794-2', 8, 'gr', 'grau');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('IEC 60794-2', 9, 'tk', 'tuerkis');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('IEC 60794-2', 10, 'sw', 'schwarz');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('IEC 60794-2', 11, 'br', 'braun');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('IEC 60794-2', 12, 'rs', 'rosa');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('IEC 60794-2', 13, 'bl+', 'blau_markiert');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('IEC 60794-2', 14, 'ge+', 'gelb_markiert');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('IEC 60794-2', 15, 'rt+', 'rot_markiert');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('IEC 60794-2', 16, 'ws+', 'weiss_markiert');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('IEC 60794-2', 17, 'gn+', 'gruen_markiert');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('IEC 60794-2', 18, 'vi+', 'violett_markiert');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('IEC 60794-2', 19, 'or+', 'orange_markiert');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('IEC 60794-2', 20, 'gr+', 'grau_markiert');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('IEC 60794-2', 21, 'tk+', 'tuerkis_markiert');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('IEC 60794-2', 22, 'sw+', 'schwarz_markiert');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('IEC 60794-2', 23, 'br+', 'braun_markiert');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('IEC 60794-2', 24, 'rs+', 'rosa_markiert');

INSERT INTO _farbcode(standard, code, farbe, description) Values ('TIA/EIA-598', 1, 'bl', 'blau');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('TIA/EIA-598', 2, 'or', 'orange');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('TIA/EIA-598', 3, 'gn', 'gruen');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('TIA/EIA-598', 4, 'br', 'braun');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('TIA/EIA-598', 5, 'gr', 'grau');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('TIA/EIA-598', 6, 'ws', 'weiss');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('TIA/EIA-598', 7, 'rt', 'rot');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('TIA/EIA-598', 8, 'sw', 'schwarz');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('TIA/EIA-598', 9, 'ge', 'gelb');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('TIA/EIA-598', 10, 'vi', 'violett');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('TIA/EIA-598', 11, 'rs', 'rosa');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('TIA/EIA-598', 12, 'tk', 'tuerkis');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('TIA/EIA-598', 13, 'bl+', 'blau_markiert');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('TIA/EIA-598', 14, 'or+', 'orange_markiert');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('TIA/EIA-598', 15, 'gn+', 'gruen_markiert');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('TIA/EIA-598', 16, 'br+', 'braun_markiert');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('TIA/EIA-598', 17, 'gr+', 'grau_markiert');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('TIA/EIA-598', 18, 'ws+', 'weiss_markiert');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('TIA/EIA-598', 19, 'rt+', 'rot_markiert');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('TIA/EIA-598', 20, 'sw+', 'schwarz_markiert');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('TIA/EIA-598', 21, 'ge+', 'gelb_markiert');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('TIA/EIA-598', 22, 'vi+', 'violett_markiert');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('TIA/EIA-598', 23, 'rs+', 'rosa_markiert');
INSERT INTO _farbcode(standard, code, farbe, description) Values ('TIA/EIA-598', 24, 'tk+', 'tuerkis_markiert');








--- Feeding produkt_kataloges
insert into pr_rohr(id, produkt, typ, anzahl_microducts, abmessung, dns_intern_artikelnr) values(1, 'r1', 'Rohrverband', 4 , '4 x 16/12', Null);
insert into pr_rohr(id, produkt, typ, anzahl_microducts, abmessung, dns_intern_artikelnr) values(2, 'r2', 'Rohrverband', 24 , '24 x 10/6', Null);
insert into pr_rohr(id, produkt, typ, anzahl_microducts, abmessung, dns_intern_artikelnr) values(3, 'r3', 'Rohrverband', 12 , '12 x 10/6', Null);
insert into pr_rohr(id, produkt, typ, anzahl_microducts, abmessung, dns_intern_artikelnr) values(4, 'r4', 'Einzelrohr', 1 , '1 x 10/6', 'MICROROHR-10MM-1X10/6');

---- # is set in order to handel the case that another rohr with the same specifications but other farbcode
Update pr_rohr set produkt= 'MRV- '|| abmessung||' #' ||farbcode where anzahl_microducts=4; 
Update pr_rohr set produkt= 'MRV- '|| abmessung ||' #' ||farbcode where anzahl_microducts in (12,24);
Update pr_rohr set produkt= 'ER- '|| abmessung||' #' || farbcode  where anzahl_microducts=1;


Insert into pr_kabel (id, produkt, leiter, strad_typ, strand_class, einsatzbereich, ader, fuellung_kabelseele    , aussen_mantel, bewehrung, anzahl_buendeladern,faser_je_buendel,kern_durchmesser,mantel_durchmesser,     daempfungskoefizient,bandbereite_dispersion,verseilung,farbcode,dns_intern_artikelnr, wellen_laenge,max_length)
	values (1, 'k1', 'GOF (Silica Glass Optical Fiber)'		,'Einmodenfaser (SMF)'		,'OS2'		,'Aussenkabel'		,'Compact Tube'		,'Trockenes Quellmittel'				,'PVC'		,'Metallenes Zug-/Stuetzelement in der Kabelseelle'		,12		,12		,9		,125				,2.7		,400		,'Lagenverseilung'		, 'DIN_VDE_0888'		,'LWL-KABEL-MICRO-SM-12X12'		,null	,null	);

Insert into pr_kabel (id, produkt, leiter, strad_typ, strand_class, einsatzbereich, ader, fuellung_kabelseele    , aussen_mantel, bewehrung, anzahl_buendeladern,faser_je_buendel,kern_durchmesser,mantel_durchmesser,     daempfungskoefizient,bandbereite_dispersion,verseilung,farbcode,dns_intern_artikelnr, wellen_laenge,max_length)
	values (2, 'k2','GOF (Silica Glass Optical Fiber)'	,'Einmodenfaser (SMF)'	,'OS2'	,'Aussenkabel'	,'Compact Tube'	,'Trockenes Quellmittel'		,'PVC'	,'Bewehrung'	,4	,12	,9	,125			,2.7	,400  ,'Lagenverseilung'		, 'DIN_VDE_0888'		,'LWL-KABEL-UNI-SM-4X12'		,null	,null);
	
Insert into pr_kabel (id, produkt, leiter, strad_typ, strand_class, einsatzbereich, ader, fuellung_kabelseele    , aussen_mantel, bewehrung, anzahl_buendeladern,faser_je_buendel,kern_durchmesser,mantel_durchmesser,     daempfungskoefizient,bandbereite_dispersion,verseilung,farbcode,dns_intern_artikelnr, wellen_laenge,max_length)
	values (3,		'k3','GOF (Silica Glass Optical Fiber)'		,'Einmodenfaser (SMF)'	,'OS2'	,'Aussenkabel'	,'Compact Tube'	,'Trockenes Quellmittel'		,'PVC'	,'Bewehrung'	,2	,12	,9	,125	,2.7	,400	,'Lagenverseilung'	, 'DIN_VDE_0888'	,Null	,null,null	);

Insert into pr_kabel (id, produkt, leiter, strad_typ, strand_class, einsatzbereich, ader, fuellung_kabelseele    , aussen_mantel, bewehrung, anzahl_buendeladern,faser_je_buendel,kern_durchmesser,mantel_durchmesser,     daempfungskoefizient,bandbereite_dispersion,verseilung,farbcode,dns_intern_artikelnr, wellen_laenge,max_length)
	values (4,		'k4','GOF (Silica Glass Optical Fiber)'		,'Einmodenfaser (SMF)'		,'OS2'		,'Aussenkabel'		,'Compact Tube'		,'Trockenes Quellmittel'		,'PVC','Bewehrung'	,1	,12	,9		,125	,2.7	,400		,'Lagenverseilung'	, 'DIN_VDE_0888'	,'LWL-KABEL-SM-1X12-MICRO',null	,null	);


/* update the produkt values*/


Do $$
DECLARE 
	it integer;
	p1 text; p2 text; p3 text; p4 text; p5 text; p6 text; p7 text;
	p8 text; p9 text; p10 text; p11 text ;p12 text; p13 text;
	txt text;
BEGIN
	for it in (select id from pr_kabel) loop
		select case when einsatzbereich='Aussenkabel' Then 'A' when einsatzbereich='Universalkabel' Then 'A/I' when einsatzbereich='Innenkabel' then 'J' End from pr_kabel into p1;
		select case when ader='Compact Tube' then'(CT)' when ader='Buendelader, gefuellt' then 'D' when ader='Buendelader, gefuellt' then 'B' end  from pr_kabel into p2;
		select case when fuellung_kabelseele='Fuellung mit Petrolat' then 'F' when fuellung_kabelseele='Trockenes Quellmittel' then 'Q' when fuellung_kabelseele='Feststoffanteilen' then 'OF' end  from pr_kabel into p3; 
		select case  when bewehrung='Bewehrung' then 'B' when bewehrung='Metallenes Zug-/Stuetzelement in der Kabelseelle' then '(ZS)' when bewehrung='Nichtmetallische Zugentlastungselement' then '(ZN)' end from pr_kabel into p4;
		select case  when aussen_mantel='LSOH' then 'H' when aussen_mantel='PE' then '(2Y)' when aussen_mantel='PVC' then 'Y' end from pr_kabel into p5;
		select (anzahl_buendeladern)::text||'x' from pr_kabel into p6;
		select (faser_je_buendel)::text from pr_kabel into p7;
		select case when strad_typ ='Einmodenfaser (SMF)' then 'E' when strad_typ ='Mehrmodenfaser Gradienternindex(Glaskern/Glasmatnel)' then 'G' 	when strad_typ ='Mehrmodenfaser Gradienternindex(Glaskern/Kunststoffmantel)' then '(GK)' when strad_typ ='Mehrmodenfaser Stufenindex(Glaskern/Kunststoffmantel)' then 'K' 	when strad_typ ='Mehrmodenfaser Stufenindex(Glaskern/Glasmantel)' then 'S' when strad_typ ='Mehrmodenfaser Stufenindex(Kunststoffkern/Kunststoffmantel)' then 'P' end  from pr_kabel into p8;
		select kern_durchmesser::text || '/' || mantel_durchmesser::text from pr_kabel into p9;
		select daempfungskoefizient::text from pr_kabel into p10;
		select case when wellen_laenge =1310 then 'F' when wellen_laenge =1550 then 'H' when wellen_laenge =850 then 'B'  end  from pr_kabel into p11;
		select bandbereite_Dispersion from pr_kabel into p12;
		select case when verseilung ='Lagenverseilung' then 'LG' when verseilung ='SZ-Verseilung' then 'SZ' end  from pr_kabel into p13;
		select COALESCE(p1,'')||'-'||COALESCE(p2,'')||COALESCE(p3,'') ||' '|| COALESCE(p4,'')||COALESCE(p5,'') ||' '|| COALESCE(p6,'') ||COALESCE(p7,'')||' '|| COALESCE(p8,'') ||COALESCE(p9,'') ||' '||COALESCE(p10,'')||COALESCE(p11,' ')||COALESCE(p12,'') ||' '||COALESCE(p13,'') into txt; 
		execute('update pr_kabel set produkt=$1 where id = $2') using txt, it;
	end loop;
END;
$$  LANGUAGE plpgsql;


INSERT INTO pr_connection_unit(id, produkt,anzal_connection_module , typ, typ_input, anzahl_input_kabel, typ_output, anzahl_output_kabel, dns_intern_artikelnr)VALUES (1,'FTTH Abschlußbox AP (unbestückt) Typ M', 1,'panel','Spleisser', 2, 'LC connector',6, 'FTTH-ABSCHLUSSBOX-AP-TYP_M');




