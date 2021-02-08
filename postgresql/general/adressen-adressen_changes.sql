-- Changes on the  data-contents of the table "adressen.adressen" update / delete / insert 
-- Not on the structure of the table. The struture of the tabvle is stored in the folder adressen.



------------------------------------------------------------------------------------------------------------------------------------------
---- 08-02-2021 : Update "WE", "GE" values in "adressen.adressen" from nexiga dataset only for those rows of "adressen.adressen" where we
---- are missing "WE", "GE".

update adressen.adressen set 
		anzahl_wohneinheit=(sel.lchh)::integer, anzahl_gewerbeeinheit=(sel.anz_fa)::integer
	from adressen.adressen_nexiga_wgs84 sel
	where sel.oi=alkis_id and (adressen.adressen.anzahl_wohneinheit is null and  adressen.adressen .anzahl_gewerbeeinheit is null)
-------------------------------------------------------------------------------------------------------------------------------------------