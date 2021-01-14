/*------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	Trigger                                                                                                                                                       --
--	                                                                                                                                                              --
--	                                                                                                                                                              --
--	name:		tr_adressen_delete                                                                                                                                --
--	schema:		public                                                                                                                                            --
--	typ:		Trigger                                                                                                                                           --
--	cr.date:	02.12.2020                                                                                                                                        --
--	ed.date:	03.12.2020                                                                                                                                        --
--	impressionable_tables:                                                                                                                                        --
--				adressen.dv_adressen_brandenburg																								                  --
--				adressen.dv_adressen_berlin                                                                                                                       --
--				adressen.dv_adressen_sachsen_anhalt                                                                                                               --
--	purpose: 	                                                                                                                                                  --
--				After Delete on "adressen.adressen"                                                      			                                              --
--	DNS-Net GIS group                                                                                                                                             --
--*/----------------------------------------------------------------------------------------------------------------------------------------------------------------


CREATE OR REPLACE function tr_adressen_delete() returns trigger as $$
begin
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



