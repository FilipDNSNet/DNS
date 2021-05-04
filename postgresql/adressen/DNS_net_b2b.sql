-- 08-04-2021
-- A CSV File is given. it contains the adresses of companies. It is from Gemeinde. 
-- Our task is to give the adresses Geometry and vid.
-- Each row corresponds to a company which can be match with more than one adress.  E.G. ABCstr. 5-7


--------   create a temporaray table

create table temp.b2b(
	adress_id	integer,
	anrede	text,
	namenszeile	text,
	namenszeile_1	text,
	namenszeile_2	text,
	namenszeile_3	text,
	plz	text,
	ort	text,
	ortsteil	text,
	strasse	text,
	hausnummer	text,
	vorwahl_telefon	text,
	telefonnummer	text,
	e_mail_adresse	text,
	anzahl_mitarbeiter_klassen	text,
	beschaeftigtenzahl	integer,
	entscheider_1_anrede	text,
	entscheider_1_titel	text,
	entscheider_1_vorname	text,
	entscheider_1_nachname	text,
	entscheider_1_funktionsnummer	text,
	entscheider_1_funktionsname	text
);
create index inx_temp_b2b_hausnummer on  temp.b2b(hausnummer);


--- Import the csv-file

\copy temp.b2b from 'C:\Users\Hamed Sayidi\Desktop\adressen_b2b\b2b.csv' WITh Delimiter ';' csv Header;





adress_id, anrede, namenszeile, namenszeile_1, namenszeile_2, namenszeile_3, plz, ort, ortsteil, strasse, hausnummer, vorwahl_telefon, telefonnummer, e_mail_adresse, anzahl_mitarbeiter_klassen, beschaeftigtenzahl     , entscheider_1_anrede     , entscheider_1_titel, entscheider_1_vorname, entscheider_1_nachname, entscheider_1_funktionsnummer, entscheider_1_funktionsname










------------           UNIFY THE HAUSNR:

-- check if the data is clean.- howmany null value is in the haus nr.  how are the cases :  1-5   2/3  6a/b   3/5/9

-- Case 1  
select hausnummer from temp.b2b where hausnummer like '%-%';--265

Do $$
DECLARE
	cur_adress_id integer;
	cur_hausnummer text;
	sum integer:=0;
	sum2 integer:=0;
	von integer;
	bis integer;
	i integer;
BEGIN
	for von, bis, cur_adress_id, cur_hausnummer in 
		(select range[1]::integer  , range[2]::integer  , sel.adress_id , sel.hausnummer from ( 
				select regexp_split_to_array(temp.b2b.hausnummer,'-') as range,* from temp.b2b where temp.b2b.hausnummer like '%-%'
			) sel
		) Loop
		raise notice 'von % , bis % , adress_id: %',von, bis, cur_adress_id;
		select sum+bis-von+1 into sum;
		for i in von..bis loop
			raise notice E'\t %',i;
			insert into temp.b2b(adress_id, anrede, namenszeile, namenszeile_1, namenszeile_2, namenszeile_3, plz, ort, ortsteil, strasse, hausnummer, vorwahl_telefon, telefonnummer, e_mail_adresse, anzahl_mitarbeiter_klassen, beschaeftigtenzahl     , entscheider_1_anrede     , entscheider_1_titel, entscheider_1_vorname, entscheider_1_nachname, entscheider_1_funktionsnummer, entscheider_1_funktionsname) 
				select temp.b2b.adress_id, anrede, namenszeile, namenszeile_1, namenszeile_2, namenszeile_3, plz, ort, ortsteil, strasse, i::text, vorwahl_telefon, telefonnummer, e_mail_adresse, anzahl_mitarbeiter_klassen, beschaeftigtenzahl     , entscheider_1_anrede     , entscheider_1_titel, entscheider_1_vorname, entscheider_1_nachname, entscheider_1_funktionsnummer, entscheider_1_funktionsname
					from temp.b2b where temp.b2b.adress_id=cur_adress_id LIMIT 1;
		end loop;
		select 1 + sum2 into sum2;
		delete from temp.b2b where temp.b2b.adress_id= cur_adress_id and temp.b2b.hausnummer=cur_hausnummer;
	end loop;
	raise notice 'Total inserted: %  deleted: %', sum, sum2;
END;
$$ Language PLPGSQL;



----- CASE 2
select  hausnummer from temp.b2b where hausnummer like '%/%';--16


Do $$
DECLARE
	cur_adress_id integer;
	cur_hausnummer text;
	arr text[];
	sum1 integer:=0;
	sum2 integer:=0;
	prev_i text;
	i text;
BEGIN
	for arr, cur_adress_id, cur_hausnummer in 
		(
			select regexp_split_to_array(temp.b2b.hausnummer,'/'), adress_id , hausnummer  from temp.b2b where temp.b2b.hausnummer like '%/%'
		) Loop
		raise notice E'adress_id  %  , Hausnr: %',cur_adress_id,cur_hausnummer ;
		select substring(replace(arr[1],' ',''), '[0-9]*') into prev_i;
		foreach i in array arr loop
			select 1 + sum1 into sum1;
			select replace(i,' ', '') into i;
			if substring(i, '[a-z|A-Z]*')<>'' then
				select prev_i||i into i;
			else
				select substring(i, '[0-9]*') into prev_i;
			end if;
			raise notice E'\t %',i;
			insert into temp.b2b(adress_id, anrede, namenszeile, namenszeile_1, namenszeile_2, namenszeile_3, plz, ort, ortsteil, strasse, hausnummer, vorwahl_telefon, telefonnummer, e_mail_adresse, anzahl_mitarbeiter_klassen, beschaeftigtenzahl     , entscheider_1_anrede     , entscheider_1_titel, entscheider_1_vorname, entscheider_1_nachname, entscheider_1_funktionsnummer, entscheider_1_funktionsname) 
				select temp.b2b.adress_id, anrede, namenszeile, namenszeile_1, namenszeile_2, namenszeile_3, plz, ort, ortsteil, strasse, i::text, vorwahl_telefon, telefonnummer, e_mail_adresse, anzahl_mitarbeiter_klassen, beschaeftigtenzahl     , entscheider_1_anrede     , entscheider_1_titel, entscheider_1_vorname, entscheider_1_nachname, entscheider_1_funktionsnummer, entscheider_1_funktionsname
					from temp.b2b where temp.b2b.adress_id=cur_adress_id LIMIT 1;
		end loop;
		select 1 + sum2 into sum2;
		delete from temp.b2b where temp.b2b.adress_id= cur_adress_id and temp.b2b.hausnummer=cur_hausnummer;
	end loop;
	raise notice 'Total inserted: %  deleted: %', sum1, sum2;
END;
$$ Language PLPGSQL;



select * from temp.b2b ;--5331








alter table temp.b2b add column uuid uuid;
alter table temp.b2b add column oid bigserial primary key;


alter table temp.b2b add column ky text;
alter table temp.b2b add column ky_ort text;
alter table temp.b2b add column ky_ortsteil text;
alter table temp.b2b add column ky_ohne_plz text;
Update temp.b2b set ky = dns_adress_match_key_generator( plz ,strasse , hausnummer,  '' , '') ;
Update temp.b2b set ky_ort = dns_adress_match_key_generator( plz ,strasse , hausnummer,  '' , ort) ;
Update temp.b2b set ky_ortsteil = dns_adress_match_key_generator( plz ,strasse , hausnummer,  '' , ortsteil) ;
Update temp.b2b set ky_ohne_plz = dns_adress_match_key_generator( '' ,strasse , hausnummer,  '' , '') ;

alter table temp.b2b add column geom_status text;



-- temporary table:
create table temp.adr (id uuid primary key , ky text, ky_ort text, ky_ortsteil text, ky_ohne_plz text);
create index inx_temp_adr_ky on temp.adr(ky);
create index inx_temp_adr_ky_ort on temp.adr(ky_ort);
create index inx_temp_adr_ky_ortsteil on temp.adr(ky_ortsteil);
create index inx_temp_adr_ky_ohne_plz on temp.adr(ky_ohne_plz);
insert into temp.adr(id,ky,ky_ort, ky_ortsteil,ky_ohne_plz)
	select id,
	dns_adress_match_key_generator(plz ,strasse , hausnr, adresszusatz , '') ,
	dns_adress_match_key_generator(plz ,strasse , hausnr, adresszusatz , ort) ,
	dns_adress_match_key_generator(plz ,strasse , hausnr, adresszusatz , ortsteil) ,
	dns_adress_match_key_generator('' ,strasse , hausnr, adresszusatz , '') 
	from adressen.adressen;
	
----------  Matching:
select oid,adr.id from temp.b2b join temp.adr adr on adr.ky=temp.b2b.ky ;-- 5022
select oid,adr.id from temp.b2b join temp.adr adr on adr.ky_ohne_plz=temp.b2b.ky_ohne_plz; --100368
select oid,adr.id from temp.b2b join temp.adr adr on adr.ky_ort=temp.b2b.ky_ort; --3673
select oid,adr.id from temp.b2b join temp.adr adr on adr.ky_ortsteil=temp.b2b.ky_ortsteil; --2664


update temp.b2b set uuid= sel.id from (
	select oid,adr.id from temp.b2b join temp.adr adr on adr.ky_ort=temp.b2b.ky_ort 
	)sel where temp.b2b.oid=sel.oid;--3673
update temp.b2b set geom_status='Sicher' where uuid is not Null;


update temp.b2b set uuid=sel2.id, geom_status='Unsicher' from (
	select oid,adr.id from temp.b2b join temp.adr adr on adr.ky=temp.b2b.ky where oid in (
			select oid from (
				select oid , count(oid) cnt from 
					(select oid,adr.id from temp.b2b join temp.adr adr on adr.ky=temp.b2b.ky) sel
					group by oid order by cnt desc
			) sel  where cnt =1
		) 
	) sel2 where uuid is null and sel2.oid=temp.b2b.oid;--1178



select * from temp.b2b where uuid is null; --480 not matched

























create table dns_dienste.b2b_selfservice(
	id	bigserial,
	vid	text,
	adress_id	integer,
	anrede	text,
	namenszeile	text,
	namenszeile_1	text,
	namenszeile_2	text,
	namenszeile_3	text,
	plz	text,
	ort	text,
	ortsteil	text,
	strasse	text,
	hausnummer	text,
	vorwahl_telefon	text,
	telefonnummer	text,
	e_mail_adresse	text,
	anzahl_mitarbeiter_klassen	text,
	beschaeftigtenzahl	integer,
	entscheider_1_anrede	text,
	entscheider_1_titel	text,
	entscheider_1_vorname	text,
	entscheider_1_nachname	text,
	entscheider_1_funktionsnummer	text,
	entscheider_1_funktionsname	text,
	uuid	uuid,
	geom_status text,
	geom geometry (point, 4326)
	
	
	constraint pk_dns_dienste_b2b_selfservice primary key (id)
);
create index inx_dns_dienste_b2bselfservice_adress_id on dns_dienste.b2b_selfservice(adress_id);
create index inx_dns_dienste_b2bselfservice_uuid on dns_dienste.b2b_selfservice(uuid);
create index inx_dns_dienste_b2bselfservice_vid on dns_dienste.b2b_selfservice(vid);
create index inx_dns_dienste_b2bselfservice_strasse on dns_dienste.b2b_selfservice(strasse);
create index inx_dns_dienste_b2bselfservice_plz on dns_dienste.b2b_selfservice(plz);
create index inx_dns_dienste_b2bselfservice_adress_hausnummer on dns_dienste.b2b_selfservice(hausnummer);
create index inx_dns_dienste_b2bselfservice_geom on dns_dienste.b2b_selfservice using GIST(geom);

Alter table dns_dienste.b2b_selfservice add constraint fk_dns_dienste_b2b_selfservice_adresse_id foreign key (adresse_id) references adressen.adressen(id);







insert into dns_dienste.b2b_selfservice(id, vid, adress_id, anrede, namenszeile, namenszeile_1, namenszeile_2, namenszeile_3, plz, ort, ortsteil, strasse, hausnummer, vorwahl_telefon, telefonnummer, e_mail_adresse, anzahl_mitarbeiter_klassen, beschaeftigtenzahl     , entscheider_1_anrede     , entscheider_1_titel, entscheider_1_vorname, entscheider_1_nachname, entscheider_1_funktionsnummer, entscheider_1_funktionsname, uuid, geom_status, geom)
	select oid, null, adress_id, anrede, namenszeile, namenszeile_1, namenszeile_2, namenszeile_3, plz, ort, ortsteil, strasse, hausnummer, vorwahl_telefon, telefonnummer, e_mail_adresse, anzahl_mitarbeiter_klassen, beschaeftigtenzahl     , entscheider_1_anrede     , entscheider_1_titel, entscheider_1_vorname, entscheider_1_nachname, entscheider_1_funktionsnummer, entscheider_1_funktionsname, uuid, geom_status, null
		from temp.b2b;
		
update dns_dienste.b2b_selfservice set geom =ad.geom, vid=ad.vid from adressen.adressen ad where ad.id=dns_dienste.b2b_selfservice.uuid;


drop table temp.b2b;
drop table temp.adr;