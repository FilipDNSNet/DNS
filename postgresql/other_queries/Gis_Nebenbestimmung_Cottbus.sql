drop table "Bauten_und_Netztechnik";
CREATE TABLE "Bauten_und_Netztechnik" ("ART" integer, "Art_Sonst" text, "Zustand" integer , "Bezeichner" Text, "ID" integer , "ID_Tech" integer, geom geometry(POINT,4258));
insert into "Bauten_und_Netztechnik" 
	select 
		case when typ='Schacht' then 3
				when subtyp in ('GF_NVT', 'KVZ')  then 2
				when subtyp='Abschlusspunkt' then 4
				when subtyp='Backbone-Uebergabepunkt' then 5
				when subtyp='Mini-POP/MFG' then 6
				when subtyp='POP' then 1
		end Art
		, Null Art_Sonst
		, 1 zustand
		, Null Bezeichner
		, id ID 
		, Null::int ID_Tech
		, st_transform(geom, 4258)
	 from comsof.knoten where typ not in ('Lage', 'Pole (Stange) / Wall(Wand)')
	 
 
 
 
 
 
 
 
 
CREATE TABLE  "Trassenbau" ("ID" serial , "Mitverleg" integer , "E_FName" text, geom geometry(geometry, 4258) );

insert into "Trassenbau" ("E_FName", geom ) select 'DNS:NET'  , st_transform(geom, 4258) from prj_cottbus.trasse;









select 
	CASE 
		when r.anzahl_microducts=1 then 6
		when r.anzahl_microducts=4 then 11
		when r.anzahl_microducts=12 then 14
		when r.anzahl_microducts=24 then 14
	END LR_art
	, Null LR_Sonst
	, r.anzahl_microducts LR_Anzahl 
	, case 
		when r.typ='Rohrverband' then (select count(*)+1 from comsof.rohr r1 where st_equals(r1.geom , r.geom) and r1.id<>r.id ) 
		else 1
	End Anzahl
	, (select count(*) from comsof.microduct m where m.rohr_id=r.id and m.kabel_id is null)  as  LR_Reserv
	,st_length(st_transform(geom,4258), false) Lae_LR
from comsof.rohr r order by Lae_LR desc











CREATE TABLE "Leerrohre" ("ID" SERIAL , "LR_Art" integer, "LR_Sonst" Text, "LR_Anzahl" integer, "Anzahl" integer, "LR_Reserv" integer , "Lae_LR" numeric, geom geometry(GEOMETRY, 4258) );

insert into "Leerrohre" ("LR_Art" , "LR_Sonst", "LR_Anzahl",  "Anzahl" ,  "LR_Reserv",  "Lae_LR", geom )
	select 
		CASE 
			when r.anzahl_microducts=1 then 6
			when r.anzahl_microducts=4 then 11
			when r.anzahl_microducts=12 then 14
			when r.anzahl_microducts=24 then 14
		END LR_art
		, Null LR_Sonst
		, r.anzahl_microducts LR_Anzahl 
		, case 
			when r.typ='Rohrverband' then (select count(*)+1 from comsof.rohr r1 where st_equals(r1.geom , r.geom) and r1.id<>r.id ) 
			else 1
		End Anzahl
		, (select count(*) from comsof.microduct m where m.rohr_id=r.id and m.kabel_id is null)  as  LR_Reserv
		, round(st_length(st_transform(geom,4258), false) ::numeric,1) Lae_LR
		, st_transform(geom,4258)
	from comsof.rohr r 

	union all 
		
	select 
		1 LR_art
		, Null LR_Sonst
		, null LR_Anzahl 
		, Null Anzahl
		, Null  LR_Reserv
		, round(st_length(st_transform(geom,4258), false) ::numeric ,1) Lae_LR
		, st_transform(geom,4258)
	from comsof.schutzrohr;

	
	








CREATE TABLE "Verbindungen" ("Verb_Art" integer, "V_A_Sonst" text, "Lae_Kabel" numeric , "Anzahl_F_A" integer , "F_A_Reserv" integer, "Zustand" integer, geom geometry (GEOMETRY, 4258));

insert into  "Verbindungen"  ("Verb_Art" , "V_A_Sonst" , "Lae_Kabel"  , "Anzahl_F_A"  , "F_A_Reserv" , "Zustand" , geom)
	select 
		CASE 
			when anzahl_fasern=12 then 6
			when anzahl_fasern=24 then 7
			when anzahl_fasern=48 then 8
			when anzahl_fasern=144 then 11
		END Verb_Art,
		Null V_A_Sonst,
		round(st_length(st_transform(geom,4258), false) ::numeric ,1) Lae_Kabel,
		NULL Anzahl_F_A,
		NULL F_A_Reserv,
		1 Zustand,
		st_transform(geom, 4258)
	from comsof.kabel