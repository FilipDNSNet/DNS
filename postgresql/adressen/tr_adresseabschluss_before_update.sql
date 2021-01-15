/*--------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	Trigger                                                                                                                                               			--
--	                                                                                                                                                                --
--	                                                                                                                                                                --
--	name:		tr_adresseabschluss_before_update                                                                                                                   --
--	schema:		public                                                                                                                                              --
--	typ:		Trigger                                                                                                                                             --
--	cr.date:	05.10.2020                                                                                                                                          --
--	ed.date:	04.01.2021                                                                                                                                          --
--	impressionable_tables:                                                                                                                                          --       
--				adressen.adresse_abschluss                                                                                                                          --
--				adressen.adressen	                                                                                                                                --               
--	purpose: 	                                                                                                                                                    --
--				BEFORE UPDATE ON "adressen.adresse_abschluss"		                                                                                                --            
--	DNS-Net GIS group                                                                                                                                               --
--*/------------------------------------------------------------------------------------------------------------------------------------------------------------------







create or replace function tr_adresseabschluss_before_update() returns trigger as $$
-- common between all projects
declare
	t boolean;
	sch text;
	kn uuid;
	ans text[];
	bol boolean;
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
			and (NEW._strasse_ = OLD._strasse_ or ((NEW._strasse_ is null) and (OLD._strasse_ is null)))
			and (NEW._haus_nr_ = OLD._haus_nr_ or ((NEW._haus_nr_ is null) and (OLD._haus_nr_ is null)))
			and (NEW._adresszusatz_ = OLD._adresszusatz_ or ((NEW._adresszusatz_ is null) and (OLD._adresszusatz_ is null)))
			and (NEW._plz_ = OLD._plz_ or ((NEW._plz_ is null) and (OLD._plz_ is null)))
			and (NEW._ort_ = OLD._ort_ or ((NEW._ort_ is null) and (OLD._ort_ is null)))
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
		raise notice '=> 1';
		new._trig:='dv';
		
		RETURN NEW;

	elsif (old._trig='dv' and NEW._trig='master') then
		---- update is made by master tables.
		raise notice '=> 2';
		new._trig:='dv';
		RETURN NEW;
	elsif (OLD._trig='dv' and NEW._trig='dv') then
		---- Update is caused by direct change in the table "adressen.adresse_abschluss"
		raise notice '=> 3';
		-- if the update does not change the immutable columns:
		select (NEW._alkis_id_ = OLD._alkis_id_ or ((NEW._alkis_id_ is null) and (OLD._alkis_id_ is null)))
			and (NEW._strasse_ = OLD._strasse_ or ((NEW._strasse_ is null) and (OLD._strasse_ is null)))
			and (NEW._haus_nr_ = OLD._haus_nr_ or ((NEW._haus_nr_ is null) and (OLD._haus_nr_ is null)))
			and (NEW._adresszusatz_ = OLD._adresszusatz_ or ((NEW._adresszusatz_ is null) and (OLD._adresszusatz_ is null)))
			and (NEW._plz_ = OLD._plz_ or ((NEW._plz_ is null) and (OLD._plz_ is null)))
			and (NEW._ort_ = OLD._ort_ or ((NEW._ort_ is null) and (OLD._ort_ is null)))
			and (st_equals(NEW._geom_ , OLD._geom_ )or (st_isEmpty(NEW._geom_) and st_isEmpty(OLD._geom_)))
			into bol;
		
		if bol then
			Execute('update adressen.adresse_abschluss set  projekt=$1 ,status_ap=$2, valid_matching=$3, status_nvt=$4 
				where _adresse_id= $5 and (_abschluss_id=$6 or ($6 is null and _abschluss_id is null));'
				)using new.projekt, new.status_ap, new.valid_matching, new.status_nvt, new._adresse_id, new._abschluss_id;
				
			if (
				(new._abschluss_id is not null and (old._abschluss_id is null or new._abschluss_id<>old._abschluss_id ) )
				or
				new._abschluss_id is null and old._abschluss_id is not null
				)
				and (old.ne_checked<>new.ne_checked or old.adresse_checked<>new.adresse_checked or old.vid<>new.vid)
				then
				raise notice '=> 3-00';
				--Execute('
				--	update adressen.adressen tar set
				--	adresse_checked= (select case when $1=true then $2 else $3 End)
				--	, ne_checked= (select case when $4=True then $2 else $3 end)
				--	, vid= $5
				--	where tar.id=$6;
				--')using new.adresse_checked, 'Ja', 'Nein', new.ne_checked, new.vid, new._adresse_id;
				--raise notice '====> %', new._abschluss_id;
				--Execute('update adressen.adresse_abschluss set _abschluss_id=$1
				--	where _adresse_id= $2 and (_abschluss_id=$1 or ($1 is null and _abschluss_id is null));'
				--	)using  new._abschluss_id, new._adresse_id;
				--return null;
				select pop_error(E'DNS-net_Error \n  **  It is not possible to update "_abschluss_id" and adress-related fields at the same time!','Uirst update "_abschluss_id", then other columns.');
			
			
			elsif new._abschluss_id is not null and (old._abschluss_id is null or new._abschluss_id<>old._abschluss_id ) then
			--elsif (new._abschluss_id is not null and old._abschluss_id is null) 
			--	or (new._abschluss_id is null and old._abschluss_id is not null)
			--	or new._abschluss_id<>old._abschluss_id  then
				----################################
				--if old.ne_checked<>new.ne_checked or old.adresse_checked<>new.adresse_checked or old.vid<>new.vid then
				--	execute('
				--			update adressen.adressen tar set
				--			adresse_checked= (select case when $1=true then $2 else $3 End)
				--			, ne_checked= (select case when $4=True then $2 else $3 end)
				--			, vid= $5
				--			where tar.id=$6;
				--		')using new.adresse_checked, 'Ja', 'Nein', new.ne_checked, new.vid, new._adresse_id;
				--end if;--################################
				raise notice '=> 3-a';
				if  dns_validate_new_abscluss_id(new._abschluss_id, new.cluster)=false then
					select pop_error(E'Error_dns : The _abschluss_id is not found in the given schema. \n  Either the schema does not exists, or the project is not registered(no table abschlusspunkte), or the given id is not found!  ');
					return null;
				else
					execute('select knoten_id from '||sch||'.abschlusspunkte where id=$1;') using new._abschluss_id   into kn;-- knoten_id of the abschlusspunkt
					new._knoten_id_:=kn;
					execute('select bez from '||sch||'.knoten where id=$1 ;')     using kn into new._abschluss_bez_;
					select dns_get_rohr_verbindung(kn, sch) into ans;
					select (ans[3])::uuid into new._nvt_;
					execute('select bez from '||sch||'.knoten where id=$1 ;')     using (ans[3])::uuid into new._nvt_bez_;
					new._verbindung_:=ans[2];
					new._farbe_seq_:=ans[1];
					new._verbindung_id_:=ans[4];
					--??new._trig:='master';--??
					new._trig:='dv';
					return new;
				end if;
			elsif new._abschluss_id is null and old._abschluss_id is not null then
				raise notice '=> 3-b';
				----################################
				--if old.ne_checked<>new.ne_checked or old.adresse_checked<>new.adresse_checked or old.vid<>new.vid then
				--	execute('
				--			update adressen.adressen tar set
				--			adresse_checked= (select case when $1=true then $2 else $3 End)
				--			, ne_checked= (select case when $4=True then $2 else $3 end)
				--			, vid= $5
				--			where tar.id=$6;
				--		')using new.adresse_checked, 'Ja', 'Nein', new.ne_checked, new.vid, new._adresse_id;
				--end if;--################################
				new._knoten_id_:=Null;
				new._abschluss_bez_:=Null;
				new.status_ap:='unplanned';
				new._nvt_:=Null;
				new._nvt_bez_:=Null;
				new.status_nvt:='unplanned';
				new._verbindung_:=Null;
				new._farbe_seq_:=Null;
				new._verbindung_id_:=Null;
				--??new._trig:='master';--??
				new._trig:='dv';
				new.cluster:= Null::integer;
				--execute('
				--		update adressen.adressen tar set
				--		adresse_checked= (select case when $1=true then $2 else $3 End)
				--		, ne_checked= (select case when $4=True then $2 else $3 end)
				--		, vid= $5
				--		where tar.id=$6;
				--	')using new.adresse_checked, 'Ja', 'Nein', new.ne_checked, new.vid, new._adresse_id;
				return new;
			elsif ((new._abschluss_id is null and old._abschluss_id is null) or new._abschluss_id=old._abschluss_id) 
				and not (
				(NEW._knoten_id_ = OLD._knoten_id_ or ((NEW._knoten_id_ is null) and (OLD._knoten_id_ is null)))
				and (NEW._verbindung_ = OLD._verbindung_ or ((NEW._verbindung_ is null) and (OLD._verbindung_ is null))) 
				and (NEW._farbe_seq_ = OLD._farbe_seq_ or ((NEW._farbe_seq_ is null) and (OLD._farbe_seq_ is null)))
				and (NEW._nvt_ = OLD._nvt_ or ((NEW._nvt_ is null) and (OLD._nvt_ is null)))
				and (NEW._nvt_bez_ = OLD._nvt_bez_ or ((NEW._nvt_bez_ is null) and (OLD._nvt_bez_ is null)))
				and (NEW._abschluss_bez_ = OLD._abschluss_bez_ or ((NEW._abschluss_bez_ is null) and (OLD._abschluss_bez_ is null)))
				and (NEW._verbindung_id_ = OLD._verbindung_id_ or ((NEW._verbindung_id_ is null) and (OLD._verbindung_id_ is null)))
				)then
					raise notice '=> 3-c';
				select pop_error(E'DNS-net_Error \n  **  It is not possible to update fileds with _ at the begining and the end of theeir names!','Update the master table instead.');
				return null;
			end if;
		elsif not bol then	
			raise notice '=> 3-d';
			Select pop_error(E'DNS-net_Error \n    It is not possible to update fields with _ at the begining and the end of theeir names!','Update the master table instead.');
			return null;
		end if;
		raise notice '=> 3-e';
		Execute('
				update adressen.adressen tar set
				adresse_checked= (select case when $1=true then $2 else $3 End)
				, ne_checked= (select case when $4=True then $2 else $3 end)
				, vid= $5
				where tar.id=$6;
			')using new.adresse_checked, 'Ja', 'Nein', new.ne_checked, new.vid, new._adresse_id;
		Execute('update adressen.adresse_abschluss set projekt=$1 ,status_ap=$2, valid_matching=$3, status_nvt=$4 
			where _adresse_id= $5 and (_abschluss_id=$6 or ($6 is null and _abschluss_id is null));
			')using new.projekt, new.status_ap, new.valid_matching, new.status_nvt,	new._adresse_id,new._abschluss_id;
				
			return null;
	ELSE 
		raise notice '=> 4';
		Return Null; 
	END if;
END;
$$ language plpgsql;
drop trigger  if  exists tr_adresseabschluss_before_update on adressen.adresse_abschluss;
CREATE TRIGGER tr_adresseabschluss_before_update
	BEFORE UPDATE ON adressen.adresse_abschluss
		FOR EACH ROW
			EXECUTE PROCEDURE tr_adresseabschluss_before_update();
			
			
			
			