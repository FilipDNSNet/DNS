/*--------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	Trigger                                                                                                                                               			--
--	                                                                                                                                                                --
--	                                                                                                                                                                --
--	name:		tr_global_adresseabschluss_before_insert                                                                                                            --
--	schema:		public                                                                                                                                              --
--	typ:		Trigger                                                                                                                                             --
--	cr.date:	05.10.2020                                                                                                                                          --
--	ed.date:	04.01.2021                                                                                                                                          --
--	impressionable_tables:                                                                                                                                          --       
--				adressen.adressen		                                                                                                                            --                                                                                                                                               
--	purpose: 	                                                                                                                                                    --
--				before insert on "adressen.adresse_abschluss "			                                                                                            --            
--	DNS-Net GIS group                                                                                                                                               --
--*/------------------------------------------------------------------------------------------------------------------------------------------------------------------






create or replace function tr_global_adresseabschluss_before_insert() returns trigger as $$
-- for insert an entity to "adressen.adresse_abschluss" it is enough to have valid _adresse_id and optionally (_abschluss_id, cluster)
DECLARE
	sch text;
	kn uuid;
	ans text[];
BEGIN
	if not exists (select from adressen.adressen where id=new._adresse_id) then
		select pop_error(E'DNS-Net Error \n    The id of the address is not found in the table "adressen.adressen"!\n Insert into that table instead. ');
	else
		select vid, alkis_id, strasse, hausnr, adresszusatz, plz, ort, case when adresse_checked='Ja' then True else False End, case when ne_checked='Ja' then True else False End, 'dv'
			from adressen.adressen where id= new._adresse_id into
				NEW.vid , NEW._alkis_id_, NEW._strasse_, NEW._haus_nr_, NEW._adresszusatz_, NEW._plz_, NEW._ort_, NEW.adresse_checked, NEW.ne_checked, new._trig; 
		---- If we have inserted also _abscluss_id and cluster
		if new._abschluss_id is not null and new.cluster is not null and dns_validate_new_abscluss_id(new._abschluss_id, new.cluster)=false then
			select pop_error(E'Error_dns : The _abschluss_id is not found in the given schema. \n  Either the schema does not exists, or the project is not registered(no table abschlusspunkte), or the given id is not found!  ');
		elsif new._abschluss_id is not null and new.cluster is not null and dns_validate_new_abscluss_id(new._abschluss_id, new.cluster)=true then
			select schema_name from _cluster where id= new.cluster into sch;
			execute('select knoten_id from '||sch||'.abschlusspunkte where id=$1;') using new._abschluss_id   into kn;-- knoten_id of the abschlusspunkt
			new._knoten_id_:=kn;
			execute('select bez from '||sch||'.knoten where id=$1 ;')     using kn into new._abschluss_bez_;
			select dns_get_rohr_verbindung(kn, sch) into ans;
			select (ans[3])::uuid into new._nvt_;
			execute('select bez from '||sch||'.knoten where id=$1 ;')     using (ans[3])::uuid into new._nvt_bez_;
			new._verbindung_:=ans[2];
			new._farbe_seq_:=ans[1];
			new._verbindung_id_:=ans[4];
		end if;
	end if;
	return new;
END; $$  language plpgsql;


drop trigger if exists tr_global_adresseabschluss_before_insert on adressen.adresse_abschluss;


create trigger tr_global_adresseabschluss_before_insert
	before insert on adressen.adresse_abschluss 
		for each row 
			execute procedure tr_global_adresseabschluss_before_insert();
			
			
			