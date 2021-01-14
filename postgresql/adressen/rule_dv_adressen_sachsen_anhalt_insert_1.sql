/*--------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	Rule                                                                                                                                               			    --
--	                                                                                                                                                                --
--	                                                                                                                                                                --
--	name:		rule_dv_adressen_sachsen_anhalt_insert_1                                                                                                            --
--	schema:		public                                                                                                                                              --
--	typ:		Rule                                                                                                                                                --
--	cr.date:	02.12.2020                                                                                                                                          --
--	ed.date:	03.12.2020                                                                                                                                          --
--	impressionable_tables:                                                                                                                                          --  
--				adressen.dv_adressen_sachsen_anhalt                                                                                                                 --                                                                                                                                          
--	purpose: 	                                                                                                                                                    --
--				On insert into table "adressen.adressen", it insert also insert into "adressen.dv_adressen_sachsen_anhalt"                                          --    			                                                                                                                                               
--	DNS-Net GIS group                                                                                                                                               --
--*/------------------------------------------------------------------------------------------------------------------------------------------------------------------

Drop rule if exists rule_dv_adressen_sachsen_anhalt_insert_1 on adressen.dv_adressen_sachsen_anhalt;


CREATE OR REPLACE RULE rule_dv_adressen_sachsen_anhalt_insert_1
	AS ON INSERT TO adressen.dv_adressen_sachsen_anhalt
		WHERE NEW._trig='adressen'
			DO ALSO (SELECT 'Inserted Successfully!');

