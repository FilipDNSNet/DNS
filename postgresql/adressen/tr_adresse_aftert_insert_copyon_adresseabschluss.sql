/*--------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	Trigger                                                                                                                                               			--
--	                                                                                                                                                                --
--	                                                                                                                                                                --
--	name:		tr_adresse_aftert_insert_copyon_adresseabschluss                                                                                                    --
--	schema:		public                                                                                                                                              --
--	typ:		Trigger                                                                                                                                             --
--	cr.date:	05.10.2020                                                                                                                                          --
--	ed.date:	03.12.2020                                                                                                                                          --
--	impressionable_tables:
--				adressen.adressen																																	--       
--				adressen.adresse_abschluss                                                                                                                          --                                                                                                                                               
--	purpose: 	                                                                                                                                                    --
--				....																								                                                --                                                                                
--	DNS-Net GIS group                                                                                                                                               --
--*/------------------------------------------------------------------------------------------------------------------------------------------------------------------





create or replace function tr_adresse_aftert_insert_copyon_adresseabschluss() returns trigger as $$
	begin
		insert into adressen.adresse_abschluss (_adresse_id, vid, _alkis_id_, _strasse_, _haus_nr_, _adresszusatz_, _plz_, _ort_, adresse_checked, ne_checked, _geom_)
				values (new.id, new.vid, new.alkis_id, new.strasse , new.hausnr, new.adresszusatz, new.plz, new.ort, case when lower(new.adresse_checked)=lower('Ja') then True else false end, case when lower(new.ne_checked)=lower('Ja') then True else false end
					--, st_setsrid(st_point(new._wgs84_lon, new._wgs84_lat),4326));
					, new.geom);--#new#
		return new;
	End;
	$$ language plpgsql;


drop trigger if exists tr_adresse_aftert_insert_copyon_adresseabschluss on adressen.adressen;

create trigger tr_adresse_aftert_insert_copyon_adresseabschluss
	after insert on adressen.adressen
		for each row
		execute function tr_adresse_aftert_insert_copyon_adresseabschluss();
