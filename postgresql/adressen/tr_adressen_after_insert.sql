/*------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	Trigger                                                                                                                                               		  -- 
--	                                                                                                                                                              --  
--	                                                                                                                                                              --  
--	name:		tr_adressen_after_insert                                                                                                             			  --     
--	schema:		public                                                                                                                                            --  
--	typ:		Trigger                                                                                                                                           --     
--	cr.date:	04.01.2021                                                                                                                                        --  
--	ed.date:	06.04.2021                                                                                                                                        --  
--	impressionable_tables:                                                                                                                                        --
--				adressen.dv_adressen_berlin                                                                                                                       --
--				adressen.dv_adressen_brandenburg                                                                                                                  --
--				adressen.dv_adressen_sachsen_anhalt                                                                                                               --
--				adressen.adresse_abschluss                                                                                                                        --
--	purpose: 	                                                                                                                                                  --  
--				AFTER insert on "adressen.adressen"			                                                     			                                      --                                                                                                  
--	DNS-Net GIS group                                                                                                                                             --  
--*/----------------------------------------------------------------------------------------------------------------------------------------------------------------


CREATE OR REPLACE FUNCTION tr_adressen_after_insert() RETURNS TRIGGER AS $$
-- It effects the tables:
--	adressen.dv_adressen_berlin
--	adressen.dv_adressen_brandenburg
--	adressen.dv_adressen_sachsen_anhalt
--	adressen.adresse_abschluss
BEGIN
	if new.bundesland='Berlin' then
		insert into adressen.dv_adressen_berlin (_id, alkis_id, vid, geom, typ, ortsnetzbereiche, gemeinde_name, gemeinde_schluessel, kreis, kreis_nr, bezirk, bezirk_nr, ort, ortsteil, ortsteil_nr, 
				plz, strasse, psn, strassenschluessel, hausnr, adresszusatz, funktion, funktion_kategorie, anzahl_wohneinheit, anzahl_gewerbeeinheit, anzahl_nutzeinheit, aufnahmedatum, 
				adresse_checked, ne_checked, datum_adresse_checked, datum_ne_checked, qualitaet, adresse_status, _x, _y, verifizierungstyp, analysiert_durch, foerder_status, beschreibung,_trig)
			select
				new.id, new.alkis_id, new.vid,
				st_transform(new.geom, 25833) geom,
				new.typ, new.ortsnetzbereiche, new.gemeinde_name, new.gemeinde_schluessel, new.kreis, new.kreis_nr, new.bezirk, new.bezirk_nr, new.ort, new.ortsteil, new.ortsteil_nr,
				new.plz, new.strasse, new.psn, new.strassenschluessel, new.hausnr, new.adresszusatz, new.funktion, new.funktion_kategorie, new.anzahl_wohneinheit, new.anzahl_gewerbeeinheit, new.anzahl_nutzeinheit,
				new.aufnahmedatum, new.adresse_checked, new.ne_checked, new.datum_adresse_checked, new.datum_ne_checked, new.qualitaet, new.adresse_status, new._x, new._y,
				new.verifizierungstyp, new.analysiert_durch, new.foerder_status, new.beschreibung,
				'adressen' _trig;
		update adressen.dv_adressen_berlin SET _trig='dv' where _trig='adressen';
		
	elsif new.bundesland='Brandenburg' then
		insert into adressen.dv_adressen_brandenburg (_id, alkis_id, vid, geom, typ, ortsnetzbereiche, gemeinde_name, gemeinde_schluessel, kreis, kreis_nr, bezirk, bezirk_nr, ort, ortsteil, ortsteil_nr, 
				plz, strasse, psn, strassenschluessel, hausnr, adresszusatz, funktion, funktion_kategorie, anzahl_wohneinheit, anzahl_gewerbeeinheit, anzahl_nutzeinheit, aufnahmedatum, 
				adresse_checked, ne_checked, datum_adresse_checked, datum_ne_checked, qualitaet, adresse_status, _x, _y, verifizierungstyp, analysiert_durch, foerder_status, beschreibung, _trig)
			select
				new.id, new.alkis_id, new.vid,
				st_transform(new.geom, 25833) geom,
				new.typ, new.ortsnetzbereiche, new.gemeinde_name, new.gemeinde_schluessel, new.kreis, new.kreis_nr, new.bezirk, new.bezirk_nr, new.ort, new.ortsteil, new.ortsteil_nr,
				new.plz, new.strasse, new.psn, new.strassenschluessel, new.hausnr, new.adresszusatz, new.funktion, new.funktion_kategorie, new.anzahl_wohneinheit, new.anzahl_gewerbeeinheit, new.anzahl_nutzeinheit,
				new.aufnahmedatum, new.adresse_checked, new.ne_checked, new.datum_adresse_checked, new.datum_ne_checked, new.qualitaet, new.adresse_status, new._x, new._y,
				new.verifizierungstyp, new.analysiert_durch, new.foerder_status, new.beschreibung,
				'adressen' _trig;
		update adressen.dv_adressen_brandenburg SET _trig='dv' where _trig='adressen';
		
		
	elsif new.bundesland='Sachsen-Anhalt' then
		insert into adressen.dv_adressen_sachsen_anhalt (_id, alkis_id, vid, geom, typ, ortsnetzbereiche, gemeinde_name, gemeinde_schluessel, kreis, kreis_nr, bezirk, bezirk_nr, ort, ortsteil, ortsteil_nr, 
				plz, strasse, psn, strassenschluessel, hausnr, adresszusatz, funktion, funktion_kategorie, anzahl_wohneinheit, anzahl_gewerbeeinheit, anzahl_nutzeinheit, aufnahmedatum, 
				adresse_checked, ne_checked, datum_adresse_checked, datum_ne_checked, qualitaet, adresse_status, _x, _y, verifizierungstyp, analysiert_durch, foerder_status, beschreibung, _trig)
			select
				new.id, new.alkis_id, new.vid,
				st_transform(new.geom, 25832) geom,
				new.typ, new.ortsnetzbereiche, new.gemeinde_name, new.gemeinde_schluessel, new.kreis, new.kreis_nr, new.bezirk, new.bezirk_nr, new.ort, new.ortsteil, new.ortsteil_nr,
				new.plz, new.strasse, new.psn, new.strassenschluessel, new.hausnr, new.adresszusatz, new.funktion, new.funktion_kategorie, new.anzahl_wohneinheit, new.anzahl_gewerbeeinheit, new.anzahl_nutzeinheit,
				new.aufnahmedatum, new.adresse_checked, new.ne_checked, new.datum_adresse_checked, new.datum_ne_checked, new.qualitaet, new.adresse_status, new._x, new._y,
				new.verifizierungstyp, new.analysiert_durch, new.foerder_status, new.beschreibung,
				'adressen' _trig;
		update adressen.dv_adressen_sachsen_anhalt SET _trig='dv' where _trig='adressen';
		
	end if;
	
	--	On adressen.adresse_abschluss
	insert into adressen.adresse_abschluss (_adresse_id, vid, _alkis_id_, _strasse_, _haus_nr_, _adresszusatz_, _plz_, _ort_, adresse_checked, ne_checked, _geom_)
				values (new.id, new.vid, new.alkis_id, new.strasse , new.hausnr, new.adresszusatz, new.plz, new.ort
					, case when lower(new.adresse_checked)=lower('Ja') then True else false end
					, case when lower(new.ne_checked)=lower('Ja') then True else false end
					, new.geom);
	
	if new.verifizierungstyp='unsicher' and lower(new.alkis_id) like 'temp%' then
		insert into adressen.amtlich_verifizierung(uuid, vid, alkis_id,insert_datum, status) values (new.id, new.vid, new.alkis_id, new.aufnahmedatum, 'Anfrage erforderlich');
	end if;
	
	RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;




drop trigger if exists tr_adressen_after_insert on adressen.adressen; 

create trigger tr_adressen_after_insert
	AFTER insert on adressen.adressen
		for each row
			execute procedure tr_adressen_after_insert();
			

