------  Task from Michael on adresses
----		
----		1.	Erweiterung der Nexigatabelle (in postgres)
----			a.	X:\Geodaten\04_Deutschland\Adressen_nexiga\DNSNT210609_KGS44_DATEN_994POLYGONE
----		2.	Angaben LCHH und ANZ_FA von erweiterter nexiga Tabelle auf adressen übertragen
----			i.	Where anzahl_wohneinheit = 0 oder NULL
----			ii.	Where anzahl_gewerbeeinheit = 0 oder Null
----		3.	Spalte anzahl_ wohneinheit in Tabelle adressen ergänzen – where funktion = Wohngebäude and anzahl_ wohneinheit = 0 oder NULL  insert   anzahl_ wohneinheit = 1
----		4.	Spalte anzahl_ gewerbeeinheit in Tabelle adressen ergänzen – where funktion = Gewerbe and anzahl_ gewerbeeinheit = 0 oder NULL  insert   anzahl_ gewerbeeinheit = 1
----		5.	Spalte anzahl_ nutzeinheit in Tabelle adressen ergänzen – where anzahl_nutzeinheit =0 oder Null
----			a.	Where anzahl_ wohneinheit = 1 and anzahl_ gewerbeeinheit = 1   insert anzahl_nutzeinheit = 1   ansonsten gilt anzahl_ wohneinheit + anzahl_gewerbeeinheit = anzahl_ nutzeinheit
----		
------ There is a file in which there are some new rows of Nexiga adreses.
------ first we needed to load the tata into database, then insert the new rows to existing Nexiga adresses. For these new we match them with adressen.adressen. Then we made some updates on the WE/GE/NE.
----16.02.2020



create table shp.ext_nexiga (
	V_LFD                   text,
	PLZ                     text,
	PO_NAME                 text,
	POT_NAME                text,
	STR_NAME                text,
	HNR                     text,
	HNR_ZS                  text,
	HNR_KOMPL               text,
	KGS8                    text,
	KGS44                   text,
	HIS                     text,
	OI                      text,
	BOF_X_ETRSUTM32         text,
	BOF_Y_ETRSUTM32         text,
	BOF_KENN                text,
	LCHH                    text,
	ANZ_FA                  text,
	DT_TECH                 text,
	DT_DAT                  text,
	DT_DOWN                 text,
	DT_UP                   text,
	KD_TECH                 text,
	KD_DAT                  text,
	KD_DOWN                 text,
	KD_UP                   text );

--    =>   Check the encoding.if it is UTF-8 and has problem with Umlauts, => save as the scv file to another scv file with different encoding, e.g. ANSI

-- import csv
\copy shp.ext_nexiga from 'C:\Users\Hamed Sayidi\Desktop\00_nexiga_extension\DNSNT210609_KGS44_DATEN_994POLYGONE.csv' WITh Delimiter ';' csv Header; 

select fid from adressen.adressen_nexiga_wgs84_v2 order by fid desc

--add column fid :
alter table shp.ext_nexiga add column fid serial;
update shp.ext_nexiga set fid= fid+1320346;-- solve the problem of unique fid when we wnat to append to adressen_nexiga
alter table shp.ext_nexiga add constraint pk_shp_ext_nexiga primary key (fid);
-- add column geometry:
alter table shp.ext_nexiga add column geom geometry(POINT, 4326);
update shp.ext_nexiga set geom=st_transform(  st_setsrid(st_point(replace(bof_x_etrsutm32,',','.')::numeric,replace(bof_y_etrsutm32,',','.')::numeric),25832)   , 4326) ;

insert into adressen.adressen_nexiga_wgs84_v2  (fid,geom,v_lfd,plz,po_name,pot_name,str_name,hnr,hnr_zs,hnr_kompl,kgs8,kgs44,his,oi,bof_x_etrs,bof_y_etrs,bof_kenn,lchh,anz_fa,dt_tech,dt_dat,dt_down,dt_up,kd_tech,kd_dat,kd_down,kd_up)
 select fid,geom,v_lfd,plz,po_name,pot_name,str_name,hnr,hnr_zs,hnr_kompl,kgs8,kgs44,his,oi,bof_x_etrsutm32,bof_y_etrsutm32,bof_kenn,lchh::int,anz_fa::int,dt_tech,dt_dat,dt_down,dt_up,kd_tech,kd_dat,kd_down,kd_up 
	from shp.ext_nexiga;
	
-- mattch with adressen.adressen:
update adressen.adressen_nexiga_wgs84_v2 set
	dns_adr_id=adressen.adressen.id
	,vid=adressen.adressen.vid
	,typ=adressen.adressen.typ
	,ortsnetzb=adressen.adressen.ortsnetzbereiche
	,gemeinde_=adressen.adressen.gemeinde_name
	,gemeind_1=adressen.adressen.gemeinde_schluessel
	,amtname=adressen.adressen.amtname
	,bundeslan=adressen.adressen.bundesland
	,kreis=adressen.adressen.kreis
	,kreis_nr=adressen.adressen.kreis_nr
	,bezirk=adressen.adressen.bezirk
	,bezirk_nr=adressen.adressen.bezirk_nr
	,ort=adressen.adressen.ort
	,ortsteil=adressen.adressen.ortsteil
	,ortsteil_=adressen.adressen.ortsteil_nr
	,_plz=adressen.adressen.plz
	,strasse=adressen.adressen.strasse
	,psn=adressen.adressen.psn
	,strassens=adressen.adressen.strassenschluessel
	,hausnr=adressen.adressen.hausnr
	,adresszus=adressen.adressen.adresszusatz
	,blk=adressen.adressen.blk
	,funktion=adressen.adressen.funktion
	,funktion_=adressen.adressen.funktion_kategorie
	,anzahl_wo=adressen.adressen.anzahl_wohneinheit
	,anzahl_ge=adressen.adressen.anzahl_gewerbeeinheit
	,anzahl_nu=adressen.adressen.anzahl_nutzeinheit
	,aufnahmed=adressen.adressen.aufnahmedatum
	,adresse_c=adressen.adressen.adresse_checked
	,ne_checke=adressen.adressen.ne_checked
	,datum_adr=adressen.adressen.datum_adresse_checked
	,datum_ne_=adressen.adressen.datum_ne_checked
	,qualitaet=adressen.adressen.qualitaet
	,adresse_s=adressen.adressen.adresse_status
	,_epsg_cod=adressen.adressen._epsg_code
	,_x=adressen.adressen._x
	,_y=adressen.adressen._y
	,_z=adressen.adressen._z
	from adressen.adressen where adressen.adressen.alkis_id=adressen.adressen_nexiga_wgs84_v2.oi and adressen.adressen_nexiga_wgs84_v2.fid>1320347;
	
	
-- from new adresses. update NE Ge adressn.adressn where they are old
update adressen.adressen adr set anzahl_wohneinheit=adressen.adressen_nexiga_wgs84_v2.lchh 
	from adressen.adressen_nexiga_wgs84_v2 where adressen.adressen_nexiga_wgs84_v2.fid>1320347
	and adr.id=uuid(dns_adr_id) and (adr.anzahl_wohneinheit=0 or adr.anzahl_wohneinheit is null);

	
update adressen.adressen adr set anzahl_gewerbeeinheit=adressen.adressen_nexiga_wgs84_v2.anz_fa
	from adressen.adressen_nexiga_wgs84_v2 where adressen.adressen_nexiga_wgs84_v2.fid>1320347
	and adr.id=uuid(dns_adr_id) and (adr.anzahl_gewerbeeinheit=0 or adr.anzahl_gewerbeeinheit is null);	
	
-- Update adressen.adressen
update adressen.adressen adr set anzahl_wohneinheit=1 where adr.funktion='Wohngebäude' and  (adr.anzahl_wohneinheit=0 or adr.anzahl_wohneinheit is null); -- 417 cases

update adressen.adressen adr set anzahl_gewerbeeinheit =1 where adr.funktion='Gewerbe' and  (adr.anzahl_gewerbeeinheit=0 or adr.anzahl_gewerbeeinheit is null);-- empty??

update adressen.adressen  set anzahl_nutzeinheit=1 where (anzahl_nutzeinheit=0 or anzahl_nutzeinheit is null) and anzahl_wohneinheit=1 and anzahl_gewerbeeinheit=1;--17414

update adressen.adressen  set anzahl_nutzeinheit=coalesce(anzahl_wohneinheit,0)+coalesce(anzahl_gewerbeeinheit,0) where (anzahl_nutzeinheit=0 or anzahl_nutzeinheit is null) ;-- 614061


------------------------------------------------------------------------------------------------
-- override adressen_nexiga_wgs84

create table bk.adressen_adressen_nexiga_wgs84_17_02_2021 as select * from adressen.adressen_nexiga_wgs84



drop table adressen.adressen_nexiga_wgs84;
create table adressen.adressen_nexiga_wgs84 as select * from adressen.adressen_nexiga_wgs84_v2;
alter table adressen.adressen_nexiga_wgs84 add constraint pk_adressen_adressen_nexiga_wgs84 primary key(fid);
create index inx_adressen_adressen_nexiga_wgs84_geom      on adressen.adressen_nexiga_wgs84 using GIST(geom);
create index inx_adressen_adressen_nexiga_wgs84_plz      on adressen.adressen_nexiga_wgs84 (plz);
create index inx_adressen_adressen_nexiga_wgs84_po_name      on adressen.adressen_nexiga_wgs84 (po_name);
create index inx_adressen_adressen_nexiga_wgs84_pot_name     on adressen.adressen_nexiga_wgs84 (pot_name);
create index inx_adressen_adressen_nexiga_wgs84_str_name      on adressen.adressen_nexiga_wgs84 (str_name);
create index inx_adressen_adressen_nexiga_wgs84_kgs8      on adressen.adressen_nexiga_wgs84 (kgs8);
create index inx_adressen_adressen_nexiga_wgs84_oi      on adressen.adressen_nexiga_wgs84 (oi);
create index inx_adressen_adressen_nexiga_wgs84_his      on adressen.adressen_nexiga_wgs84 (his);
create index inx_adressen_adressen_nexiga_wgs84_dns_adr_id     on adressen.adressen_nexiga_wgs84 (dns_adr_id);
create index inx_adressen_adressen_nexiga_wgs84_vid      on adressen.adressen_nexiga_wgs84 (vid);


drop adressen.adressen_nexiga_wgs84_v2;



----  delete some adresses. they are attributive duplication. with the same "his" value but wrong geometries.
delete from adressen.adressen_nexiga_wgs84 where fid in (1039812, 367854, 609542, 345361);

