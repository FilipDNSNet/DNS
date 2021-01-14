/*------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	Trigger                                                                                                                                               			    
--	                                                                                                                                                                
--	                                                                                                                                                                
--	name:		tr_dv_adressen_brandenburg_before_update                                                                                                                    
--	schema:		public                                                                                                                                              
--	typ:		Trigger                                                                                                                                                
--	cr.date:	02.12.2020                                                                                                                                          
--	ed.date:	03.12.2020                                                                                                                                          
--	impressionable_tables:
				adressen.adressen																																		
--				adressen.dv_adressen_brandenburg                                                                                                                                                                                                                                                                   
--	purpose: 	                                                                                                                                                    
--				Before update on "adressen.dv_adressen_brandenburg"                                                      			                                                                                                                                               
--	DNS-Net GIS group                                                                                                                                               
--*/----------------------------------------------------------------------------------------------------------------------------------------------------------------



create or replace function tr_dv_adressen_brandenburg_before_update() returns trigger as $$
DECLARE
	t boolean;
BEGIN
	select case 
		when 
			NEW._id = OLD._id 
			AND (NEW.alkis_id = OLD.alkis_id or ((NEW.alkis_id is null) and (OLD.alkis_id is null)))
			AND (NEW.vid = OLD.vid or ((NEW.vid is null) and (OLD.vid is null)))
			AND (NEW.typ = OLD.typ or ((NEW.typ is null) and (OLD.typ is null)))
			AND (NEW.ortsnetzbereiche = OLD.ortsnetzbereiche or ((NEW.ortsnetzbereiche is null) and (OLD.ortsnetzbereiche is null)))
			AND (NEW.gemeinde_name = OLD.gemeinde_name or ((NEW.gemeinde_name is null) and (OLD.gemeinde_name is null)))
			AND (NEW.gemeinde_schluessel = OLD.gemeinde_schluessel or ((NEW.gemeinde_schluessel is null) and (OLD.gemeinde_schluessel is null)))
			AND (NEW.kreis = OLD.kreis or ((NEW.kreis is null) and (OLD.kreis is null)))
			AND (NEW.kreis_nr = OLD.kreis_nr or ((NEW.kreis_nr is null) and (OLD.kreis_nr is null)))
			AND (NEW.bezirk = OLD.bezirk or ((NEW.bezirk is null) and (OLD.bezirk is null)))
			AND (NEW.bezirk_nr = OLD.bezirk_nr or ((NEW.bezirk_nr is null) and (OLD.bezirk_nr is null)))
			AND (NEW.ort = OLD.ort or ((NEW.ort is null) and (OLD.ort is null)))
			AND (NEW.ortsteil = OLD.ortsteil or ((NEW.ortsteil is null) and (OLD.ortsteil is null)))
			AND (NEW.ortsteil_nr = OLD.ortsteil_nr or ((NEW.ortsteil_nr is null) and (OLD.ortsteil_nr is null)))
			AND (NEW.plz = OLD.plz or ((NEW.plz is null) and (OLD.plz is null)))
			AND (NEW.strasse = OLD.strasse or ((NEW.strasse is null) and (OLD.strasse is null)))
			AND (NEW.psn = OLD.psn or ((NEW.psn is null) and (OLD.psn is null)))
			AND (NEW.strassenschluessel = OLD.strassenschluessel or ((NEW.strassenschluessel is null) and (OLD.strassenschluessel is null)))
			AND (NEW.hausnr = OLD.hausnr or ((NEW.hausnr is null) and (OLD.hausnr is null)))
			AND (NEW.adresszusatz = OLD.adresszusatz or ((NEW.adresszusatz is null) and (OLD.adresszusatz is null)))
			AND (NEW.funktion = OLD.funktion or ((NEW.funktion is null) and (OLD.funktion is null)))
			AND (NEW.funktion_kategorie = OLD.funktion_kategorie or ((NEW.funktion_kategorie is null) and (OLD.funktion_kategorie is null)))
			AND (NEW.anzahl_wohneinheit = OLD.anzahl_wohneinheit or ((NEW.anzahl_wohneinheit is null) and (OLD.anzahl_wohneinheit is null)))
			AND (NEW.anzahl_gewerbeeinheit = OLD.anzahl_gewerbeeinheit or ((NEW.anzahl_gewerbeeinheit is null) and (OLD.anzahl_gewerbeeinheit is null)))
			AND (NEW.anzahl_nutzeinheit = OLD.anzahl_nutzeinheit or ((NEW.anzahl_nutzeinheit is null) and (OLD.anzahl_nutzeinheit is null)))
			AND (NEW.aufnahmedatum = OLD.aufnahmedatum or ((NEW.aufnahmedatum is null) and (OLD.aufnahmedatum is null)))
			AND (NEW.adresse_checked = OLD.adresse_checked or ((NEW.adresse_checked is null) and (OLD.adresse_checked is null)))
			AND (NEW.ne_checked = OLD.ne_checked or ((NEW.ne_checked is null) and (OLD.ne_checked is null)))
			AND (NEW.datum_adresse_checked = OLD.datum_adresse_checked or ((NEW.datum_adresse_checked is null) and (OLD.datum_adresse_checked is null)))
			AND (NEW.datum_ne_checked = OLD.datum_ne_checked or ((NEW.datum_ne_checked is null) and (OLD.datum_ne_checked is null)))
			AND (NEW.qualitaet = OLD.qualitaet or ((NEW.qualitaet is null) and (OLD.qualitaet is null)))
			AND (NEW.adresse_status = OLD.adresse_status or ((NEW.adresse_status is null) and (OLD.adresse_status is null)))
			AND (NEW._x = OLD._x or ((NEW._x is null) and (OLD._x is null)))
			AND (NEW._y = OLD._y or ((NEW._y is null) and (OLD._y is null)))
			--AND (ST_INTERSECTS(OLD.geom,new.geom) or ((OLD.geom is null) and (new.geom is null) ))
			AND (ST_equals(OLD.geom,new.geom) or ((OLD.geom is null) and (new.geom is null) )) --#new#
			----AND COALESCE( ST_INTERSECTS(OLD.geom,new.geom),FALSE )
		Then TRUE
		else FALSE END
	into t;
	if (t) Then
		---- only native columns of the dv are updated.
		new._trig:='dv';
		RETURN NEW;
	elsif new._id != old._id  and (OLD._trig='dv' and NEW._trig='dv')  THEN
		Select pop_error(E'Error \n    It is not possible to change uuid from here!','Change id in the master table "adressen.adressen".');
		return null;
	elsif (old._trig='dv' and NEW._trig='adressen') then
		new._trig:='dv';
		RETURN NEW;
	elsif (OLD._trig='dv' and NEW._trig='dv') then
		update adressen.adressen set
				id=new._id 
				,alkis_id =NEW.alkis_id
				,vid =NEW.vid
				,typ =NEW.typ
				,ortsnetzbereiche =NEW.ortsnetzbereiche
				,gemeinde_name =NEW.gemeinde_name
				,gemeinde_schluessel =NEW.gemeinde_schluessel 
				,kreis =NEW.kreis
				,kreis_nr =NEW.kreis_nr
				,bezirk =NEW.bezirk
				,bezirk_nr =NEW.bezirk_nr
				,ort =NEW.ort
				,ortsteil =NEW.ortsteil
				,ortsteil_nr =NEW.ortsteil_nr
				,plz =NEW.plz
				,strasse =NEW.strasse
				,psn=New.psn
				,strassenschluessel =NEW.strassenschluessel
				,hausnr =NEW.hausnr
				,adresszusatz =NEW.adresszusatz
				,funktion =NEW.funktion
				,funktion_kategorie =NEW.funktion_kategorie
				,anzahl_wohneinheit =NEW.anzahl_wohneinheit
				,anzahl_gewerbeeinheit =NEW.anzahl_gewerbeeinheit
				,anzahl_nutzeinheit =NEW.anzahl_nutzeinheit
				,aufnahmedatum =NEW.aufnahmedatum
				,adresse_checked =NEW.adresse_checked
				,ne_checked =NEW.ne_checked
				,datum_adresse_checked =NEW.datum_adresse_checked
				,datum_ne_checked =NEW.datum_ne_checked
				,qualitaet =NEW.qualitaet
				,adresse_status =NEW.adresse_status
				,geom=st_transform(new.geom, 4326)--#new#
			where adressen.id=new._id;
		UPDATE adressen._geometry_adresse_25833 set geom=new.geom where adressen._geometry_adresse_25833._id=new._id;
		RETURN NULL;
	else
		RETURN NULL;
	End if;
END;
$$ language plpgsql;

drop trigger  if  exists tr_dv_adressen_brandenburg_before_update on adressen.dv_adressen_brandenburg;
CREATE TRIGGER tr_dv_adressen_brandenburg_before_update
	BEFORE UPDATE ON adressen.dv_adressen_brandenburg
		FOR EACH ROW
			EXECUTE PROCEDURE tr_dv_adressen_brandenburg_before_update();



