/*--------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	Rule                                                                                                                                                            --
--	                                                                                                                                                                --
--	                                                                                                                                                                --
--	name:		rule_asressen_update                                                                                                                                --
--	schema:		public                                                                                                                                              --
--	typ:		Rule                                                                                                                                                --
--	cr.date:	02.12.2020                                                                                                                                          --
--	ed.date:	09.02.2021                                                                                                                                          --
--	impressionable_tables:                                                                                                                                          --
--				adressen.adressen                                                                                                                                   --
--				adressen.dv_adressen_brandenburg	                                                                                                                --
--				adressen.dv_adressen_brandenburg	                                                                                                                --
--				adressen.dv_adressen_berlin                                                                                                                         --
--				adressen.dv_adressen_sachsen_anhalt                                                                                                                 --
--	purpose: 	                                                                                                                                                    --
--				On update to table "adressen.adressen"                                                                                                              --                                                    
--	DNS-Net GIS group                                                                                                                                               --
--*/------------------------------------------------------------------------------------------------------------------------------------------------------------------


Drop rule if exists rule_asressen_update on adressen.adressen;


CREATE OR REPLACE RULE rule_asressen_update
	AS ON UPDATE TO adressen.adressen
		DO ALSO (
			-- on adressen.adresse_abschluss
			update adressen.adresse_abschluss set ne_checked=(select case when lower(new.ne_checked) = 'ja' then True else false end)
								, adresse_checked =(select case when lower(new.adresse_checked) = 'ja' then True else false end)
								, vid=new.vid
								, _alkis_id_=new.alkis_id
								, _strasse_ = new.strasse
								, _plz_ = new.plz
								, _haus_nr_=new.hausnr
								, _adresszusatz_=new.adresszusatz
								, _ort_=new.ort
								,_geom_ = new.geom
								, _trig='master'  where old.id=_adresse_id ;
			update adressen.adresse_abschluss  set _trig='dv' where _trig!='dv'; 
		
		
			update adressen.dv_adressen_berlin set
					_id=new.id,
					alkis_id =NEW.alkis_id
					,vid =NEW.vid
					, geom=st_transform(new.geom, 25833)
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
					,psn=new.psn
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
					,_x =new._x
					,_y =new._y
					,verifizierungstyp =NEW.verifizierungstyp --on 09.02.2021
					,analysiert_durch =NEW.analysiert_durch --on 09.02.2021
					,foerder_status =NEW.foerder_status --on 09.02.2021
					,beschreibung =NEW.beschreibung		 --on 09.02.2021
					,_trig='adressen'
				where adressen.dv_adressen_berlin._id=old.id;
			UPDATE adressen.dv_adressen_berlin set _trig='vd' where  _id=new.id;
			
			update adressen.dv_adressen_brandenburg set
					_id=new.id,
					alkis_id =NEW.alkis_id
					,vid =NEW.vid
					, geom=st_transform(new.geom, 25833)
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
					,psn=new.psn
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
					,_x =new._x
					,_y =new._y
					,verifizierungstyp =NEW.verifizierungstyp --on 09.02.2021
					,analysiert_durch =NEW.analysiert_durch --on 09.02.2021
					,foerder_status =NEW.foerder_status --on 09.02.2021
					,beschreibung =NEW.beschreibung	 --on 09.02.2021
					,_trig='adressen'
				where adressen.dv_adressen_brandenburg._id=old.id;
			UPDATE adressen.dv_adressen_brandenburg set _trig='vd' where  _id=new.id;
			
			update adressen.dv_adressen_sachsen_anhalt set
					_id=new.id,
					alkis_id =NEW.alkis_id
					,vid =NEW.vid
					, geom=st_transform(new.geom, 25832)
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
					,psn=new.psn
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
					,_x =new._x
					,_y =new._y
					,verifizierungstyp =NEW.verifizierungstyp --on 09.02.2021
					,analysiert_durch =NEW.analysiert_durch --on 09.02.2021
					,foerder_status =NEW.foerder_status --on 09.02.2021
					,beschreibung =NEW.beschreibung	 --on 09.02.2021
					,_trig='adressen'
				where adressen.dv_adressen_sachsen_anhalt._id=old.id;
			UPDATE adressen.dv_adressen_sachsen_anhalt set _trig='vd' where  _id=new.id;
		);


	

