/*------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	Trigger                                                                                                                                                       --
--	                                                                                                                                                              --
--	                                                                                                                                                              --
--	name:		tr_adressen_insert_dv                                                                                                                             --
--	schema:		public                                                                                                                                            --
--	typ:		Trigger                                                                                                                                           --
--	cr.date:	02.12.2020                                                                                                                                        --
--	ed.date:	03.12.2020                                                                                                                                        --
--	impressionable_tables:                                                                                                                                        --
--				adressen.dv_adressen_brandenburg																								                  --
--				adressen.dv_adressen_berlin                                                                                                                       --
--				adressen.dv_adressen_sachsen_anhalt                                                                                                               --
--	purpose: 	                                                                                                                                                  --
--				After Insert into "adressen.adressen"                                                      			                                              --
--	DNS-Net GIS group                                                                                                                                             --
--*/----------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION tr_adressen_insert_dv() RETURNS TRIGGER AS $$
BEGIN
	if new.bundesland='Berlin' then
		insert into adressen.dv_adressen_berlin (_id, alkis_id, vid, geom, typ, ortsnetzbereiche, gemeinde_name, gemeinde_schluessel, kreis, kreis_nr, bezirk, bezirk_nr, ort, ortsteil, ortsteil_nr, 
				plz, strasse, psn, strassenschluessel, hausnr, adresszusatz, funktion, funktion_kategorie, anzahl_wohneinheit, anzahl_gewerbeeinheit, anzahl_nutzeinheit, aufnahmedatum, 
				adresse_checked, ne_checked, datum_adresse_checked, datum_ne_checked, qualitaet, adresse_status, _x, _y,_trig)
			select
				new.id, new.alkis_id, new.vid,
				--(select geom from adressen._geometry_adresse_25833 where _id=new.id union all select null limit 1 ) geom, 
				st_transform(new.geom, 25833) geom,--#new#
				new.typ, new.ortsnetzbereiche, new.gemeinde_name, new.gemeinde_schluessel, new.kreis, new.kreis_nr, new.bezirk, new.bezirk_nr, new.ort, new.ortsteil, new.ortsteil_nr,
				new.plz, new.strasse, new.psn, new.strassenschluessel, new.hausnr, new.adresszusatz, new.funktion, new.funktion_kategorie, new.anzahl_wohneinheit, new.anzahl_gewerbeeinheit, new.anzahl_nutzeinheit,
				new.aufnahmedatum, new.adresse_checked, new.ne_checked, new.datum_adresse_checked, new.datum_ne_checked, new.qualitaet, new.adresse_status, new._x, new._y,
				'adressen' _trig;
		update adressen.dv_adressen_berlin SET _trig='dv' where _trig='adressen';
		
	elsif new.bundesland='Brandenburg' then
		insert into adressen.dv_adressen_brandenburg (_id, alkis_id, vid, geom, typ, ortsnetzbereiche, gemeinde_name, gemeinde_schluessel, kreis, kreis_nr, bezirk, bezirk_nr, ort, ortsteil, ortsteil_nr, 
				plz, strasse, psn, strassenschluessel, hausnr, adresszusatz, funktion, funktion_kategorie, anzahl_wohneinheit, anzahl_gewerbeeinheit, anzahl_nutzeinheit, aufnahmedatum, 
				adresse_checked, ne_checked, datum_adresse_checked, datum_ne_checked, qualitaet, adresse_status, _x, _y,_trig)
			select
				new.id, new.alkis_id, new.vid,
				--(select geom from adressen._geometry_adresse_25833 where _id=new.id union all select null limit 1 ) geom, 
				st_transform(new.geom, 25833) geom,--#new#
				new.typ, new.ortsnetzbereiche, new.gemeinde_name, new.gemeinde_schluessel, new.kreis, new.kreis_nr, new.bezirk, new.bezirk_nr, new.ort, new.ortsteil, new.ortsteil_nr,
				new.plz, new.strasse, new.psn, new.strassenschluessel, new.hausnr, new.adresszusatz, new.funktion, new.funktion_kategorie, new.anzahl_wohneinheit, new.anzahl_gewerbeeinheit, new.anzahl_nutzeinheit,
				new.aufnahmedatum, new.adresse_checked, new.ne_checked, new.datum_adresse_checked, new.datum_ne_checked, new.qualitaet, new.adresse_status, new._x, new._y,
				'adressen' _trig;
		update adressen.dv_adressen_brandenburg SET _trig='dv' where _trig='adressen';
		
		
	elsif new.bundesland='Sachsen-Anhalt' then
		insert into adressen.dv_adressen_sachsen_anhalt (_id, alkis_id, vid, geom, typ, ortsnetzbereiche, gemeinde_name, gemeinde_schluessel, kreis, kreis_nr, bezirk, bezirk_nr, ort, ortsteil, ortsteil_nr, 
				plz, strasse, psn, strassenschluessel, hausnr, adresszusatz, funktion, funktion_kategorie, anzahl_wohneinheit, anzahl_gewerbeeinheit, anzahl_nutzeinheit, aufnahmedatum, 
				adresse_checked, ne_checked, datum_adresse_checked, datum_ne_checked, qualitaet, adresse_status, _x, _y,_trig)
			select
				new.id, new.alkis_id, new.vid,
				--(select geom from adressen._geometry_adresse_25832 where _id=new.id union all select null limit 1 ) geom, 
				st_transform(new.geom, 25832) geom,--#new#
				new.typ, new.ortsnetzbereiche, new.gemeinde_name, new.gemeinde_schluessel, new.kreis, new.kreis_nr, new.bezirk, new.bezirk_nr, new.ort, new.ortsteil, new.ortsteil_nr,
				new.plz, new.strasse, new.psn, new.strassenschluessel, new.hausnr, new.adresszusatz, new.funktion, new.funktion_kategorie, new.anzahl_wohneinheit, new.anzahl_gewerbeeinheit, new.anzahl_nutzeinheit,
				new.aufnahmedatum, new.adresse_checked, new.ne_checked, new.datum_adresse_checked, new.datum_ne_checked, new.qualitaet, new.adresse_status, new._x, new._y,
				'adressen' _trig;
		update adressen.dv_adressen_sachsen_anhalt SET _trig='dv' where _trig='adressen';
		
	end if;
	RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;



drop trigger if exists tr_adressen_insert_dv on adressen.adressen; 


create trigger tr_adressen_insert_dv
	AFTER insert on adressen.adressen
		for each row
			execute procedure tr_adressen_insert_dv();
