-- Data from Micha to match with adressen.adressen 18-05-2021


create table immobilienwirtschaft.glasfaseranbindung_berlin (
	lfd text
	,objekt_kuerzel text
	,strasse text
	,plz text
	,ort text
	,hausverwaltung text
	,eigentuemergesellschaft text
	,unbebautes_grundstueck text
	,projekt_entwicklung text
	,greystay text
	,glasfaser_anschluss_vorhanden text
	,aufgaenge integer
	,geschosse integer
	,we integer
	,ge integer
	,ne_gesamt integer
	,flaeche_we numeric
	,flaeche_ge numeric
	,gesamt_flaeche numeric
);  
--------------------------------------------
--import from csv:
	\copy immobilienwirtschaft.glasfaseranbindung_berlin from 'C:\Users\Hamed Sayidi\Desktop\Micha_Match-adresse\objektuebersicht_berlin_projekt_glasfaseranbindung_v01.csv' WITh Delimiter ';' csv Header;
--------------------------------------------

alter table immobilienwirtschaft.glasfaseranbindung_berlin
	add column id serial;
alter table immobilienwirtschaft.glasfaseranbindung_berlin
	add constraint pk_immobilienwirtschaft_glasfaseranbindung_berlin
		primary key (id);
alter table immobilienwirtschaft.glasfaseranbindung_berlin 
	add column ky_1 text;
create index inx_immobilienwirtschaft_glasfaseranbindung_berlin_ky1 on immobilienwirtschaft.glasfaseranbindung_berlin(ky_1);
alter table immobilienwirtschaft.glasfaseranbindung_berlin 
	add column ky_2 text;	
create index inx_immobilienwirtschaft_glasfaseranbindung_berlin_ky2 on immobilienwirtschaft.glasfaseranbindung_berlin(ky_2);
update immobilienwirtschaft.glasfaseranbindung_berlin
	set ky_1=dns_adress_match_key_generator( plz,strasse , '', '' , ort);
update immobilienwirtschaft.glasfaseranbindung_berlin
	set ky_2=dns_adress_match_key_generator( '',strasse , '', '' , ort);	
alter table immobilienwirtschaft.glasfaseranbindung_berlin add column alkis_id text;
create index inx_immobilienwirtschaft_glasfaseranbindung_berlin_alkisid on immobilienwirtschaft.glasfaseranbindung_berlin(alkis_id);
alter table immobilienwirtschaft.glasfaseranbindung_berlin add column vid text;
create index inx_immobilienwirtschaft_glasfaseranbindung_berlin_vid	on  immobilienwirtschaft.glasfaseranbindung_berlin(vid);
alter table immobilienwirtschaft.glasfaseranbindung_berlin add column geom geometry(POINT,4326);
create index inx_immobilienwirtschaft_glasfaseranbindung_berlin_geom on immobilienwirtschaft.glasfaseranbindung_berlin using GIST(geom);
	


-- narrow down adressen.adressen
drop table temp;
create table temp as 
	select * from adressen.adressen where ort in
		(select distinct ort from  immobilienwirtschaft.glasfaseranbindung_berlin)
		or bundesland='Berlin';
update temp set ort='Berlin' where bundesland='Berlin' and ort is null;
alter table temp add constraint pk_temp primary key (id);
alter table temp add column ky_1 text;
create index inx_temp on temp(ky_1);
alter table temp add column ky_2 text;
create index inx_temp_ky_2 on temp(ky_2);
update temp  set ky_1=dns_adress_match_key_generator( plz,strasse , hausnr, adresszusatz , ort);
update temp  set ky_2=dns_adress_match_key_generator( '',strasse , hausnr, adresszusatz , ort);-- ohne plz

select temp.ky_1, nw.ky_1 newky from temp join immobilienwirtschaft.glasfaseranbindung_berlin nw on temp.ky_1=nw.ky_1 ;

update immobilienwirtschaft.glasfaseranbindung_berlin set alkis_id=sel.alkis_id ,vid= sel.vid , geom=sel.geom 
	from (select temp.vid, temp.alkis_id, temp.geom, nw.id from temp join immobilienwirtschaft.glasfaseranbindung_berlin nw on temp.ky_1=nw.ky_1)sel
		where sel.id=immobilienwirtschaft.glasfaseranbindung_berlin.id;

###########################################################
-- now match without PLZ
select temp.ky_1, nw.ky_1 newky from temp join immobilienwirtschaft.glasfaseranbindung_berlin nw on temp.ky_2=nw.ky_2 where nw.alkis_id is null;

update immobilienwirtschaft.glasfaseranbindung_berlin set alkis_id=sel.alkis_id ,vid= sel.vid , geom=sel.geom 
	from (select temp.vid, temp.alkis_id, temp.geom, nw.id from temp join immobilienwirtschaft.glasfaseranbindung_berlin nw on temp.ky_2=nw.ky_2 where nw.alkis_id is null)sel
		where sel.id=immobilienwirtschaft.glasfaseranbindung_berlin.id;

###################################################
-- now control manually:
select ky_1 from immobilienwirtschaft.glasfaseranbindung_berlin where alkis_id is  null

ky_1
1	seibnitz01855langestr1
2	seibnitz01855langestr3
3	berlin10245ehemmarkgrafendamm24a
3	berlin10245ehemmarkgrafendamm24a
4	berlin10245krossenerstr5
5	berlin10245krossenerstr6
7	berlin10317kynaststr25
8	berlin10365kietzerweg09
9	berlin14195koserstr9
10	berlin14195koserstr10
11	forst03149thumstr3
12	berlin14195koserstr11
13	görtlitz02826salomonstr41
14	forst03149bahnhofstr33
15	potsdam14467brandenburgischestr60a
16	potsdam14542maulbeerweg(derwitzerfeld)









