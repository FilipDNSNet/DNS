/*------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	Trigger                                                                                                                                                       --
--	                                                                                                                                                              --
--	                                                                                                                                                              --
--	name:		tr_adressen_delete                                                                                                                                --
--	schema:		public                                                                                                                                            --
--	typ:		Trigger                                                                                                                                           --
--	cr.date:	02.12.2020                                                                                                                                        --
--	ed.date:	04.01.2021                                                                                                                                        --
--	impressionable_tables:                                                                                                                                        --
--				adressen.dv_adressen_brandenburg																								                  --
--				adressen.dv_adressen_berlin                                                                                                                       --
--				adressen.dv_adressen_sachsen_anhalt                                                                                                               --
--				adressen.adresse_abschluss                                                                                                                        --
--	purpose: 	                                                                                                                                                  --
--				After Delete on "adressen.adressen"                                                      			                                              --
--	DNS-Net GIS group                                                                                                                                             --
--*/----------------------------------------------------------------------------------------------------------------------------------------------------------------

drop trigger if exists tr_adressen_delete on adressen.adressen;
drop  function if exists tr_adressen_delete cascade;




CREATE OR REPLace function tr_adressen_delete() returns trigger as $$
--- It effects the tables
--	adressen.dv_adressen_berlin
--	adressen.dv_adressen_brandenburg
--	adressen.dv_adressen_sachsen_anhalt
--	adressen.adresse_abschluss
begin
	---on adressen.adressen
	DELETE FROM adressen.adresse_abschluss  where _adresse_id=old.id;
	
	if old.bundesland='Berlin' then
		delete from adressen.dv_adressen_berlin where _id=OLD.id;
	elsif old.bundesland='Brandenburg' then
		delete from adressen.dv_adressen_brandenburg where _id=OLD.id;
	elsif old.bundesland='Sachsen-Anhalt' then
		delete from adressen.dv_adressen_sachsen_anhalt where _id=OLD.id;
	end if;
	return null;
end;
$$ language plpgsql;


drop trigger if exists tr_adressen_delete on adressen.adressen;


create trigger tr_adressen_delete
	after delete on adressen.adressen
		for each row
			execute procedure tr_adressen_delete();
