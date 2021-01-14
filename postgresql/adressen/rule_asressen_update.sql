/*--------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	Rule                                                                                                                                                            --
--	                                                                                                                                                                --
--	                                                                                                                                                                --
--	name:		rule_asressen_update                                                                                                                                --
--	schema:		public                                                                                                                                              --
--	typ:		Rule                                                                                                                                                --
--	cr.date:	02.12.2020                                                                                                                                          --
--	ed.date:	03.12.2020                                                                                                                                          --
--	impressionable_tables:                                                                                                                                          --
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
			update adressen.dv_adressen_berlin set
					_id=new.id,
					alkis_id =NEW.alkis_id
					,vid =NEW.vid
					--,geom =(select geom from adressen._geometry_adresse_25833 g where g._id=old.id union all select null limit 1)
					--,geom=(select st_setsrid(  st_point(new._x::numeric, new._y::numeric), new._epsg_code) )
					, geom=st_transform(new.geom, 25833)   --#new#
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
					,_trig='adressen'
				where adressen.dv_adressen_berlin._id=old.id;
			UPDATE adressen.dv_adressen_berlin set _trig='vd' where  _id=new.id;
			
			update adressen.dv_adressen_brandenburg set
					_id=new.id,
					alkis_id =NEW.alkis_id
					,vid =NEW.vid
					--,geom =(select geom from adressen._geometry_adresse_25833 g where g._id=old.id union all select null limit 1)
					--,geom=(select st_setsrid(  st_point(new._x::numeric, new._y::numeric), new._epsg_code) )
					, geom=st_transform(new.geom, 25833)   --#new#
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
					,_trig='adressen'
				where adressen.dv_adressen_brandenburg._id=old.id;
			UPDATE adressen.dv_adressen_brandenburg set _trig='vd' where  _id=new.id;
			
			update adressen.dv_adressen_sachsen_anhalt set
					_id=new.id,
					alkis_id =NEW.alkis_id
					,vid =NEW.vid
					--,geom =(select geom from adressen._geometry_adresse_25832 g where g._id=old.id union all select null limit 1)
					--,geom=(select st_setsrid(  st_point(new._x::numeric, new._y::numeric), new._epsg_code) )
					, geom=st_transform(new.geom, 25832)   --#new#
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
					,_trig='adressen'
				where adressen.dv_adressen_sachsen_anhalt._id=old.id;
			UPDATE adressen.dv_adressen_sachsen_anhalt set _trig='vd' where  _id=new.id;
		);

