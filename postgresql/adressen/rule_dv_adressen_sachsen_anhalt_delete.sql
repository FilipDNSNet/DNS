/*--------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	Rule                                                                                                                                                            --
--	                                                                                                                                                                --
--	                                                                                                                                                                --
--	name:		rule_dv_adressen_sachsen_anhalt_delete                                                                                                                      --
--	schema:		public                                                                                                                                              --
--	typ:		Rule                                                                                                                                                --
--	cr.date:	02.12.2020                                                                                                                                          --
--	ed.date:	03.12.2020                                                                                                                                          --
--	impressionable_tables:                                                                                                                                          --
--				adressen.dv_adressen_sachsen_anhalt                                                                                                                         --                                                                                                    
--	purpose: 	                                                                                                                                                    --
--				On direct deletion on table "adressen.dv_adressen_sachsen_anhalt", it throws an error;                                                                      --                                                                                                   
--	DNS-Net GIS group                                                                                                                                               --
--*/------------------------------------------------------------------------------------------------------------------------------------------------------------------

Drop rule if exists rule_dv_adressen_sachsen_anhalt_delete on adressen.dv_adressen_sachsen_anhalt;


CREATE OR REPLACE RULE rule_dv_adressen_sachsen_anhalt_delete
	AS ON DELETE TO adressen.dv_adressen_sachsen_anhalt
		where exists (select from adressen.adressen where old._id=adressen.adressen.id)
			DO INSTEAD (SELECT pop_error(E'Error \n    It is not possible to delete from Dynamic-View "dv_adressen_sachsen_anhalt" !','DELETE from the master table "adressen.adressen".'));





