/*--------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	Rule                                                                                                                                                            --
--	                                                                                                                                                                --
--	                                                                                                                                                                --
--	name:		rule_dv_adressen_berlin_delete                                                                                                                      --
--	schema:		public                                                                                                                                              --
--	typ:		Rule                                                                                                                                                --
--	cr.date:	02.12.2020                                                                                                                                          --
--	ed.date:	03.12.2020                                                                                                                                          --
--	impressionable_tables:                                                                                                                                          --
--				adressen.dv_adressen_berlin                                                                                                                         --                                                                                                    
--	purpose: 	                                                                                                                                                    --
--				On direct deletion on table "adressen.dv_adressen_berlin", it throws an error;                                                                      --                                                                                                   
--	DNS-Net GIS group                                                                                                                                               --
--*/------------------------------------------------------------------------------------------------------------------------------------------------------------------

Drop rule if exists rule_dv_adressen_berlin_delete on adressen.dv_adressen_berlin;

CREATE OR REPLACE RULE rule_dv_adressen_berlin_delete
	AS ON DELETE TO adressen.dv_adressen_berlin
		where exists (select from adressen.adressen where old._id=adressen.adressen.id)
			DO INSTEAD (SELECT pop_error(E'Error \n    It is not possible to delete from Dynamic-View "dv_adressen_berlin" !','DELETE from the master table "adressen.adressen".'));


