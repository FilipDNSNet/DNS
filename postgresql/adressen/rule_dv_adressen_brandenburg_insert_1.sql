/*--------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	Rule                                                                                                                                               			    --
--	                                                                                                                                                                --
--	                                                                                                                                                                --
--	name:		rule_dv_adressen_brandenburg_insert_1                                                                                                               --
--	schema:		public                                                                                                                                              --
--	typ:		Rule                                                                                                                                                --
--	cr.date:	02.12.2020                                                                                                                                          --
--	ed.date:	03.12.2020                                                                                                                                          --
--	impressionable_tables:                                                                                                                                          --
--				adressen.dv_adressen_brandenburg                                                                                                                    --                                                                                                                                          
--	purpose: 	                                                                                                                                                    --
--				On insert into table "adressen.adressen", it insert also insert into "adressen.dv_adressen_brandenburg"                                             --    			                                                                                                                                               
--	DNS-Net GIS group                                                                                                                                               --
--*/------------------------------------------------------------------------------------------------------------------------------------------------------------------

Drop rule if exists rule_dv_adressen_brandenburg_insert_1 on adressen.dv_adressen_brandenburg;

CREATE OR REPLACE RULE rule_dv_adressen_brandenburg_insert_1
	AS ON INSERT TO adressen.dv_adressen_brandenburg
		WHERE NEW._trig='adressen'
			DO ALSO (SELECT 'Inserted Successfully!');

