drop table if exists view_b_bb.dv_abschluss cascade;
create table view_b_bb.dv_abschluss (
	_adresse_id uuid,
	_abschluss_id uuid,
	_nvt_ uuid,
	nvt_bez text,
	_verbindung_ text,
	_farbe_seq_ text,
	_abschluss_bez text,
	_knoten_id_ uuid,
	status_nvt text DeFAULT 'geplant' ,		-- Inerlich
	status_ap_tiefbau text DeFAULT 'geplant' , -- Inerlich
	status_ap_montage text DeFAULT 'geplant' , -- Inerlich
	homeconnect_status text,
	typ text,
	_vid_ text,
	_alkis_id_ dom_adresse_id,
	_strasse_ text,
	_haus_nr_  dom_numeric_string,
	_adresszusatz_ text,
	_plz_ dom_5_digit_string,
	_ort_ text,
	_projekt_ text,
	adresse_checked boolean,
	ne_checked boolean,
	_cluster_  integer,
	_trig text default 'dv',--dv  / master
	constraint pk_dv_abschluss primary key (_adresse_id,_abschluss_id)
);

---- view  -- INSERT    trigger
create or replace RULE rule_prj_test_zeuthen_dv_hausanschluss_insert_1
	as on insert to view_b_bb.dv_abschluss
		where new._trig='master'
			DO ALSO (select 'Inserted');
CREATE OR REPLACE RULE rule_prj_test_zeuthen_dv_hausanschluss_insert_2
	as on insert to view_b_bb.dv_abschluss
		where new._trig='dv'
			Do instead (SELECT pop_error(E'Error \n    It is not possible to insert directly to Dynamic-View "dv_abschluss" !','Instead, Insert into the master table "prj_test_zeuthen.adresse_abschluss".'));

---- view  -- DELETE    trigger
CREATE OR REPLACE RULE rule_prj_test_zeuthen_dv_abschluss_delete
	AS ON DELETE TO view_b_bb.dv_abschluss
		where exists (select from prj_test_zeuthen.adresse_abschluss sc where old._adresse_id=sc.adresse_id and old._abschluss_id=sc.abschlusspunkte_id)
			DO INSTEAD (SELECT pop_error(E'Error \n    It is not possible to delete from Dynamic-View "dv_abschluss" !','DELETE from the master table "prj_test_zeuthen.adresse_abschluss".'));


---- view  -- UPDATE    trigger
create or replace function tr_prj_test_zeuthen_dv_abschluss_before_update() returns trigger as $$
declare
	t boolean;
begin
	select case
		when 
			(NEW._adresse_id = OLD._adresse_id or ((NEW._adresse_id is null) and (OLD._adresse_id is null)))
			and (NEW._abschluss_id = OLD._abschluss_id or ((NEW._abschluss_id is null) and (OLD._abschluss_id is null)))
			and (NEW._knoten_id_ = OLD._knoten_id_ or ((NEW._knoten_id_ is null) and (OLD._knoten_id_ is null)))
			and (NEW._abschluss_bez = OLD._abschluss_bez or ((NEW._abschluss_bez is null) and (OLD._abschluss_bez is null)))
			and (NEW._vid_ = OLD._vid_ or ((NEW._vid_ is null) and (OLD._vid_ is null)))
			and (NEW._alkis_id_ = OLD._alkis_id_ or ((NEW._alkis_id_ is null) and (OLD._alkis_id_ is null)))
			and (NEW.homeconnect_status = OLD.homeconnect_status or ((NEW.homeconnect_status is null) and (OLD.homeconnect_status is null)))
			and (NEW.typ = OLD.typ or ((NEW.typ is null) and (OLD.typ is null)))
			and (NEW._strasse_ = OLD._strasse_ or ((NEW._strasse_ is null) and (OLD._strasse_ is null)))
			and (NEW._haus_nr_ = OLD._haus_nr_ or ((NEW._haus_nr_ is null) and (OLD._haus_nr_ is null)))
			and (NEW._adresszusatz_ = OLD._adresszusatz_ or ((NEW._adresszusatz_ is null) and (OLD._adresszusatz_ is null)))
			and (NEW._plz_ = OLD._plz_ or ((NEW._plz_ is null) and (OLD._plz_ is null)))
			and (NEW._ort_ = OLD._ort_ or ((NEW._ort_ is null) and (OLD._ort_ is null)))
			and (NEW._projekt_ = OLD._projekt_ or ((NEW._projekt_ is null) and (OLD._projekt_ is null)))
			and (NEW.adresse_checked = OLD.adresse_checked or ((NEW.adresse_checked is null) and (OLD.adresse_checked is null)))
			and (NEW.ne_checked = OLD.ne_checked or ((NEW.ne_checked is null) and (OLD.ne_checked is null)))
			and (NEW._verbindung_ = OLD._verbindung_ or ((NEW._verbindung_ is null) and (OLD._verbindung_ is null)))
			and (NEW._farbe_seq_ = OLD._farbe_seq_ or ((NEW._farbe_seq_ is null) and (OLD._farbe_seq_ is null)))
			and (NEW._nvt_ = OLD._nvt_ or ((NEW._nvt_ is null) and (OLD._nvt_ is null)))
			and (NEW.nvt_bez = OLD.nvt_bez or ((NEW.nvt_bez is null) and (OLD.nvt_bez is null)))
			and (NEW._cluster_ = OLD._cluster_ or ((NEW._cluster_ is null) and (OLD._cluster_ is null)))
		then true
		else false END
	into t;
	raise notice 'T-val is % ',t;
	if (t) Then
		raise notice '=> 1';
		---- only native columns of the dv are updated.
		new._trig:='dv';
		RETURN NEW;
	elsif (old._trig='dv' and NEW._trig='master') then
		raise notice '=> 2';
		new._trig:='dv';
		RETURN NEW;
	elsif (OLD._trig='dv' and NEW._trig='dv') then
		raise notice '=> 3';
		if (NEW._vid_ = OLD._vid_ or ((NEW._vid_ is null) and (OLD._vid_ is null)))
			and (NEW._knoten_id_ = OLD._knoten_id_ or ((NEW._knoten_id_ is null) and (OLD._knoten_id_ is null)))
			and (NEW._alkis_id_ = OLD._alkis_id_ or ((NEW._alkis_id_ is null) and (OLD._alkis_id_ is null)))
			and (NEW._strasse_ = OLD._strasse_ or ((NEW._strasse_ is null) and (OLD._strasse_ is null)))
			and (NEW._haus_nr_ = OLD._haus_nr_ or ((NEW._haus_nr_ is null) and (OLD._haus_nr_ is null)))
			and (NEW._adresszusatz_ = OLD._adresszusatz_ or ((NEW._adresszusatz_ is null) and (OLD._adresszusatz_ is null)))
			and (NEW._plz_ = OLD._plz_ or ((NEW._plz_ is null) and (OLD._plz_ is null)))
			and (NEW._ort_ = OLD._ort_ or ((NEW._ort_ is null) and (OLD._ort_ is null)))
			and (NEW._projekt_ = OLD._projekt_ or ((NEW._projekt_ is null) and (OLD._projekt_ is null)))
			and (NEW._verbindung_ = OLD._verbindung_ or ((NEW._verbindung_ is null) and (OLD._verbindung_ is null)))
			and (NEW._farbe_seq_ = OLD._farbe_seq_ or ((NEW._farbe_seq_ is null) and (OLD._farbe_seq_ is null)))
			and (NEW._nvt_ = OLD._nvt_ or ((NEW._nvt_ is null) and (OLD._nvt_ is null)))
			and (NEW._cluster_ = OLD._cluster_ or ((NEW._cluster_ is null) and (OLD._cluster_ is null)))
			then
				update prj_test_zeuthen.abschlusspunkte tar set
					homeconnect_status=new.homeconnect_status
					, typ=new.typ
					where tar.id=new._abschluss_id;
				update adressen.adressen tar set
					adresse_checked= (select case when new.adresse_checked=true then 'Ja' else 'Nein' End)
					, ne_checked= (select case when new.ne_checked=True then 'Ja' else 'Nein' end)
					where tar.id=new._adresse_id;
				update prj_test_zeuthen.knoten tar set
					bez=new._abschluss_bez
					where tar.id=(select knoten_id from prj_test_zeuthen.abschlusspunkte ab where ab.id=new._abschluss_id);
				update prj_test_zeuthen.knoten tar set
					bez=new.nvt_bez
					where tar.id=(select knoten_id from prj_test_zeuthen.abschlusspunkte ab where ab.id=new._nvt_);
				update prj_test_zeuthen.adresse_abschluss tar set
					abschlusspunkte_id=new._abschluss_id
					, adresse_id = new._adresse_id
					where tar.adresse_id=old._adresse_id and tar.abschlusspunkte_id=old._abschluss_id;
		ELSE
			raise notice '=> 4';
			Select pop_error(E'Error \n    It is not possible to update fileds with _ at the begining and the end of theeir names!','Update the master table instead.');
		END if;
		Return Null;
	ELSE 
		Return Null; 
	END if;
END;
$$ language plpgsql;
drop trigger  if  exists tr_prj_test_zeuthen_dv_abschluss_before_update on view_b_bb.dv_abschluss;
CREATE TRIGGER tr_prj_test_zeuthen_dv_abschluss_before_update
	BEFORE UPDATE ON view_b_bb.dv_abschluss
		FOR EACH ROW
			EXECUTE PROCEDURE tr_prj_test_zeuthen_dv_abschluss_before_update();
			

--select * , dns_get_rohr_verbindung(knoten_id, 'prj_test_zeuthen') val from
--	(select * from 
--		(select knoten_id, homeconnect_status, typ, cluster from prj_test_zeuthen.abschlusspunkte abs limit 1) ab     ,   			
--		(select vid _vid_, alkis_id _alkis_id_, strasse _strasse_, hausnr _haus_nr_, adresszusatz _adresszusatz_, plz _plz_,ort  _ort_, case when lower(adresse_checked)=lower('Ja') then True else false end adresse_checked,  case when lower(adresse_checked)=lower('Ja') then True else false end ne_checked from adressen.adressen limit 1) adr
--	) sel1
--	






---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- master -- insert trigger
create or replace function tr_prj_test_zeuthen_adresseabschluss_insert_on_dvabschluss() returns trigger as $$
begin
	insert into view_b_bb.dv_abschluss ( 
		_adresse_id, _abschluss_id   -- von adresse_abschluss
		, homeconnect_status, typ, _cluster_   -- von abschlusspunkte
		, _vid_, _alkis_id_, _strasse_, _haus_nr_, _adresszusatz_, _plz_, _ort_, adresse_checked, ne_checked  --- von adressen
		, _knoten_id_ , _abschluss_bez, _verbindung_, _farbe_seq_, _nvt_ --von knoten
		, nvt_bez--von knoten
		,_projekt_  -- von _cluster
		, _trig  
		) 
		select * , (select bez from prj_test_zeuthen.knoten kn where kn.id=_nvt_ ) nvt_bez, (Select project_name  from _cluster where _cluster.id=_cluster_) _projekt_, 'master' _trig
		from(
			select 
				new.adresse_id _adresse_id, new.abschlusspunkte_id _abschluss_id, homeconnect_status, typ,cluster _cluster_, _vid_, _alkis_id_, _strasse_, _haus_nr_, _adresszusatz_, _plz_, _ort_, adresse_checked, ne_checked
				, knoten_id _knoten_id_, (select bez from prj_test_zeuthen.knoten kn where kn.id=knoten_id) _abschluss_bez, val[2] _verbindung_, val[1]  _farbe_seq_, (val[3])::uuid _nvt_
			from (
					select * , dns_get_rohr_verbindung(knoten_id, 'prj_test_zeuthen') val from
						(select * from 
							(select knoten_id, homeconnect_status, typ, cluster from prj_test_zeuthen.abschlusspunkte  abs where abs.id=new.abschlusspunkte_id) ab   			
							,(select vid _vid_, alkis_id _alkis_id_, strasse _strasse_, hausnr _haus_nr_, adresszusatz _adresszusatz_, plz _plz_,ort  _ort_, case when lower(adresse_checked)=lower('Ja') then True else false end adresse_checked,  case when lower(ne_checked)=lower('Ja') then True else false end ne_checked from adressen.adressen ad where ad.id= new.adresse_id) adr
						) sel1
				)sel2
			) sel3;
	update view_b_bb.dv_abschluss  set _trig='dv' where _trig!='dv';
	return new;
end;
$$ language plpgsql;
drop trigger if exists tr_prj_test_zeuthen_adresseabschluss_insert_on_dvabschluss on prj_test_zeuthen.adresse_abschluss;
create trigger tr_prj_test_zeuthen_adresseabschluss_insert_on_dvabschluss
	AFTER insert on prj_test_zeuthen.adresse_abschluss
		for each row
			execute procedure tr_prj_test_zeuthen_adresseabschluss_insert_on_dvabschluss();

---- master  -- DELETE    trigger
CREATE Or REPLACE FUNCTION tr_prj_test_zeuthen_adresseabschluss_delete_on_dvabschluss() returns trigger as $$
begin
	DELETE FROM view_b_bb.dv_abschluss  where _adresse_id=old.adresse_id and _abschluss_id=old.abschlusspunkte_id;
	return null;
End;
$$ language plpgsql;
drop trigger if exists tr_prj_test_zeuthen_adresseabschluss_delete_on_dvabschluss on prj_test_zeuthen.adresse_abschluss;
create trigger tr_prj_test_zeuthen_adresseabschluss_delete_on_dvabschluss
	after delete on prj_test_zeuthen.adresse_abschluss
		for each row
			execute procedure tr_prj_test_zeuthen_adresseabschluss_delete_on_dvabschluss();


---- master -- UPDATE   trigger
CREATE OR REPLACE RULE rule_prj_test_zeuthen_adresseabschluss_update_on_dvabschluss
	AS ON UPDATE TO prj_test_zeuthen.adresse_abschluss
		DO ALSO (
			update view_b_bb.dv_abschluss   dv set
				_adresse_id=sel4._adresse_id,
				_abschluss_id=sel4._abschluss_id,
				homeconnect_status=sel4.homeconnect_status,
				typ=sel4.typ,
				_cluster_=sel4._cluster_,
				_vid_=sel4._vid_,
				_alkis_id_=sel4._alkis_id_,
				_strasse_=sel4._strasse_,
				_haus_nr_=sel4._haus_nr_,
				_adresszusatz_=sel4._adresszusatz_,
				_plz_=sel4._plz_,
				_ort_=sel4._ort_,
				adresse_checked=sel4.adresse_checked,
				ne_checked=sel4.ne_checked,
				_knoten_id_=sel4._knoten_id_,
				_abschluss_bez=sel4._abschluss_bez,
				_verbindung_=sel4._verbindung_,
				_farbe_seq_=sel4._farbe_seq_,
				_nvt_=sel4._nvt_,
				nvt_bez=sel4.nvt_bez,
				_projekt_=sel4._projekt_,
				_trig=sel4._trig
				from (
						select * , (select bez from prj_test_zeuthen.knoten kn where kn.id=_nvt_ ) nvt_bez, (Select project_name  from _cluster where _cluster.id=_cluster_) _projekt_, 'master' _trig
						from(
							select 
								new.adresse_id _adresse_id, new.abschlusspunkte_id _abschluss_id, homeconnect_status, typ,cluster _cluster_, _vid_, _alkis_id_, _strasse_, _haus_nr_, _adresszusatz_, _plz_, _ort_, adresse_checked, ne_checked
								, knoten_id _knoten_id_, (select bez from prj_test_zeuthen.knoten kn where kn.id=knoten_id) _abschluss_bez, val[2] _verbindung_, val[1]  _farbe_seq_, (val[3])::uuid _nvt_
							from (
									select * , dns_get_rohr_verbindung(knoten_id, 'prj_test_zeuthen') val from
										(select * from 
											(select knoten_id, homeconnect_status, typ, cluster from prj_test_zeuthen.abschlusspunkte  abs where abs.id=new.abschlusspunkte_id) ab   			
											,(select vid _vid_, alkis_id _alkis_id_, strasse _strasse_, hausnr _haus_nr_, adresszusatz _adresszusatz_, plz _plz_,ort  _ort_, case when lower(adresse_checked)=lower('Ja') then True else false end adresse_checked,  case when lower(ne_checked)=lower('Ja') then True else false end ne_checked from adressen.adressen ad where ad.id= new.adresse_id) adr
										) sel1
								)sel2
							) sel3
						) sel4
				where dv._adresse_id=old.adresse_id and dv._abschluss_id=old.abschlusspunkte_id;
			update view_b_bb.dv_abschluss  set _trig='dv' where _trig!='dv';
			);

			
create or replace RULE rule_adressen_update_on_dv_prj_test_zeuthen
	as on update to adressen.adressen
		where (new.bezirk_nr is not null and new.bezirk_nr in (select unnest(bezirk_nr) from _cluster where schema_name='prj_test_zeuthen' )) 
			or 
			(new.gemeinde_schluessel is not null and new.gemeinde_schluessel in (select unnest(gemeindeschluessel) from _cluster where schema_name='prj_test_zeuthen' ))
				do also(
					update view_b_bb.dv_abschluss set ne_checked=(select case when lower(new.ne_checked) = 'ja' then True else false end)
								, adresse_checked =(select case when lower(new.adresse_checked) = 'ja' then True else false end)
								, _trig='master'  where old.id=_adresse_id ;
					update view_b_bb.dv_abschluss  set _trig='dv' where _trig!='dv'; 
							);

								
create or replace RULE rule_knoten_update_on_dv_prj_test_zeuthen_dvabschluss
	as on update to prj_test_zeuthen.knoten
			do also(
					update view_b_bb.dv_abschluss set
								 _knoten_id_=new.id
								, _abschluss_bez=new.bez 
								, _trig='master' 
							where old.id=_knoten_id_;
					update view_b_bb.dv_abschluss  set _trig='dv' where _trig!='dv';
					update view_b_bb.dv_abschluss set 
								_nvt_=new.id
								, nvt_bez=new.bez 
								, _trig='master'
							where old.id=_nvt_;
					update view_b_bb.dv_abschluss  set _trig='dv' where _trig!='dv';
								);			


create or replace RULE rule_abschlusspunkte_update_on_dv_prj_test_zeuthen_dvabschluss
	as on update to prj_test_zeuthen.abschlusspunkte
			do also(
				update view_b_bb.dv_abschluss  set 
						homeconnect_status = new.homeconnect_status
						, typ= new.typ
						, _cluster_ = new.cluster
					where old.id=_abschluss_id;
				update view_b_bb.dv_abschluss  set _trig='dv' where _trig!='dv';
								);	
								


---- TO DO LATER   create or replace RULE rule_microduct_update_on_dv_prj_test_zeuthen_dvabschluss
---- TO DO LATER   	as on update to prj_test_zeuthen.microduct
---- TO DO LATER   			do also(
---- TO DO LATER   				update view_b_bb.dv_abschluss  set 
---- TO DO LATER   						homeconnect_status = new.homeconnect_status
---- TO DO LATER   						, typ= new.typ
---- TO DO LATER   						, _cluster_ = new.cluster
---- TO DO LATER   					where old.id=_abschluss_id;
---- TO DO LATER   				update view_b_bb.dv_abschluss  set _trig='dv' where _trig!='dv';
---- TO DO LATER   								);
---- TO DO LATER   



--create or replace function update microduct_verbindung(sch text) returns void as $$
--declare
--	kn uuid;
--	ans text[];
--begin
--	for kn in (select _knoten_id_ from ||sch||.dv_abschluss) loop
--		ans:=dns_get_rohr_verbindung(knoten_id, ||sch||);
--		update view_b_bb.dv_abschluss v set
--			_verbindung_=ans[2]
--			, _farbe_seq_ =ans[1]
--			,_nvt_=(ans[3])::uuid
--			,_trig='master'
--		where v._knoten_id_=kn;
--		update view_b_bb.dv_abschluss  set _trig='dv' where _trig!='dv';
--	end loop;
--end
--$$ language plpgsql;




