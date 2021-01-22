/*-- This file is used to imlement ansd test the creation of the dynamic table for 
-- fluestueck-Eigentümer  Normally it is slow to use it in calsucal view.
-- In first versions the name was "dv_flurstueck" we changed it to "dv_flurstueck_eigentuemer"
-- DNS-Net GIS team
-- 18.01.2021
--*/

-- DROPPING
-- drop table if exists zusammenstellungen.dv_flurstueck_eigentuemer;


--Table Definition



CREATE SCHEMA IF NOT EXISTS zusammenstellungen;


CREATE TABLE zusammenstellungen.dv_flurstueck_eigentuemer (
	-- For Brandenburg : EPSGFcode 25833
	-- (_ogc_fid_, _gml_id, _flurstueckskennzeichen_, _flsnr_, _gemarkungsnummer_, _gemarkung_, _flurnummer_
	-- 	, _nenner_, _zaehler_, _weistauf_, _adressen_, _eigentuemer_, _gemeinde_, _geom_, _trig)
	_ogc_fid_ integer
	, _gml_id varchar(16)
	, _flurstueckskennzeichen_ text
	, _flsnr_ text
	, _gemarkungsnummer_ text
	, _gemarkung_ text
	, _flurnummer_ integer
	, _nenner_ text
	, _zaehler_ text
	, _weistauf_ varchar(16)[]
	, _adressen_ text
	, _eigentuemer_ text
	, _gemeinde_ text
	, _geom_ geometry('Polygon',25833)
	, _trig text default 'dv'
);
ALTER TABLE zusammenstellungen.dv_flurstueck_eigentuemer add constraint pk_dv_flurstueck_eigentuemer primary key(_ogc_fid_);
ALTER TABLE zusammenstellungen.dv_flurstueck_eigentuemer add constraint fk_dv_flurstueck_eigentuemer_ogc_fid
	foreign key(_ogc_fid_) references ax_flurstueck(ogc_fid) on delete cascade;
create index inx_dvflurstueck_eigentuemer_gmlid on zusammenstellungen.dv_flurstueck_eigentuemer(_gml_id);
create index inx_dvflurstueck_eigentuemer_flsnr on zusammenstellungen.dv_flurstueck_eigentuemer(_flsnr_);
create index inx_dvflurstueck_eigentuemer_gemarkungsnr on zusammenstellungen.dv_flurstueck_eigentuemer(_gemarkungsnummer_);
create index inx_dvflurstueck_eigentuemer_geom on zusammenstellungen.dv_flurstueck_eigentuemer using GIST(_geom_);


-- from dns_net_geodb
create or replace function pop_error(error_message text default 'Error', hint_text text default '') returns void as $$
	BEGIN
		raise exception '%' ,error_message using hint = hint_text;
	END;
	$$language plpgsql;




CREATE OR REPLACE FUNCTION tr_ax_flurstueck_after_insert() returns trigger as $$
-- This function Insert the new insertions to zusammenstellungen.dv_flurstueck_eigentuemer.
DECLARE
	_flsnr text; 
	_ff_stand integer;
	_amtlflsfl double precision;
	_lagebez text;
	_gemashl varchar(6);
	ax_flsnr text;
	_gemarkung text;
	_adressen text;
	_eigentuemer text;
	_gemname text;	
BEGIN
	SELECT ( alkis_flsnr(ax_flurstueck.* ) )::text from ax_flurstueck where ogc_fid= new.ogc_fid into ax_flsnr;
	------------------------------------------------------------------ from flurst
	EXECUTE('select flsnr , ff_stand, amtlflsfl, lagebez, gemashl from flurst where ff_stand=0 and flsnr=$1 limit 1')  using ax_flsnr  into
		_flsnr , _ff_stand, _amtlflsfl, _lagebez, _gemashl; -- #ToDo remove limit 1 and check for duplication
	
	------------------------------------------------------------------ _gemarkung
	SELECT gema_shl.gemarkung FROM gema_shl WHERE gema_shl.gemashl = _gemashl into _gemarkung;
	
	------------------------------------------------------------------ adressen
	EXECUTE('with sel as ( select * from strassen where strassen.flsnr=($1)::bpchar AND (strassen.ff_stand = 0)  )
	select array_to_string((array_agg(DISTINCT ((str_shl.strname)::text || COALESCE(('' ''::text || (sel.hausnr)::text), ''''::text))) ||
					CASE
						WHEN ($2 IS NULL) THEN (ARRAY[$2])::text[]
						ELSE ''{}''::text[]
					END), ''''::text) AS array_to_string
	from sel left join str_shl on sel.strshl=str_shl.strshl
	') using  _flsnr, _lagebez into _adressen;
	------------------------------------------------------------------ _eigentuemer
	Execute('
		With sel as (select * from eignerart where eignerart.flsnr=($1)::bpchar AND (eignerart.ff_stand = 0)  )
			select
				array_to_string(array_agg(DISTINCT ((((e.name1)::text || COALESCE(('', ''::text || (e.name2)::text), ''''::text)) 
					|| COALESCE(('', ''::text || (e.name3)::text), ''''::text)) || COALESCE(('', ''::text 
					|| (e.name4)::text), ''''::text))), ''''::text) AS array_to_string
		from sel join eigner e ON (((sel.bestdnr = e.bestdnr) AND (e.ff_stand = 0)));
	') using  _flsnr, _lagebez into _eigentuemer;
	------------------------------------------------------------------ _gemname
	Execute('
	select  gemname from gem_shl where gemshl =(
		select gemshl from gema_shl where gema_shl.gemashl=(
			select schluesselgesamt from ax_gemarkung where gemarkungsnummer=$1
		) 
	);
	') using new.gemarkungsnummer into _gemname; 
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	INSERT INTO  zusammenstellungen.dv_flurstueck_eigentuemer(
			_ogc_fid_, _gml_id, _flurstueckskennzeichen_, _flsnr_, _gemarkungsnummer_, _gemarkung_, _flurnummer_,
			_nenner_, _zaehler_, _weistauf_, _adressen_, _eigentuemer_, _gemeinde_, _geom_, _trig)
		VALUES
			(new.ogc_fid, new.gml_id, new.flurstueckskennzeichen, _flsnr, new.gemarkungsnummer, _gemarkung, new.flurnummer 
			,new.nenner, new.zaehler, new.weistauf, _adressen, _eigentuemer, _gemname, new.wkb_geometry, 'master'); 
	update zusammenstellungen.dv_flurstueck_eigentuemer set _trig = 'dv' where _ogc_fid_=new.ogc_fid;
	return new;
END; $$ LANGUAGE PLPGSQL;


drop trigger if exists tr_ax_flurstueck_after_insert on ax_flurstueck;

CREATE TRIGGER tr_ax_flurstueck_after_insert
	after Insert on ax_flurstueck
		for each row
			execute procedure tr_ax_flurstueck_after_insert();



------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--  insert rules on dv
create or replace rule rule_dv_flurstueck_eigentuemer_on_insert_1 
	as on insert to zusammenstellungen.dv_flurstueck_eigentuemer
		where _trig='master'
			do also (SELECT 'Inserted Successfully!');
			

create or replace rule rule_dv_flurstueck_eigentuemer_on_insert_2 
	as on insert to zusammenstellungen.dv_flurstueck_eigentuemer
		WHERE NEW._trig!='master'
			DO INSTEAD (SELECT pop_error(E'Error \n    It is not possible to insert into Dynamic-View "zusammenstellungen.dv_flurstueck_eigentuemer" !',
			'Instead, Insert into the master table "ax_flurstueck".'));





--	Table:			n_entities:	used columns:
--	gema_shl:		1429		(gemashl, gemarkung)
--	gem_shl:		271			(gemname)
--	strassen:		1970975		(flsnr, ff_stand)
--	str_shl:		51243		(strshl, strname)
--	eignerart:		2085287		(flsnr, ff_stand)
--	eigner:			883699		(name1, name2, name3, name4, bestdnr, ff_stand)
--	ax_flurstueck	2078399 	()
--	flurst:			2076885		(flsnr , ff_stand, amtlflsfl, lagebez, gemashl)
--



CREATE OR REPLACE FUNCTION tr_dv_flurstueck_eigentuemer_before_update() returns trigger as $$
DECLARE
	t boolean;
BEGIN
	select case 
			when 
				(new._ogc_fid_=OLD._ogc_fid_ or ((new._ogc_fid_ is NULL) AND (OLD._ogc_fid_ is NULL)) )
					AND (new._gml_id=OLD._gml_id or ((new._gml_id is NULL) AND (OLD._gml_id is NULL)) )
					AND (new._flurstueckskennzeichen_ =OLD._flurstueckskennzeichen_ or ((new._flurstueckskennzeichen_ is NULL) AND (OLD._flurstueckskennzeichen_ is NULL)) )
					AND (new._flsnr_=OLD._flsnr_ or ((new._flsnr_ is NULL) AND (OLD._flsnr_ is NULL)) )
					AND (new._gemarkungsnummer_ =OLD._gemarkungsnummer_ or ((new._gemarkungsnummer_ is NULL) AND (OLD._gemarkungsnummer_ is NULL)) )
					AND (new._gemarkung_=OLD._gemarkung_ or ((new._gemarkung_ is NULL) AND (OLD._gemarkung_ is NULL)) )
					AND (new._flurnummer_ =OLD._flurnummer_ or ((new._flurnummer_ is NULL) AND (OLD._flurnummer_ is NULL)) )
					AND (new._nenner_ =OLD._nenner_ or ((new._nenner_ is NULL) AND (OLD._nenner_ is NULL)) )
					AND (new._zaehler_=OLD._zaehler_ or ((new._zaehler_ is NULL) AND (OLD._zaehler_ is NULL)) )
					AND (new._weistauf_ =OLD._weistauf_ or ((new._weistauf_ is NULL) AND (OLD._weistauf_ is NULL)) )
					AND (new._adressen_ =OLD._adressen_ or ((new._adressen_ is NULL) AND (OLD._adressen_ is NULL)) )
					AND (new._eigentuemer_=OLD._eigentuemer_ or ((new._eigentuemer_ is NULL) AND (OLD._eigentuemer_ is NULL)) )
					AND (new._gemeinde_=OLD._gemeinde_ or ((new._gemeinde_ is NULL) AND (OLD._gemeinde_ is NULL)) )
					AND (new._geom_ =OLD._geom_ or ((new._geom_ is NULL) AND (OLD._geom_ is NULL)))
				Then TRUE
			else FALSE
			END
		into t;
	if (t) Then
		new._trig:='dv';
		return new;
	elsif t=false and new._trig='master' then
		new._trig='dv';
		return new;
	else
		SELECT pop_error(E'DNS-Net Error \n    It is not possible to update Dynamic-View "zusammenstellungen.dv_flurstueck_eigentuemer" !',
			'update Instead the master table "ax_flurstueck".');
		return null;
	End if;
END; $$ LANGUAGE PLPGSQL;



DROP TRIGGER IF EXISTS tr_dv_flurstueck_eigentuemer_before_update on zusammenstellungen.dv_flurstueck_eigentuemer;

create Trigger tr_dv_flurstueck_eigentuemer_before_update
	before update on zusammenstellungen.dv_flurstueck_eigentuemer
		for each row
			execute procedure tr_dv_flurstueck_eigentuemer_before_update();









CREATE OR REPLACE FUNCTION tr_ax_flurstueck_after_update() returns trigger as $$
-- This function Insert the new insertions to zusammenstellungen.dv_flurstueck_eigentuemer.
DECLARE
	_flsnr text; 
	_ff_stand integer;
	_amtlflsfl double precision;
	_lagebez text;
	_gemashl varchar(6);
	ax_flsnr text;
	_gemarkung text;
	_adressen text;
	_eigentuemer text;
	_gemname text;	
BEGIN
	SELECT ( alkis_flsnr(ax_flurstueck.* ) )::text from ax_flurstueck where ogc_fid= new.ogc_fid into ax_flsnr;
	------------------------------------------------------------------ from flurst
	EXECUTE('select flsnr , ff_stand, amtlflsfl, lagebez, gemashl from flurst where ff_stand=0 and flsnr=$1 limit 1')  using ax_flsnr  into
		_flsnr , _ff_stand, _amtlflsfl, _lagebez, _gemashl; -- #ToDo remove limit 1 and check for duplication
	
	------------------------------------------------------------------ _gemarkung
	SELECT gema_shl.gemarkung FROM gema_shl WHERE gema_shl.gemashl = _gemashl into _gemarkung;
	
	------------------------------------------------------------------ adressen
	EXECUTE('with sel as ( select * from strassen where strassen.flsnr=($1)::bpchar AND (strassen.ff_stand = 0)  )
	select array_to_string((array_agg(DISTINCT ((str_shl.strname)::text || COALESCE(('' ''::text || (sel.hausnr)::text), ''''::text))) ||
					CASE
						WHEN ($2 IS NULL) THEN (ARRAY[$2])::text[]
						ELSE ''{}''::text[]
					END), ''''::text) AS array_to_string
	from sel left join str_shl on sel.strshl=str_shl.strshl
	') using  _flsnr, _lagebez into _adressen;
	------------------------------------------------------------------ _eigentuemer
	Execute('
		With sel as (select * from eignerart where eignerart.flsnr=($1)::bpchar AND (eignerart.ff_stand = 0)  )
			select
				array_to_string(array_agg(DISTINCT ((((e.name1)::text || COALESCE(('', ''::text || (e.name2)::text), ''''::text)) 
					|| COALESCE(('', ''::text || (e.name3)::text), ''''::text)) || COALESCE(('', ''::text 
					|| (e.name4)::text), ''''::text))), ''''::text) AS array_to_string
		from sel join eigner e ON (((sel.bestdnr = e.bestdnr) AND (e.ff_stand = 0)));
	') using  _flsnr, _lagebez into _eigentuemer;
	------------------------------------------------------------------ _gemname
	Execute('
	select  gemname from gem_shl where gemshl =(
		select gemshl from gema_shl where gema_shl.gemashl=(
			select schluesselgesamt from ax_gemarkung where gemarkungsnummer=$1
		) 
	);
	') using new.gemarkungsnummer into _gemname; 
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	UPDATE zusammenstellungen.dv_flurstueck_eigentuemer SET
		_ogc_fid_=sel.ogc_fid
		, _gml_id=sel.gml_id
		, _flurstueckskennzeichen_=sel.flurstueckskennzeichen
		, _flsnr_=sel._flsnr
		, _gemarkungsnummer_=sel.gemarkungsnummer
		, _gemarkung_=sel._gemarkung
		, _flurnummer_=sel.flurnummer
		, _nenner_=sel.nenner
		, _zaehler_=sel.zaehler
		, _weistauf_=sel.weistauf
		, _adressen_=sel._adressen
		, _eigentuemer_=sel._eigentuemer
		, _gemeinde_=sel._gemname
		, _geom_=sel.wkb_geometry
		, _trig = 'master'
		from (select new.ogc_fid, new.gml_id, new.flurstueckskennzeichen, _flsnr, new.gemarkungsnummer, _gemarkung, new.flurnummer 
				,new.nenner, new.zaehler, new.weistauf, _adressen, _eigentuemer, _gemname, new.wkb_geometry
			) sel where _ogc_fid_=sel.ogc_fid;

	--update zusammenstellungen.dv_flurstueck_eigentuemer set _trig = 'dv' where _ogc_fid_=new.ogc_fid;
	return new;
END; $$ LANGUAGE PLPGSQL;

drop trigger if exists tr_ax_flurstueck_after_update on ax_flurstueck;

CREATE TRIGGER tr_ax_flurstueck_after_update
	after update on ax_flurstueck
		for each row
			execute procedure tr_ax_flurstueck_after_update();



-- DELETE

--CREATE OR REPLACE FUNCTION  tr_ax_flurstueck_after_delete RETURNS TRIGGER as $$
--BEGIN
--	delete from zusammenstellungen.dv_flurstueck_eigentuemer.
--END; $$ LANGUAGE PLPGSQL;


create or replace rule rule_dv_flurstueck_eigentuemer_on_delete
	as on delete to zusammenstellungen.dv_flurstueck_eigentuemer
		where exists (select from ax_flurstueck where ogc_fid=old._ogc_fid_)
			Do instead(
				SELECT pop_error(E'DNS-Net Error \n    It is not possible to DELETE from Dynamic-View "zusammenstellungen.dv_flurstueck_eigentuemer" !',
			'Delete Instead from the master table "ax_flurstueck" or deactivate rule "rule_dv_flurstueck_eigentuemer_on_delete".');
			);






-- ------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 
-- to do tomorrow:
-- 	testing
-- 	tr_ax_flurstueck_after_update
-- 	
-- 	tr_ax_flurstueck_after_delete
-- 	rule_dv_flurstueck_eigentuemer_delete
-- 	
-- 	
-- 	tr_gema_shl_update		
-- 	tr_gem_shl_update
-- 	tr_strassen_update	
-- 	tr_str_shl_update
-- 	tr_eignerart_update
-- 	tr_eigner_update
-- 	tr_flurst_update
-- 	
-- 	tr_gema_shl_delete		
-- 	tr_gem_shl_update
-- 	tr_strassen_delete	
-- 	tr_str_shl_delete
-- 	tr_eignerart_delete
-- 	tr_eigner_delete
-- 	tr_flurst_delete

	