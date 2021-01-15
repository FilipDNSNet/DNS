/*--------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	Rule                                                                                                                                               			--
--	                                                                                                                                                                --
--	                                                                                                                                                                --
--	name:		rule_adressen_update_effectson_adresse_abschluss                                                                                                    --
--	schema:		public                                                                                                                                              --
--	typ:		Rule                                                                                                                                             --
--	cr.date:	05.10.2020                                                                                                                                          --
--	ed.date:	04.01.2021                                                                                                                                          --
--	impressionable_tables:
--				adressen.adressen																																	--       
--				adressen.adresse_abschluss                                                                                                                          --                                                                                                                                               
--	purpose: 	                                                                                                                                                    --
--				....																								                                                --                                                                                
--	DNS-Net GIS group                                                                                                                                               --
--*/------------------------------------------------------------------------------------------------------------------------------------------------------------------


drop rule if exists rule_adressen_update_effectson_adresse_abschluss on adressen.adressen;



--		reate or replace RULE rule_adressen_update_effectson_adresse_abschluss
--			as on update to adressen.adressen
--				do ALSO (
--					update adressen.adresse_abschluss set ne_checked=(select case when lower(new.ne_checked) = 'ja' then True else false end)
--										, adresse_checked =(select case when lower(new.adresse_checked) = 'ja' then True else false end)
--										, vid=new.vid
--										, _alkis_id_=new.alkis_id
--										, _strasse_ = new.strasse
--										, _plz_ = new.plz
--										, _haus_nr_=new.hausnr
--										, _adresszusatz_=new.adresszusatz
--										, _ort_=new.ort
--										--, _geom_= st_setsrid(st_point(new._wgs84_lon, new._wgs84_lat),4326)
--										,_geom_ = new.geom ---#new#
--										, _trig='master'  where old.id=_adresse_id ;
--					update view_b_bb.dv_abschluss  set _trig='dv' where _trig!='dv'; 
--				);
--		
--		