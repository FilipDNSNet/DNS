
/*------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	Query                                                                                                                                                         --
--	                                                                                                                                                              --
--	                                                                                                                                                              --
--	name:		--                                                                                                                                                --
--	schema:		--                                                                                                                                                --
--	typ:		Query                                                                                                                                             --
--	cr.date:	24-11-2020                                                                                                                                        --
--	ed.date:	24-11-2020                                                                                                                                        --
--	impressionable_tables:                                                                                                                                        --
--				- 										                                                                                                          --
--	purpose:                                                                                                                                                      --
--				Get report NVT to Hausanschluss	                                                                                                                  --
--				                                                      			                                                                                  --
--	DNS-Net GIS group                                                                                                                                             --
--*/----------------------------------------------------------------------------------------------------------------------------------------------------------------


with recursive tr as (
							select   1 as temp, id,case when (select typ from prj_test_eichwalde.rohr r where r.id=rohr_id)='Einzelrohr' then '' else dns_getcolor(microduct_nr::int)||'@' End|| (select mantel_farbe from prj_test_eichwalde.rohr r where r.id=rohr_id) farbe, (select bez from prj_test_eichwalde.rohr r where r.id=rohr_id), knoten_anfang from prj_test_eichwalde.microduct where bottom_agg_id=uuid('d0f00001-1223-44a5-b4d2-5536fdb7e9cb')::text and knoten_ende=uuid('d0f00001-1223-44a5-b4d2-5536fdb7e9cb')
						union
							select  1, m.id, case when (select typ from prj_test_eichwalde.rohr r where r.id=m.rohr_id)='Einzelrohr' then '' else dns_getcolor(m.microduct_nr::int)||'@' End|| (select mantel_farbe from prj_test_eichwalde.rohr r where r.id=m.rohr_id) , (select bez from prj_test_eichwalde.rohr r where r.id=m.rohr_id) , m.knoten_anfang from prj_test_eichwalde.microduct  m inner join tr on tr.knoten_anfang=m.knoten_ende  where bottom_agg_id=uuid('d0f00001-1223-44a5-b4d2-5536fdb7e9cb')::text 
						)
						,sel2 as (select row_number() over (order by temp) ord, * from tr  order by ord desc)
						, sel3 as (select array_agg(farbe) farbe_ar, array_agg(bez) label_ar, array_agg(knoten_anfang) source from sel2)
						select array[ array_to_string(farbe_ar,'>',' ') , array_to_string(label_ar,'>',' ') , source[1]::text ] from sel3;