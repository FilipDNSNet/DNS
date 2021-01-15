/*--------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	Trigger                                                                                                                                               			--
--	                                                                                                                                                                --
--	                                                                                                                                                                --
--	name:		tr_adresse_abschluss_before_delete                                                                                                                  --
--	schema:		public                                                                                                                                              --
--	typ:		Trigger                                                                                                                                             --
--	cr.date:	05.10.2020                                                                                                                                          --
--	ed.date:	04.01.2021                                                                                                                                          --
--	impressionable_tables:                                                                                                                                          --       
--				adressen.adresse_abschluss                                                                                                                          --                                                                                                                                               
--	purpose: 	                                                                                                                                                    --
--				It can delete until there is at least one _adresse_id for adresses in "adressen.adressen".                                                          --
--				It should be trigger not Rule beacues it should be run for each row.			                                                                    --                                                                                
--	DNS-Net GIS group                                                                                                                                               --
--*/------------------------------------------------------------------------------------------------------------------------------------------------------------------


drop trigger if exists tr_adresse_abschluss_before_delete on adressen.adressen;
drop  function if exists tr_adresse_abschluss_before_delete cascade;


--		create or replace function tr_adresse_abschluss_before_delete() returns trigger as $$
--		begin
--			raise notice '==>> Here: % ', (select count(*) from adressen.adressen where old._adresse_id=adressen.adressen.id) ;
--			if  exists (select count(*) from adressen.adressen where old._adresse_id=adressen.adressen.id) and (select count(*)from adressen.adresse_abschluss adb where old._adresse_id=adb._adresse_id) =1 then
--				SELECT pop_error(E'Error \n   =>> It is not possible to delete from Dynamic-Table "adressen.adresse_abschluss" !','DELETE from the master table "adressen.adressen".');
--			end if;
--			return Old;
--		end;
--		$$ language plpgsql;
--		
--		drop trigger if exists tr_adresse_abschluss_before_delete on adressen.adresse_abschluss;
--		
--		create trigger tr_adresse_abschluss_before_delete
--			before delete on adressen.adresse_abschluss
--				for each row
--					execute procedure tr_adresse_abschluss_before_delete();
--		