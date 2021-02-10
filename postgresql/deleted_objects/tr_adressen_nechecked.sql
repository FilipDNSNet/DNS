/*------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	Trigger                                                                                                                                                       --
--	                                                                                                                                                              --
--	                                                                                                                                                              --
--	name:		tr_adressen_nechecked                                                                                                                             --
--	Database:	dns_net_geodb                                                                                                                                     --
--	schema:		public                                                                                                                                            --
--	typ:		Trigger                                                                                                                                           --
--	cr.date:	03.12.2020                                                                                                                                        --
--	ed.date:	04.01.2021                                                                                                                                        --
--	impressionable_tables:                                                                                                                                        --
--				adressen.adressen                                                                                                                                 --
--	purpose: 	                                                                                                                                                  --
--				Before UPDATE ON  "adressen.adressen"                                                      			                                              --
--	DNS-Net GIS group                                                                                                                                             --
--*/----------------------------------------------------------------------------------------------------------------------------------------------------------------


----- We should not write for insert, because on every insert, it might overide incorrectly the value of that have alredy checked dated	with insertion time	

DROp TRIGGER IF EXISTS  tr_adressen_nechecked on adressen.adressen;
drop function if exists tr_adressen_nechecked;


--  CREATE OR REPLACE function tr_adressen_nechecked() returns trigger as $$
--  	BEGIN
--  		if new.ne_checked='Ja' Then 
--  			new.datum_ne_checked=(SELECT now());
--  		elsif new.ne_checked='Nein' Then 
--  			new.datum_ne_checked=Null;
--  		end if;
--  		return New;
--  	END;
--  $$ LANGUAGE PLPGSQL;
--  
--  
--  DROp TRIGGER IF EXISTS  tr_adressen_nechecked on adressen.adressen;
--  
--  
--  CREATE TRIGGER tr_adressen_nechecked
--  	Before UPDATE ON adressen.adressen
--  		For Each ROW
--  			EXECUTE PROCEDURE tr_adressen_nechecked();
--  

