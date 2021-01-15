/*------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	Trigger                                                                                                                                               		  -- 
--	                                                                                                                                                              --  
--	                                                                                                                                                              --  
--	name:		tr_global_adresse_abschluss_before_delete                                                                                                         --     
--	schema:		public                                                                                                                                            --  
--	typ:		Trigger                                                                                                                                           --     
--	cr.date:	02.12.2020                                                                                                                                        --  
--	ed.date:	04.01.2021                                                                                                                                        --  
--	impressionable_tables:                                                                                                                                        --
				adressen.adressen																																  --
--				adressen.adresse_abschluss                                                                                                                        --                                                                                                                                            
--	purpose: 	                                                                                                                                                  --  
--				before delete on "adressen.adresse_abschluss"	                                                     			                                  --                                                                                                             
--	DNS-Net GIS group                                                                                                                                             --  
--*/----------------------------------------------------------------------------------------------------------------------------------------------------------------




create or replace function tr_global_adresse_abschluss_before_delete() returns trigger as $$
declare
	n_adresse integer;
	n_adresse_abschluss integer;
begin
	select count(*) from adressen.adressen where id=old._adresse_id into n_adresse;
	select count(*) from adressen.adresse_abschluss where adressen.adresse_abschluss._adresse_id=old._adresse_id into n_adresse_abschluss;
	if n_adresse=1 and n_adresse_abschluss=1 then
		Execute('Update adressen.adresse_abschluss set _abschluss_id=Null where adressen.adresse_abschluss._adresse_id=$1') using old._adresse_id;
		return Null;
	else
		return old;
	end if ;
	--elsif n_adresse=1 and n_adresse_abschluss>1
end; $$ language plpgsql;


drop trigger if exists tr_global_adresse_abschluss_before_delete on adressen.adresse_abschluss;


create Trigger tr_global_adresse_abschluss_before_delete 
	before delete on adressen.adresse_abschluss
		for each row
			execute procedure tr_global_adresse_abschluss_before_delete();


