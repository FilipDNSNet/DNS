/*------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	Trigger                                                                                                                                                       --
--	                                                                                                                                                              --
--	                                                                                                                                                              --
--	name:		tr_adressen_adressechecked                                                                                                                        --
--	Database:	dns_net_geodb                                                                                                                                     --
--	schema:		public                                                                                                                                            --
--	typ:		Trigger                                                                                                                                           --
--	cr.date:	03.12.2020                                                                                                                                        --
--	ed.date:	04.01.2021                                                                                                                                       --
--	impressionable_tables:                                                                                                                                        --
--				adressen.adressen                                                                                                                                 --
--	purpose: 	                                                                                                                                                  --
--				Before UPDATE ON  "adressen.adressen"                                                      			                                              --
--	DNS-Net GIS group                                                                                                                                             --
--*/----------------------------------------------------------------------------------------------------------------------------------------------------------------


----- We should not write for insert, because on every insert, it might overide incorrectly the value of that have alredy checked dated	with insertion time			


DROp TRIGGER IF EXISTS  tr_adressen_adressechecked on adressen.adressen;
drop function if exists tr_adressen_adressechecked;

--	CREATE OR REPLACE function tr_adressen_adressechecked() returns trigger as $$
--		BEGIN
--			if new.adresse_checked='Ja' Then 
--				new.datum_adresse_checked=(SELECT now());
--			elsif new.adresse_checked='Nein' Then 
--				new.datum_adresse_checked=Null;
--			end if;
--			return New;
--		END;
--	$$ LANGUAGE PLPGSQL;
--	
--	
--	DROp TRIGGER IF EXISTS  tr_adressen_adressechecked on adressen.adressen;
--	
--	CREATE TRIGGER tr_adressen_adressechecked
--		Before UPDATE ON adressen.adressen
--			For Each ROW
--				EXECUTE PROCEDURE tr_adressen_adressechecked();			
--		