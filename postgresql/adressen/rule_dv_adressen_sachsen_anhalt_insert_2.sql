/*--------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	Rule                                                                                                                                               			    --
--	                                                                                                                                                                --
--	                                                                                                                                                                --
--	name:		rule_dv_adressen_sachsen_anhalt_insert_2                                                                                                            --
--	schema:		public                                                                                                                                              --
--	typ:		Rule                                                                                                                                                --
--	cr.date:	02.12.2020                                                                                                                                          --
--	ed.date:	03.12.2020                                                                                                                                          --
--	impressionable_tables:                                                                                                                                          --  
--				adressen.dv_adressen_sachsen_anhalt                                                                                                                 --                                                                                                                                          
--	purpose: 	                                                                                                                                                    --
--				On direct insertion into table "adressen.dv_adressen_sachsen_anhalt", it throws an error;                                                   		--                                                                                                                                           
--	DNS-Net GIS group                                                                                                                                               --
--*/------------------------------------------------------------------------------------------------------------------------------------------------------------------

Drop rule if exists rule_dv_adressen_sachsen_anhalt_insert_2 on adressen.dv_adressen_sachsen_anhalt;



CREATE OR REPLACE RULE rule_dv_adressen_sachsen_anhalt_insert_2
	AS ON INSERT TO adressen.dv_adressen_sachsen_anhalt
		WHERE NEW._trig!='adressen'
			DO INSTEAD (SELECT pop_error(E'Error \n    It is not possible to insert into Dynamic-View "dv_adressen_sachsen_anhalt" !','Insert into the master table "adressen.adressen".'));




