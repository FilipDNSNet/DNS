/*--------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	Trigger                                                                                                                                               			--
--	                                                                                                                                                                --
--	                                                                                                                                                                --
--	name:		tr_adresseabschluss_before_update                                                                                                                   --
--	schema:		public                                                                                                                                              --
--	typ:		Trigger                                                                                                                                             --
--	cr.date:	05.10.2020                                                                                                                                          --
--	ed.date:	24.11.2020                                                                                                                                          --
--	impressionable_tables:                                                                                                                                          --       
--				adressen.adresse_abschluss                                                                                                                          --                                                                                                                                               
--	purpose: 	                                                                                                                                                    --
--				...			                                                                                                                                        --            
--	DNS-Net GIS group                                                                                                                                               --
--*/------------------------------------------------------------------------------------------------------------------------------------------------------------------





create or replace function tr_adresseabschluss_before_update() returns trigger as $$
-- common between all projects
declare
	t boolean;
	sch text;
	kn uuid;
	ans text[];
begin
	select schema_name from _cluster where id= new.cluster into sch;
	select case
		when 
			(NEW._adresse_id = OLD._adresse_id or ((NEW._adresse_id is null) and (OLD._adresse_id is null)))
			and (NEW._abschluss_id = OLD._abschluss_id or ((NEW._abschluss_id is null) and (OLD._abschluss_id is null)))
			and (NEW._knoten_id_ = OLD._knoten_id_ or ((NEW._knoten_id_ is null) and (OLD._knoten_id_ is null)))
			and (NEW._abschluss_bez_ = OLD._abschluss_bez_ or ((NEW._abschluss_bez_ is null) and (OLD._abschluss_bez_ is null)))
			and (NEW.vid = OLD.vid or ((NEW.vid is null) and (OLD.vid is null)))
			and (NEW._alkis_id_ = OLD._alkis_id_ or ((NEW._alkis_id_ is null) and (OLD._alkis_id_ is null)))
			--and (NEW.homeconnect_status = OLD.homeconnect_status or ((NEW.homeconnect_status is null) and (OLD.homeconnect_status is null)))
			--and (NEW.typ = OLD.typ or ((NEW.typ is null) and (OLD.typ is null)))
			and (NEW._strasse_ = OLD._strasse_ or ((NEW._strasse_ is null) and (OLD._strasse_ is null)))
			and (NEW._haus_nr_ = OLD._haus_nr_ or ((NEW._haus_nr_ is null) and (OLD._haus_nr_ is null)))
			and (NEW._adresszusatz_ = OLD._adresszusatz_ or ((NEW._adresszusatz_ is null) and (OLD._adresszusatz_ is null)))
			and (NEW._plz_ = OLD._plz_ or ((NEW._plz_ is null) and (OLD._plz_ is null)))
			and (NEW._ort_ = OLD._ort_ or ((NEW._ort_ is null) and (OLD._ort_ is null)))
			--and (NEW.projekt = OLD.projekt or ((NEW.projekt is null) and (OLD.projekt is null)))
			and (NEW.adresse_checked = OLD.adresse_checked or ((NEW.adresse_checked is null) and (OLD.adresse_checked is null)))
			and (NEW.ne_checked = OLD.ne_checked or ((NEW.ne_checked is null) and (OLD.ne_checked is null)))
			and (NEW._verbindung_ = OLD._verbindung_ or ((NEW._verbindung_ is null) and (OLD._verbindung_ is null)))
			and (NEW._farbe_seq_ = OLD._farbe_seq_ or ((NEW._farbe_seq_ is null) and (OLD._farbe_seq_ is null)))
			and (NEW._nvt_ = OLD._nvt_ or ((NEW._nvt_ is null) and (OLD._nvt_ is null)))
			and (NEW._nvt_bez_ = OLD._nvt_bez_ or ((NEW._nvt_bez_ is null) and (OLD._nvt_bez_ is null)))
			and (st_equals(NEW._geom_ , OLD._geom_ ) or ((st_isEmpty(NEW._geom_)) and (st_isEmpty(OLD._geom_) )))
			and (NEW.cluster = OLD.cluster or ((NEW.cluster is null) and (OLD.cluster is null)))
		then true
		else false END
	into t;
	--raise notice 'T-val is %   old:%  new:%',t, new.ne_checked,new.ne_checked;
	if (t) Then
		---- only native columns of the dv are updated which makes no changes on the other tables.
		--raise notice '=> 1';
		new._trig:='dv';
		RETURN NEW;
	elsif (old._trig='dv' and NEW._trig='master') then
		---- update is made by master tables.
		--raise notice '=> 2';
		--if  new._abschluss_id is not null and new._abschluss_id<>old._abschluss_id and dns_validate_new_abscluss_id(new._abschluss_id, new.cluster)=false then
		--	select pop_error(E'Error_dns : The _abschluss_id is not found in the given schema. \n  Either the schema does not exists, or the project is not registered(no table abschlusspunkte), or the given id is not found!  ');
		--	return null;
		--end if;
		new._trig:='dv';
		RETURN NEW;
	elsif (OLD._trig='dv' and NEW._trig='dv') then
		---- Update is caused by direct change in the table "adressen.adresse_abschluss"
		--raise notice '=> 3';
		-- if the update does not change the immutable columns:
		if  (NEW._knoten_id_ = OLD._knoten_id_ or ((NEW._knoten_id_ is null) and (OLD._knoten_id_ is null)))
			and (NEW._alkis_id_ = OLD._alkis_id_ or ((NEW._alkis_id_ is null) and (OLD._alkis_id_ is null)))
			and (NEW._strasse_ = OLD._strasse_ or ((NEW._strasse_ is null) and (OLD._strasse_ is null)))
			and (NEW._haus_nr_ = OLD._haus_nr_ or ((NEW._haus_nr_ is null) and (OLD._haus_nr_ is null)))
			and (NEW._adresszusatz_ = OLD._adresszusatz_ or ((NEW._adresszusatz_ is null) and (OLD._adresszusatz_ is null)))
			and (NEW._plz_ = OLD._plz_ or ((NEW._plz_ is null) and (OLD._plz_ is null)))
			and (NEW._ort_ = OLD._ort_ or ((NEW._ort_ is null) and (OLD._ort_ is null)))
			--and (NEW.projekt = OLD.projekt or ((NEW.projekt is null) and (OLD.projekt is null)))
			and (NEW._verbindung_ = OLD._verbindung_ or ((NEW._verbindung_ is null) and (OLD._verbindung_ is null)))
			and (NEW._farbe_seq_ = OLD._farbe_seq_ or ((NEW._farbe_seq_ is null) and (OLD._farbe_seq_ is null)))
			and (NEW._nvt_ = OLD._nvt_ or ((NEW._nvt_ is null) and (OLD._nvt_ is null)))
			and (NEW._nvt_bez_ = OLD._nvt_bez_ or ((NEW._nvt_bez_ is null) and (OLD._nvt_bez_ is null)))
			and (NEW._abschluss_bez_ = OLD._abschluss_bez_ or ((NEW._abschluss_bez_ is null) and (OLD._abschluss_bez_ is null)))
			and (st_equals(NEW._geom_ , OLD._geom_ )or (st_isEmpty(NEW._geom_) and st_isEmpty(OLD._geom_)))
			--and (NEW.cluster = OLD.cluster or ((NEW.cluster is null) and (OLD.cluster is null)))
			then
				--##--------------
				if  new._abschluss_id is not null and (old._abschluss_id is null or new._abschluss_id<>old._abschluss_id ) then
					--raise notice 'Haahh  %', sch;
					if  dns_validate_new_abscluss_id(new._abschluss_id, new.cluster)=false then
						select pop_error(E'Error_dns : The _abschluss_id is not found in the given schema. \n  Either the schema does not exists, or the project is not registered(no table abschlusspunkte), or the given id is not found!  ');
						return null;
					else
						--raise notice 'torokhodddda';
						
						execute('select knoten_id from '||sch||'.abschlusspunkte where id=$1;') using new._abschluss_id   into kn;-- knoten_id of the abschlusspunkt
						new._knoten_id_:=kn;
						execute('select bez from '||sch||'.knoten where id=$1 ;')     using kn into new._abschluss_bez_;
						select dns_get_rohr_verbindung(kn, sch) into ans;
						select (ans[3])::uuid into new._nvt_;
						execute('select bez from '||sch||'.knoten where id=$1 ;')     using (ans[3])::uuid into new._nvt_bez_;
						new._verbindung_:=ans[2];
						new._farbe_seq_:=ans[1];
						new._verbindung_id_=ans[4];
						
						
						new._trig:='master';
						--raise notice 'new_farbe  %', kn;
						--  --update adresses:(it might happen that the adresses are also updated)
						--  execute('
						--  	update adressen.adressen tar set
						--  	adresse_checked= (select case when $1=true then $2 else $3 End)
						--  	, ne_checked= (select case when $4=True then $2 else $3 end)
						--  	, vid= $5
						--  	where tar.id=$6;
						--  ')using new.adresse_checked, 'Ja', 'Nein', new.ne_checked, new.vid, new._adresse_id;
						
						return new;
					end if;
				end if;
				--execute('
				--	update '||sch||'.abschlusspunkte tar set
				--	typ=$1
				--	where tar.id=$2;
				--') using new.typ, new._abschluss_id;
				
				execute('
					update adressen.adressen tar set
					adresse_checked= (select case when $1=true then $2 else $3 End)
					, ne_checked= (select case when $4=True then $2 else $3 end)
					, vid= $5
					where tar.id=$6;
				')using new.adresse_checked, 'Ja', 'Nein', new.ne_checked, new.vid, new._adresse_id;
				
				--execute('
				--	update '||sch||'.knoten tar set
				--	bez=$1
				--	where tar.id=(select knoten_id from '||sch||'.abschlusspunkte ab where ab.id=$2);
				--') using new._abschluss_bez, new._abschluss_id;
				
				--execute('
				--	update '||sch||'.knoten tar set
				--	bez=$1
				--	where tar.id=(select knoten_id from '||sch||'.abschlusspunkte ab where ab.id=$2);
				--') using new._nvt_bez_, new._nvt_;

				--execute('
				--	update '||sch||'.adresse_abschluss tar set
				--	abschlusspunkte_id=$1
				--	, adresse_id = $2
				--	where tar.adresse_id=$3 and tar.abschlusspunkte_id=$4;
				--') using new._abschluss_id, new._adresse_id, old._adresse_id, old._abschluss_id;
				
			return Null;
		ELSE
			--raise notice '=> 4';
			Select pop_error(E'Error \n    It is not possible to update fileds with _ at the begining and the end of theeir names!','Update the master table instead.');
		END if;
		Return Null;
	ELSE 
		Return Null; 
	END if;
END;
$$ language plpgsql;



drop trigger  if  exists tr_adresseabschluss_before_update on adressen.adresse_abschluss;

CREATE TRIGGER tr_adresseabschluss_before_update
	BEFORE UPDATE ON adressen.adresse_abschluss
		FOR EACH ROW
			EXECUTE PROCEDURE tr_adresseabschluss_before_update();
			
			
			
			