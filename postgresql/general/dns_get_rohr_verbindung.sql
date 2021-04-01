
/*------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	Function                                                                                                                                                      --
--	                                                                                                                                                              --
--	                                                                                                                                                              --
--	name:		dns_get_rohr_verbindung                                                                                                                           --            
--	schema:		public                                                                                                                                            --
--	typ:		Function                                                                                                                                          --
--	cr.date:	24-11-2020                                                                                                                                        --
--	ed.date:	24-11-2020                                                                                                                                        --
--	impressionable_tables:                                                                                                                                        --
--				- 										                                                                                                          --
--	purpose: 	                                                                                                                                                  --
--				This function gets the id(uuid) of a knoten and returns an array of 4 elements.                                                                   --
--				e.g. ['bl@gn>rt@gn>bl@gn>rs',                                                                                                                     --
--					' label_rohr_1>label_rohr_2 >label_rohr_3 > label_rohr_4',                                                                                    --
--					'source_anf', 'microduct_id_1>microduct_id_2>...>drom_microduct']                                                                             --
--				The first is sequence of color_microduct@color_rohr from the source til the given id_ende.                                                        --
--					E.g. id_ende is the noten id of  a hausanschluss, and source_anf is the NVT                                                                   --
--				the second is the bezeichnung of the rohrs                                                                                                        --
--				the third is the id of the source-koten in text.                                                                                                  --
--				the force is the id of microducts                                                    			                                                  --
--	DNS-Net GIS group                                                                                                                                             --
--*/----------------------------------------------------------------------------------------------------------------------------------------------------------------


create or replace function dns_get_rohr_verbindung(id_ende uuid, sch text) returns text[] as $$
declare
	--this function gets the id(uuid) of a knoten and returns an array of 4 elements.
	-- e.g. ['bl@gn>rt@gn>bl@gn>rs',
	--		' label_rohr_1>label_rohr_2 >label_rohr_3 > label_rohr_4',     
	--		'source_anf', 'microduct_id_1>microduct_id_2>...>drom_microduct']
	-- The first is sequence of color_microduct@color_rohr from the source til the given id_ende. 
	-- 	E.g. id_ende is the noten id of  a hausanschluss, and source_anf is the NVT
	-- the second is the bezeichnung of the rohrs
	-- the third is the id of the source-koten in text.
	-- the forth is the id of microducts
	ret text[];
begin
	execute('with recursive tr as (
							select   1 as temp, id,case when (select typ from '||sch||'.rohr r where r.id=rohr_id)=$3 then $4 else dns_getcolor(microduct_nr::int)||$2 End|| (select mantel_farbe from '||sch||'.rohr r where r.id=rohr_id) farbe, (select bez from '||sch||'.rohr r where r.id=rohr_id), knoten_anfang from '||sch||'.microduct where bottom_agg_id=$1::text and knoten_ende=$1
						union
							select  1, m.id, case when (select typ from '||sch||'.rohr r where r.id=m.rohr_id)=$3 then $4 else dns_getcolor(m.microduct_nr::int)||$2 End|| (select mantel_farbe from '||sch||'.rohr r where r.id=m.rohr_id) , (select bez from '||sch||'.rohr r where r.id=m.rohr_id) , m.knoten_anfang from '||sch||'.microduct  m inner join tr on tr.knoten_anfang=m.knoten_ende  where bottom_agg_id=$1::text 
						)
						,sel2 as (select row_number() over (order by temp) ord, * from tr  order by ord desc)
						, sel3 as (select array_agg(farbe) farbe_ar, array_agg(bez) bez_ar, array_agg(knoten_anfang) source , array_agg(id) id_ar from sel2)
						select array[ array_to_string(farbe_ar,$6,$5) , array_to_string(bez_ar,$6,$5) , source[1]::text,  array_to_string(id_ar,$6,$5) ] from sel3;' 
					) using id_ende,'@','Einzelrohr', '',' ','>' into ret;
	return ret;
end;
$$ language plpgsql;

--select dns_get_rohr_verbindung(uuid('d0f000f8-2bd9-4d3b-aba6-fabcb5653fac'), 'prj_test_eichwalde')

