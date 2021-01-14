/*--------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	Rule                                                                                                                                                            --
--	                                                                                                                                                                --
--	                                                                                                                                                                --
--	name:		rule_dv_adressen_brandenburg_delete                                                                                                                 --
--	schema:		public                                                                                                                                              --
--	typ:		Rule                                                                                                                                                --
--	cr.date:	02.12.2020                                                                                                                                          --
--	ed.date:	03.12.2020                                                                                                                                          --
--	impressionable_tables:                                                                                                                                          --
--				adressen.dv_adressen_brandenburg                                                                                                                    --                                                                                                   
--	purpose: 	                                                                                                                                                    --
--				On direct deletion on table "adressen.dv_adressen_brandenburg", it throws an error;                                                                 --                                                                                                  
--	DNS-Net GIS group                                                                                                                                               --
--*/------------------------------------------------------------------------------------------------------------------------------------------------------------------

Drop rule if exists rule_dv_adressen_brandenburg_delete on adressen.dv_adressen_brandenburg;

CREATE OR REPLACE RULE rule_dv_adressen_brandenburg_delete
	AS ON DELETE TO adressen.dv_adressen_brandenburg
		where exists (select from adressen.adressen where old._id=adressen.adressen.id)
			DO INSTEAD (SELECT pop_error(E'Error \n    It is not possible to delete from Dynamic-View "dv_adressen_brandenburg" !','DELETE from the master table "adressen.adressen".'));

