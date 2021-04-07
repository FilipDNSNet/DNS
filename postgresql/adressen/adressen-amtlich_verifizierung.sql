-- Track the changes the verification of adresses.
/*------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	Table                                                                                                                                                       --
--	                                                                                                                                                              --
--	                                                                                                                                                              --
--	name:		amtlich_verifizierung                                                                                                                               --
--	schema:		adressen                                                                                                                                            --
--	typ:		Trigger                                                                                                                                           --
--	cr.date:	06.04.2021                                                                                                                                        --
--	ed.date:	06.04.2021                                                                                                                                        --
--	impressionable_tables:                                                                                                                                        --
--				adressen.adresse_adressen                                                                                                                        --
--	purpose: 	                                                                                                                                                  --
--				track Verifizirung                                                      			                                         				     --
--	DNS-Net GIS group                                                                                                                                             --
--*/----------------------------------------------------------------------------------------------------------------------------------------------------------------
create table adressen.amtlich_verifizierung(
	id bigserial primary key,
	uuid uuid,
	vid dom_vid,
	alkis_id dom_adresse_id,
	insert_datum date,
	anfrage_datum date,
	status text default 'Anfrage erforderlich',
	hausnr_verifiziert text,
	flrs_verifiziert text,
	we_verifiziert integer,
	ge_verifiziert integer,
	funktion_verifiziert text,
	contact text,
	beschreibung text,
	constraint fk_amtlich_verifizierung_status foreign key (status) references enum_verifizierungsstatus (val) on update cascade,
	constraint unq_enum_verifizierungsstatus_uuid unique (uuid)
);
