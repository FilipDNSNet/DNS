-- Task: new strategy for monitoring(überwachung)
-- adding new status :  status_hp to abschlusspunkte
-- createion of two new tables :
		adressen.nvts
		adressen.nvt_eingangen_ausgangen
		
create table adressen.nvts (
	id uuid,
	ext_id text,
	typ text,
	bez text Not Null,
	projekt text,
	cluster text,
	db_cluster integer,
	versorgt_von text,
	bundesland text,
	kreis text,
	gemeinde text,
	geom geometry(POINT, 4326)
);
alter table adressen.nvts add constraint pk_adressen_nvts primary key (id);
alter table adressen.nvts add constraint fk_adressen_db_cluster foreign key (db_cluster) references _cluter(id) on update cascade;
alter table adressen.nvts add constraint fk_adressen_bundesland foreign key (bundesland) references enum_bundesland on update cascade;
create index inx_adressen_nvts_ext_id on adressen.nvts(ext_id);
create index inx_adressen_nvts_cluster on adressen.nvts(cluster);
create index inx_adressen_nvts_versorgt_von on adressen.nvts(versorgt_von);
create index inx_adressen_nvts_geom on adressen.nvts using GIST(geom);




create or replace function tr_adressen_nvt_before_upin() returns trigger as $$
DECLARE
		t boolean :=False;
BEGIN
	if st_isvalid(new.geom)=True and st_srid(new.geom)='4326' Then
			select True into t;
		end if;
	
	--bundesland :
	if new.bundesland is null AND t
		AND exists (SELECT FROM information_schema.tables WHERE  table_schema='basisdaten' AND table_name='bundeslaender_generalisierte_grenzen')
		THEN
		select bn.gen from basisdaten.bundeslaender_generalisierte_grenzen bn
			where st_contains(bn.geom, new.geom) limit 1 into new.bundesland;
	end if;
	
	----kreis:
	----		Table "basisdaten.zusammengestellten_kreise" is created manually.
	if (new.kreis is Null OR new.kreis_nr is null) 
		AND exists (SELECT FROM information_schema.tables WHERE  table_schema='basisdaten' AND table_name='zusammengestellten_kreise')
		THEN
		if new.kreis_nr is not null then
			select kr_name from basisdaten.zusammengestellten_kreise where kr_nr=new.kreis_nr into new.kreis;
		elsif new.kreis is not Null then
			select kr_nr from basisdaten.zusammengestellten_kreise where kr_name=new.kreis into new.kreis_nr;
		elsif t THEN
			select kr_name, kr_nr from basisdaten.zusammengestellten_kreise pol where st_contains(pol.geom, new.geom) limit 1
				into new.kreis, new.kreis_nr;
		end if;				
	end if;


	
	--Gemeinde:
	----		Table "basisdaten.zusammengestellten_gemeinden" is created manually.
	if (new.gemeinde is Null) 
		AND exists (SELECT FROM information_schema.tables WHERE  table_schema='basisdaten' AND table_name='zusammengestellten_gemeinden')
		THEN
		if new.bundesland in ('Berlin') THEN
			select 'Berlin'	into new.gemeinde;
		elsif t THEN
			select gem_name from basisdaten.zusammengestellten_gemeinden pol where st_contains(pol.geom, new.geom) limit 1
				into new.gemeinde;
		end if;				
	end if;
	
END
$$ language plpgsql;

drop trigger if exists tr_adressen_nvt_before_upin on adressen.nvts;
create trigger tr_adressen_nvt_before_upin 
	before insert or update on adressen.nvts
		for each row
			execute procedure tr_adressen_nvt_before_upin();


