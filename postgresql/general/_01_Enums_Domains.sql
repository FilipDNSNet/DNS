/*PostgreSQL ENUMs and Domain
DNS-Net Datamodel-A for Geodatamanagement and palning.

prerequisites:
	- 00_Public_Tables_and_Values.sql

Version 10-11-2020
*/
/* List of ENUMs
	enum_epsg                      
	enum_netzebene                 
	enum_foerdertstatus            
	enum_status                    
	enum_ja_nein                   
	enum_hc_status                 
	enum_eigentum                  
	enum_widmung                   
	enum_strecke_typ               
	enum_adresse_typ               
	enum_adresse_verifiziert       
	enum_adresse_funktionkategorie 
	enum_adresse_qualitaet         
	enum_adresse_status            
	enum_trasse_typ                
	enum_trassenbauverfahren       
	enum_trasse_oberflaeche        
	enum_kabel_typ                 
	enum_rohr_typ                  
	enum_knoten_typ              
	enum_knoten_subtyp           
	enum_connmodule_typ              
	enum_vertriebsstatus           
	enum_faserconn                 
	enum_connelement_typ           
	enum_connelement_subtyp        
	enum_abschlusspunkte_typ       
	enum_abschlusspunkte_einbauort 
	enum_abschlusspunkte_status    
	enum_produkt_rohr_typ          
	enum_farbe
	enum_bundesland
	enum_status_nvt
	enum_status_ap
*/
/* List of DOMAINS
	dom_adresse_id
	dom_2_digit_string
	dom_4_digit_string
	dom_5_digit_string
	dom_6_digit_string
	dom_8_digit_string
	dom_numeric_string
	dom_zahl
	dom_cluster
	dom_produkt_id
	dom_vid
*/

/*###	Drop exxisitng Domains and Enums	###################################################################################################################################*/
DROP DOMAIN IF EXISTS dom_adresse_id;
DROP DOMAIN IF EXISTS dom_2_digit_string;
DROP DOMAIN IF EXISTS dom_4_digit_string;
DROP DOMAIN IF EXISTS dom_5_digit_string;
DROP DOMAIN IF EXISTS dom_6_digit_string;
DROP DOMAIN IF EXISTS dom_8_digit_string;
DROP DOMAIN IF EXISTS dom_numeric_string;
DROP DOMAIN IF EXISTS dom_zahl;
DROP DOMAIN IF EXISTS dom_cluster;
DROP DOMAIN IF EXISTS dom_produkt_id;
DROP DOMAIN IF EXISTS dom_vid;

DROP TABLE IF EXISTS enum_epsg;
DROP TABLE IF EXISTS enum_netzebene ;
DROP TABLE IF EXISTS enum_foerdertstatus ;
DROP TABLE IF EXISTS enum_planungsstatus ;
DROP TABLE IF EXISTS enum_ja_nein ;
DROP TABLE IF EXISTS enum_hc_status ;
DROP TABLE IF EXISTS enum_eigentum ;
DROP TABLE IF EXISTS enum_widmung ;
DROP TABLE IF EXISTS enum_strecke_typ ;
DROP TABLE IF EXISTS enum_adresse_typ ;
DROP TABLE IF EXISTS enum_adresse_verifiziert ;
DROP TABLE IF EXISTS enum_adresse_funktionkategorie ;
DROP TABLE IF EXISTS enum_adresse_qualitaet ;
DROP TABLE IF EXISTS enum_adresse_status ;
DROP TABLE IF EXISTS enum_trasse_typ ;
DROP TABLE IF EXISTS enum_trassenbauverfahren ;
DROP TABLE IF EXISTS enum_trasse_oberflaeche ;
DROP TABLE IF EXISTS enum_kabel_typ ;
DROP TABLE IF EXISTS enum_rohr_typ ;
DROP TABLE IF EXISTS enum_knoten_typ ;
DROP TABLE IF EXISTS enum_knoten_subtyp ;
DROP TABLE IF EXISTS enum_connmodule_typ ;
DROP TABLE IF EXISTS enum_vertriebsstatus ;
DROP TABLE IF EXISTS enum_faserconn ;
DROP TABLE IF EXISTS enum_connelement_typ ;
DROP TABLE IF EXISTS enum_connelement_subtyp ;
DROP TABLE IF EXISTS enum_abschlusspunkte_typ ;
DROP TABLE IF EXISTS enum_abschlusspunkte_einbauort ;
DROP TABLE IF EXISTS enum_abschlusspunkte_status ;
DROP TABLE IF EXISTS enum_produkt_rohr_typ ;
DROP TABLE IF EXISTS enum_farbe;
DROP TABLE IF EXISTS enum_bundesland;
drop table if exists enum_status_nvt; --for dv
drop table if exists enum_status_ap;--for dv

DROP TABLE IF EXISTS enum_adressen_verifizierungstyp;
DROP TABLE IF EXISTS enum_adressen_anlysiert_durch;
DROP TABLE IF EXISTS enum_adressen_foerder_status;



/*###	Domains	###################################################################################################################################*/

CREATE DOMAIN dom_adresse_id AS VARCHAR(16) CHECK (LENGTH(VALUE)=16 /* Todo add more details */);

CREATE DOMAIN dom_2_digit_string AS VARCHAR(2) CHECK (VALUE ~ '^\d{2}$');

CREATE DOMAIN dom_4_digit_string AS VARCHAR(4) CHECK (VALUE ~ '^\d{4}$');

CREATE DOMAIN dom_5_digit_string AS VARCHAR(5) CHECK (VALUE ~ '^\d{5}$');

CREATE DOMAIN dom_6_digit_string AS VARCHAR(6) CHECK (VALUE ~ '^\d{6}$');

CREATE DOMAIN dom_8_digit_string AS VARCHAR(8) CHECK (VALUE ~ '^\d{8}$');

CREATE DOMAIN dom_numeric_string AS TEXT CHECK (VALUE ~ '^\d*$');


CREATE DOMAIN dom_zahl INTEGER  CHECK (Value >0);

CREATE DOMAIN dom_cluster AS TEXT;/* #todo: To get developed later!!! */

CREATE DOMAIN dom_produkt_id AS TEXT;/* #todo: To get developed later!!! */

CREATE DOMAIN dom_vid AS TEXT; /* #todo: To get developed later!!! */


/*###	Enums	###################################################################################################################################*/
CREATE TABLE enum_epsg (val TEXT PRIMARY KEY);
	INSERT INTO enum_epsg VALUES('25832');
	INSERT INTO enum_epsg VALUES('25833');

CREATE TABLE enum_netzebene (val TEXT PRIMARY KEY);
	INSERT INTO enum_netzebene VALUES('Backbone-Ebene');
	INSERT INTO enum_netzebene VALUES('Backbone/Haupt-Ebene');
	INSERT INTO enum_netzebene VALUES('Haupt-Ebene');
	INSERT INTO enum_netzebene VALUES('Haupt/Verteiler-Ebene');
	INSERT INTO enum_netzebene VALUES('Verteiler-Ebene');
	INSERT INTO enum_netzebene VALUES('Verteiler/Drop');
	INSERT INTO enum_netzebene VALUES('In-House-Ebene');


CREATE TABLE enum_foerdertstatus (val TEXT PRIMARY KEY);
	INSERT INTO enum_foerdertstatus VALUES('Eigenausbau');
	INSERT INTO enum_foerdertstatus VALUES('Gefoerdert');

CREATE TABLE enum_planungsstatus (val TEXT PRIMARY KEY);
	INSERT INTO enum_planungsstatus VALUES('Grobplanung');
	INSERT INTO enum_planungsstatus VALUES('Genehmigungsplanung');
	INSERT INTO enum_planungsstatus VALUES('Ausfuehrungsplanung');
	INSERT INTO enum_planungsstatus VALUES('In Ausfuehrung');
	INSERT INTO enum_planungsstatus VALUES('Vermessen/Dokumentiert');
	INSERT INTO enum_planungsstatus VALUES('Betriebsbereit');

CREATE TABLE enum_ja_nein (val TEXT PRIMARY KEY);
	INSERT INTO enum_ja_nein VALUES('Ja');
	INSERT INTO enum_ja_nein VALUES('Nein');

CREATE TABLE enum_hc_status (val TEXT PRIMARY KEY);
	INSERT INTO enum_hc_status VALUES('HC : Home-Connect');
	INSERT INTO enum_hc_status VALUES('Kein HC (Kein Home-Connect)');
	INSERT INTO enum_hc_status VALUES('HP : Home-Pass');

CREATE TABLE enum_eigentum (val TEXT PRIMARY KEY);
	INSERT INTO enum_eigentum VALUES('Eigentum');
	INSERT INTO enum_eigentum VALUES('Pacht');

CREATE TABLE enum_widmung (val TEXT PRIMARY KEY);
	INSERT INTO enum_widmung VALUES('Unbekannt');
	INSERT INTO enum_widmung VALUES('Oeffentlich');
	INSERT INTO enum_widmung VALUES('Privat');


CREATE TABLE enum_strecke_typ (val TEXT PRIMARY KEY);
	INSERT INTO enum_strecke_typ VALUES('Microduct');
	INSERT INTO enum_strecke_typ VALUES('Trasse');
	INSERT INTO enum_strecke_typ VALUES('Schutzrohr');

CREATE TABLE enum_adresse_typ (val TEXT PRIMARY KEY);
	INSERT INTO enum_adresse_typ VALUES('A: Adresse');
	INSERT INTO enum_adresse_typ VALUES('B: Platz/Strasse ohne Hausnummer');

CREATE TABLE enum_adresse_verifiziert (val TEXT PRIMARY KEY);
	INSERT INTO enum_adresse_verifiziert VALUES('Nicht-verifiziert');
	INSERT INTO enum_adresse_verifiziert VALUES('Lage-verifiziert');
	INSERT INTO enum_adresse_verifiziert VALUES('Nutzung-verifiziert');
	INSERT INTO enum_adresse_verifiziert VALUES('Funktion-verifiziert');
	INSERT INTO enum_adresse_verifiziert VALUES('Verifiziert');

CREATE TABLE enum_adresse_funktionkategorie (val TEXT PRIMARY KEY);
	INSERT INTO enum_adresse_funktionkategorie VALUES('Wohngebaeude');
	INSERT INTO enum_adresse_funktionkategorie VALUES('Wohn-und Gewerbegebaeude');
	INSERT INTO enum_adresse_funktionkategorie VALUES('Gewerbegebaeude');
	INSERT INTO enum_adresse_funktionkategorie VALUES('Schule und sonstige Bildungseinrichtung');
	INSERT INTO enum_adresse_funktionkategorie VALUES('Krankenhaus');
	INSERT INTO enum_adresse_funktionkategorie VALUES('Freizeit- und Erholung');
	INSERT INTO enum_adresse_funktionkategorie VALUES('Oeffentliche Gebaeude');
	INSERT INTO enum_adresse_funktionkategorie VALUES('Religioese und Kulturelle Nutzung');
	INSERT INTO enum_adresse_funktionkategorie VALUES('Sonstige Nutzung');

CREATE TABLE enum_adresse_qualitaet (val TEXT PRIMARY KEY);
	INSERT INTO enum_adresse_qualitaet VALUES('1- Hauskoordinate innerhalb Flurstueck');
	INSERT INTO enum_adresse_qualitaet VALUES('2- Koordinate liegt auf einem Gebaeudeumring');
	INSERT INTO enum_adresse_qualitaet VALUES('3- Katasterinterne Hausnummer / Hauskoordinate innerhalb Flurstueck');
	INSERT INTO enum_adresse_qualitaet VALUES('4- Datensatz im Regionalen Bezugssystem');

CREATE TABLE enum_adresse_status (val TEXT PRIMARY KEY);
	INSERT INTO enum_adresse_status VALUES('Bestand-Objekt');
	INSERT INTO enum_adresse_status VALUES('In Bau');
	INSERT INTO enum_adresse_status VALUES('Bebauungsplan');
	INSERT INTO enum_adresse_status VALUES('Bauluecke');
	INSERT INTO enum_adresse_status VALUES('Ruine');

CREATE TABLE enum_trasse_typ (val TEXT PRIMARY KEY);
	INSERT INTO enum_trasse_typ VALUES('Laengstrasse');
	INSERT INTO enum_trasse_typ VALUES('Querung');
	INSERT INTO enum_trasse_typ VALUES('Hausanschlusstrasse');
	INSERT INTO enum_trasse_typ VALUES('Sonstige');

CREATE TABLE enum_trassenbauverfahren (val TEXT PRIMARY KEY);
	INSERT INTO enum_trassenbauverfahren VALUES('Klassischer Tiefbau (Ausschachtung)');
	INSERT INTO enum_trassenbauverfahren VALUES('HDD Spuelbohrung');
	INSERT INTO enum_trassenbauverfahren VALUES('Pressbohrung/Bodenverdraengung');
	INSERT INTO enum_trassenbauverfahren VALUES('Erdrakete');
	INSERT INTO enum_trassenbauverfahren VALUES('Kabelpflug');
	INSERT INTO enum_trassenbauverfahren VALUES('Microtrenching');
	INSERT INTO enum_trassenbauverfahren VALUES('Minitrenching');
	INSERT INTO enum_trassenbauverfahren VALUES('Macrotrenching');
	INSERT INTO enum_trassenbauverfahren VALUES('Verlegung in Schutzrohre (Bestand)');
	INSERT INTO enum_trassenbauverfahren VALUES('Mitverlegung Bestandsleitungen (andere Medien)');
	INSERT INTO enum_trassenbauverfahren VALUES('Oberirdische Verlegung');
	INSERT INTO enum_trassenbauverfahren VALUES('Sonstige');

CREATE TABLE enum_trasse_oberflaeche (val TEXT PRIMARY KEY);
	INSERT INTO enum_trasse_oberflaeche VALUES('Unbefestigt');
	INSERT INTO enum_trasse_oberflaeche VALUES('Kleinpflaster');
	INSERT INTO enum_trasse_oberflaeche VALUES('Naturstein/Kopfsteinpflaster');
	INSERT INTO enum_trasse_oberflaeche VALUES('Grosspflaster/Platten');
	INSERT INTO enum_trasse_oberflaeche VALUES('Verbundpflaster');
	INSERT INTO enum_trasse_oberflaeche VALUES('Asphalt/Beton Gehweg,Radweg');
	INSERT INTO enum_trasse_oberflaeche VALUES('Asphalt/Beton Fahrbahn (Strasse)');
	INSERT INTO enum_trasse_oberflaeche VALUES('Sonstige Oberflaechen/unbekannt');

CREATE TABLE enum_kabel_typ (val TEXT PRIMARY KEY);
	INSERT INTO enum_kabel_typ VALUES('Kabel');
	INSERT INTO enum_kabel_typ VALUES('Patch-Kabel');


CREATE TABLE enum_rohr_typ (val TEXT PRIMARY KEY);
	INSERT INTO enum_rohr_typ VALUES('Rohrverband');
	INSERT INTO enum_rohr_typ VALUES('Einzelrohr');
	INSERT INTO enum_rohr_typ VALUES('Arial-Kabel-Path');

CREATE TABLE enum_knoten_typ (val TEXT PRIMARY KEY);
	INSERT INTO enum_knoten_typ VALUES('Schacht');
	INSERT INTO enum_knoten_typ VALUES('Kabinet');
	INSERT INTO enum_knoten_typ VALUES('Gebaeude');
	INSERT INTO enum_knoten_typ VALUES('Pole (Stange) / Wall(Wand)');
	INSERT INTO enum_knoten_typ VALUES('Lage');

CREATE TABLE enum_knoten_subtyp (val TEXT PRIMARY KEY);
	INSERT INTO enum_knoten_subtyp VALUES('Backbone-Uebergabepunkt');
	INSERT INTO enum_knoten_subtyp VALUES('POP');
	INSERT INTO enum_knoten_subtyp VALUES('Mini-POP/MFG');
	INSERT INTO enum_knoten_subtyp VALUES('GF_NVT');
	INSERT INTO enum_knoten_subtyp VALUES('KVZ');
	INSERT INTO enum_knoten_subtyp VALUES('Abschlusspunkt');
	INSERT INTO enum_knoten_subtyp VALUES('Lage, zugaenglich mit einem Kugelmarker');
	INSERT INTO enum_knoten_subtyp VALUES('Lage ohne Kugelmarker');
	INSERT INTO enum_knoten_subtyp VALUES('Ziehschacht / Schacht an grossen Knotenpunkten');

CREATE TABLE enum_connmodule_typ (val TEXT PRIMARY KEY);
	INSERT INTO enum_connmodule_typ VALUES('Muffe');
	INSERT INTO enum_connmodule_typ VALUES('Board');
	INSERT INTO enum_connmodule_typ VALUES('Switch / Plugin');

CREATE TABLE enum_vertriebsstatus (val TEXT PRIMARY KEY);
	INSERT INTO enum_vertriebsstatus VALUES('Kein Vertrag');
	INSERT INTO enum_vertriebsstatus VALUES('Vertrag inkl. GEE');
	INSERT INTO enum_vertriebsstatus VALUES('Vertrag,GEE ausstehend');
	
CREATE TABLE enum_faserconn (val TEXT PRIMARY KEY);
	INSERT INTO enum_faserconn VALUES('Spleisser');
	INSERT INTO enum_faserconn VALUES('ST connector');
	INSERT INTO enum_faserconn VALUES('SC connector');
	INSERT INTO enum_faserconn VALUES('LC connector');
	INSERT INTO enum_faserconn VALUES('FCPC Connector');
	INSERT INTO enum_faserconn VALUES('Lx.5 Connector');
	INSERT INTO enum_faserconn VALUES('MU Connector');
	INSERT INTO enum_faserconn VALUES('MTRJ Connector');
	INSERT INTO enum_faserconn VALUES('MTP/MPO Connector');
	INSERT INTO enum_faserconn VALUES('E2000 Connector');
	INSERT INTO enum_faserconn VALUES('ESCON connector');
	INSERT INTO enum_faserconn VALUES('FDDI connector');
	INSERT INTO enum_faserconn VALUES('Kupfer Connector');
	INSERT INTO enum_faserconn VALUES('Shutter');
	INSERT INTO enum_faserconn VALUES('Nicht angegeben');

CREATE TABLE enum_connelement_typ (val TEXT PRIMARY KEY);
	INSERT INTO enum_connelement_typ VALUES('Passive');
	INSERT INTO enum_connelement_typ VALUES('Active');
	INSERT INTO enum_connelement_typ VALUES('Totes_Ende');

CREATE TABLE enum_connelement_subtyp (val TEXT PRIMARY KEY);
	INSERT INTO enum_connelement_subtyp VALUES('Splitter-Kassette/Box');
	INSERT INTO enum_connelement_subtyp VALUES('Spleiss-Kassette/Box');
	INSERT INTO enum_connelement_subtyp VALUES('Splitter');
	INSERT INTO enum_connelement_subtyp VALUES('Switch / Plugin');

CREATE TABLE enum_abschlusspunkte_typ (val TEXT PRIMARY KEY);
	INSERT INTO enum_abschlusspunkte_typ VALUES('Gf-HUEP');
	INSERT INTO enum_abschlusspunkte_typ VALUES('CU-APL');
	INSERT INTO enum_abschlusspunkte_typ VALUES('Curb / DSLAM');

CREATE TABLE enum_abschlusspunkte_einbauort (val TEXT PRIMARY KEY);
	INSERT INTO enum_abschlusspunkte_einbauort VALUES('Keller');
	INSERT INTO enum_abschlusspunkte_einbauort VALUES('Obergeschoss');
	INSERT INTO enum_abschlusspunkte_einbauort VALUES('Erdgeschoss');
	INSERT INTO enum_abschlusspunkte_einbauort VALUES('Ausserhalb des Gebaeudes');

CREATE TABLE enum_abschlusspunkte_status (val TEXT PRIMARY KEY);
	INSERT INTO enum_abschlusspunkte_status VALUES('1 - nicht geplant');
	INSERT INTO enum_abschlusspunkte_status VALUES('2 - bestellbar');
	INSERT INTO enum_abschlusspunkte_status VALUES('3 - bestellt');
	INSERT INTO enum_abschlusspunkte_status VALUES('4 - inRealisierung');
	INSERT INTO enum_abschlusspunkte_status VALUES('5 - Rohrabgeschlossen');
	INSERT INTO enum_abschlusspunkte_status VALUES('6 - fertig angeschlossen');
	INSERT INTO enum_abschlusspunkte_status VALUES('A - Passed Plus');
	
CREATE TABLE enum_produkt_rohr_typ (val TEXT PRIMARY KEY);
	INSERT INTO enum_produkt_rohr_typ VALUES ('Rohrverband');
	INSERT INTO enum_produkt_rohr_typ VALUES ('Einzelrohr');
	INSERT INTO enum_produkt_rohr_typ VALUES ('Schutzrohr');

CREATE TABLE enum_farbe (val TEXT PRIMARY KEY, farbe varchar(25));/*DIN 47002*/
	INSERT INTO enum_farbe VALUES ('rt','rot');
	INSERT INTO enum_farbe VALUES ('gn','gruen');
	INSERT INTO enum_farbe VALUES ('bl','blau');
	INSERT INTO enum_farbe VALUES ('ge','gelb');
	INSERT INTO enum_farbe VALUES ('ws','weiss');
	INSERT INTO enum_farbe VALUES ('gr','grau');
	INSERT INTO enum_farbe VALUES ('br','braun');
	INSERT INTO enum_farbe VALUES ('vi','violett');
	INSERT INTO enum_farbe VALUES ('tk','tuerkis');
	INSERT INTO enum_farbe VALUES ('sw','schwarz');
	INSERT INTO enum_farbe VALUES ('or','orange');
	INSERT INTO enum_farbe VALUES ('rs','rosa');
	--INSERT INTO enum_farbe VALUES ('l,'');----('lila');


CREATE TABLE enum_bundesland (val TEXT PRIMARY KEY, abkuertzung varchar(50), _epsg_code varchar(5));
alter table enum_bundesland add constraint fk_bundesland_epsg foreign key (_epsg_code) references enum_epsg (val) on update cascade;
	INSERT INTO enum_bundesland VALUES ('Berlin', 'br', '25833');
	INSERT INTO enum_bundesland VALUES ('Brandenburg', 'bb', 25833);
	INSERT INTO enum_bundesland VALUES ('Sachsen-Anhalt', 'st', 25832);
	


CREATE TABLE enum_status_nvt (val TEXT PRIMARY KEY);
	Insert into enum_status_nvt values('unplanned');
	Insert into enum_status_nvt values('planned');
	Insert into enum_status_nvt values('under construction');
	Insert into enum_status_nvt values('finished');


CREATE TABLE enum_status_ap (val TEXT PRIMARY KEY);
	Insert into enum_status_ap values('unplanned');
	Insert into enum_status_ap values('planned');
	Insert into enum_status_ap values('orderable');
	Insert into enum_status_ap values('ordered');
	Insert into enum_status_ap values('underConstruction');
	Insert into enum_status_ap values('ductOpen');
	Insert into enum_status_ap values('ductConnected');
	Insert into enum_status_ap values('cableInside');
	Insert into enum_status_ap values('connected');
	Insert into enum_status_ap values('passed');



CREATE TABLE enum_adressen_verifizierungstyp (val TEXT PRIMARY KEY);
	INSERT INTO enum_adressen_verifizierungstyp VALUES('amtlich');
	INSERT INTO enum_adressen_verifizierungstyp VALUES('vertrieb');
	INSERT INTO enum_adressen_verifizierungstyp VALUES('extern');
	INSERT INTO enum_adressen_verifizierungstyp VALUES('DNS-Net/Plannung');
	INSERT INTO enum_adressen_verifizierungstyp VALUES('unsicher'); 
	
CREATE TABLE enum_adressen_analysiert_durch (val TEXT PRIMARY KEY);
	INSERT INTO enum_adressen_analysiert_durch VALUES('COMSOF');
	INSERT INTO enum_adressen_analysiert_durch VALUES('AND');
	INSERT INTO enum_adressen_analysiert_durch VALUES('TKI');

CREATE TABLE enum_adressen_foerder_status (val TEXT PRIMARY KEY);
	INSERT INTO enum_adressen_foerder_status VALUES('weisse-Flecke');
	INSERT INTO enum_adressen_foerder_status VALUES('graue-Flecke');
	INSERT INTO enum_adressen_foerder_status VALUES('schwarze-Felcke');
