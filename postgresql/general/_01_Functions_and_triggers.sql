/*
This code is define general functions 

It should be run only once.
Not For Each Project.

prerequisites:
	- 00_Public_Tables_and_Values.sql

DNS GIS-Group
24-11-2020
*/


create or replace function pop_error(error_message text default 'Error', hint_text text default '') returns void as $$
BEGIN
	raise exception '%' ,error_message using hint = hint_text;
END;
$$language plpgsql;






create or replace function dns_getcolor(indx integer, std text DEFAULT 'DIN_VDE_0888') returns text as $$
begin
	return (select farbe from _farbcode where std=standard and code=indx union all select NULL limit 1);
End;
$$ LANGUAGE PLPGSQL;



create or replace function dns_message(pretxt text default 'dns', txt text default '-') returns void as $$ 
begin
	raise notice '% : %' ,pretxt, txt;
end;
$$ language plpgsql; 
--select message('as','12')




create or replace function dns_netzwerk_uuid(typ text DEFAULT NULL) returns uuid as $$
DECLARE
	txt varchar(36);
	ret varchar(36);
BEGIN
        select uuid_generate_v4()::text into txt;
		/* prefix 'd1f300' is for example for kable */
		IF lower(typ)='adresse' THEN
			SELECT uuid('d0f0add0'||right(txt,28)) into ret;
		elsif lower(typ)='knoten' THEN 
			SELECT uuid('d0f000'||right(txt,30)) into ret;
		elsif lower(typ)='abschlusspunkte' THEN 
			SELECT uuid('d0f0ab00'||right(txt,28)) into ret;
		elsif lower(typ)='connection_module' THEN 
			SELECT uuid('d0fccc00'||right(txt,28)) into ret;
		elsif lower(typ)='connection_unit' THEN 
			SELECT uuid('d0f0cc00'||right(txt,28)) into ret;
		elsif lower(typ)='connection_element' THEN 
			SELECT uuid('d0f0c0'||right(txt,30)) into ret;
		
		elsif lower(typ)='linear_object' THEN 
			SELECT uuid('d1f000'||right(txt,30)) into ret;
		elsif lower(typ)='trasse' THEN 
			SELECT uuid('d1f111'||right(txt,30)) into ret;
		elsif lower(typ)='rohr' THEN 
			SELECT uuid('d1f200'||right(txt,30)) into ret;
		elsif lower(typ)='microduct' THEN 
			SELECT uuid('d1f222'||right(txt,30)) into ret;
		elsif lower(typ)='kabel' THEN 
			SELECT uuid('d1f300'||right(txt,30)) into ret;
		elsif lower(typ)='faser' THEN 
			SELECT uuid('d1f333'||right(txt,30)) into ret;
		elsif lower(typ)='schutzrohr' THEN 
			SELECT uuid('d1f11220'||right(txt,28)) into ret;
		
		elsif lower(typ)='polygon' THEN 
			SELECT uuid('d2f000'||right(txt,30)) into ret;
			
		elsif lower(typ)='attribute' THEN 
			SELECT uuid('daf000'||right(txt,30)) into ret;
		
		else
			select uuid_generate_v4() into ret;
		end IF;
        RETURN ret;
END;
$$  LANGUAGE plpgsql;





--create or replace function dns_get_rohr_verbindung(id_ende uuid, sch text) returns text[] as $$

--create or replace function dns_get_rohr_verbindung(id_ende uuid, sch text) returns text[] as $$
--declare
--	--this function gets the id(uuid) of a knoten and returns an array of 3 elements.
--	-- e.g. ['bl@gn>rt@gn>bl@gn>rs',     ' label_rohr_1>label_rohr_2 >label_rohr_3 > label_rohr_4',     'source_anf']
--	-- the first is sequence of color_microduct@color_rohr from the source til the given id_ende.  E.g. id_ende is the noten id of  a hausanschluss, and source_anf is the NVT
--	-- the second is the label of the rohrs
--	-- the third is the id of the source-koten in text.
--	ret text[];
--begin
--	execute('with recursive tr as (
--							select   1 as temp, id,case when (select typ from '||sch||'.rohr r where r.id=rohr_id)=$3 then $4 else dns_getcolor(microduct_nr::int)||$2 End|| (select mantel_farbe from '||sch||'.rohr r where r.id=rohr_id) farbe, (select mantel_label from '||sch||'.rohr r where r.id=rohr_id), knoten_anfang from '||sch||'.microduct where bottom_agg_id=$1::text and knoten_ende=$1
--						union
--							select  1, m.id, case when (select typ from '||sch||'.rohr r where r.id=m.rohr_id)=$3 then $4 else dns_getcolor(m.microduct_nr::int)||$2 End|| (select mantel_farbe from '||sch||'.rohr r where r.id=m.rohr_id) , (select mantel_label from '||sch||'.rohr r where r.id=m.rohr_id) , m.knoten_anfang from '||sch||'.microduct  m inner join tr on tr.knoten_anfang=m.knoten_ende  where bottom_agg_id=$1::text 
--						)
--						,sel2 as (select row_number() over (order by temp) ord, * from tr  order by ord desc)
--						, sel3 as (select array_agg(farbe) farbe_ar, array_agg(mantel_label) label_ar, array_agg(knoten_anfang) source from sel2)
--						select array[ array_to_string(farbe_ar,$6,$5) , array_to_string(label_ar,$6,$5) , source[1]::text ] from sel3;' 
--					) using id_ende,'@','Einzelrohr', '',' ','>' into ret;
--	return ret;
--end;
--$$ language plpgsql;
--

--create or replace function dns_get_rohr_verbindung(id_ende uuid, sch text) returns text[] as $$
--declare
--	--this function gets the id(uuid) of a knoten and returns an array of 3 elements.
--	-- e.g. ['bl@gn>rt@gn>bl@gn>rs',     ' label_rohr_1>label_rohr_2 >label_rohr_3 > label_rohr_4',     'source_anf']
--	-- the first is sequence of color_microduct@color_rohr from the source til the given id_ende.  E.g. id_ende is the noten id of  a hausanschluss, and source_anf is the NVT
--	-- the second is the bezeichnung of the rohrs
--	-- the third is the id of the source-koten in text.
--	ret text[];
--begin
--	execute('with recursive tr as (
--							select   1 as temp, id,case when (select typ from '||sch||'.rohr r where r.id=rohr_id)=$3 then $4 else dns_getcolor(microduct_nr::int)||$2 End|| (select mantel_farbe from '||sch||'.rohr r where r.id=rohr_id) farbe, (select bez from '||sch||'.rohr r where r.id=rohr_id), knoten_anfang from '||sch||'.microduct where bottom_agg_id=$1::text and knoten_ende=$1
--						union
--							select  1, m.id, case when (select typ from '||sch||'.rohr r where r.id=m.rohr_id)=$3 then $4 else dns_getcolor(m.microduct_nr::int)||$2 End|| (select mantel_farbe from '||sch||'.rohr r where r.id=m.rohr_id) , (select bez from '||sch||'.rohr r where r.id=m.rohr_id) , m.knoten_anfang from '||sch||'.microduct  m inner join tr on tr.knoten_anfang=m.knoten_ende  where bottom_agg_id=$1::text 
--						)
--						,sel2 as (select row_number() over (order by temp) ord, * from tr  order by ord desc)
--						, sel3 as (select array_agg(farbe) farbe_ar, array_agg(bez) bez_ar, array_agg(knoten_anfang) source from sel2)
--						select array[ array_to_string(farbe_ar,$6,$5) , array_to_string(bez_ar,$6,$5) , source[1]::text ] from sel3;' 
--					) using id_ende,'@','Einzelrohr', '',' ','>' into ret;
--	return ret;
--end;
--$$ language plpgsql;
--
--select dns_get_rohr_verbindung(7607, 'comsof')


create or replace function dns_get_rohr_verbindung(id_ende uuid, sch text) returns text[] as $$
declare
	--this function gets the id(uuid) of a knoten and returns an array of 4 elements.
	-- e.g. ['bl@gn>rt@gn>bl@gn>rs',     ' label_rohr_1>label_rohr_2 >label_rohr_3 > label_rohr_4',     'source_anf', 'microduct_id_1>microduct_id_2>...>drom_microduct']
	-- the first is sequence of color_microduct@color_rohr from the source til the given id_ende.  E.g. id_ende is the noten id of  a hausanschluss, and source_anf is the NVT
	-- the second is the bezeichnung of the rohrs
	-- the third is the id of the source-koten in text.
	-- the force is the id of microducts
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

select dns_get_rohr_verbindung(uuid('d0f000f8-2bd9-4d3b-aba6-fabcb5653fac'), 'prj_test_eichwalde')






with recursive tr as (
							select   1 as temp, id,case when (select typ from prj_test_eichwalde.rohr r where r.id=rohr_id)='Einzelrohr' then '' else dns_getcolor(microduct_nr::int)||'@' End|| (select mantel_farbe from prj_test_eichwalde.rohr r where r.id=rohr_id) farbe, (select bez from prj_test_eichwalde.rohr r where r.id=rohr_id), knoten_anfang from prj_test_eichwalde.microduct where bottom_agg_id=uuid('d0f00001-1223-44a5-b4d2-5536fdb7e9cb')::text and knoten_ende=uuid('d0f00001-1223-44a5-b4d2-5536fdb7e9cb')
						union
							select  1, m.id, case when (select typ from prj_test_eichwalde.rohr r where r.id=m.rohr_id)='Einzelrohr' then '' else dns_getcolor(m.microduct_nr::int)||'@' End|| (select mantel_farbe from prj_test_eichwalde.rohr r where r.id=m.rohr_id) , (select bez from prj_test_eichwalde.rohr r where r.id=m.rohr_id) , m.knoten_anfang from prj_test_eichwalde.microduct  m inner join tr on tr.knoten_anfang=m.knoten_ende  where bottom_agg_id=uuid('d0f00001-1223-44a5-b4d2-5536fdb7e9cb')::text 
						)
						,sel2 as (select row_number() over (order by temp) ord, * from tr  order by ord desc)
						, sel3 as (select array_agg(farbe) farbe_ar, array_agg(bez) label_ar, array_agg(knoten_anfang) source from sel2)
						select array[ array_to_string(farbe_ar,'>',' ') , array_to_string(label_ar,'>',' ') , source[1]::text ] from sel3;





create or replace function dns_get_next_branching_rohr_label (label text) returns text as $$
declare
	ret text;
	val text;
	temp text;
begin
	select right(label, 1) into temp;
	--if temp=any(ARRAY['-','/','_']) then
	--	select left(right(label, 2),1) into temp; 
	--end if;
	if temp= ANY(Array['0','1','2','3','4','5','6','7','8','9']) then
		select  label||'-a' into ret;
	elsif temp='a' Then
		select left(label, -1)||'b' into ret;
	elsif temp='b' Then
		select left(label, -1)||'c' into ret;
	elsif temp='c' Then
		select left(label, -1)||'d' into ret;
	elsif temp='d' Then
		select left(label, -1)||'e' into ret;	
	elsif temp='e' Then
		select left(label, -1)||'f' into ret;
	elsif temp='f' Then
		select left(label, -1)||'g' into ret;
	end if;
	return ret;
end;
$$ language plpgsql;
--select dns_get_next_branching_rohr_label('fsdfad/01-a');--  =>  fsdfad/01-b

create or replace function dns_get_alphabet_of_int (val integer) returns varchar(1) as $$
begin
	return (select case 
		when val=1 then 'a'
		when val=2 then 'b'
		when val=3 then 'c'
		when val=4 then 'd'
		when val=5 then 'e'
		when val=6 then 'f'
		when val=7 then 'g'
		when val=8 then 'h'
		when val=9 then 'i'
		when val=10 then 'j'
		when val=11 then 'k'
		when val=12 then 'L'
		when val=13 then 'm'
		when val=14 then 'n'
		when val=15 then 'o'
		when val=16 then 'p'
		when val=17 then 'q'
		when val=18 then 'r'
		when val=19 then 's'
		when val=20 then 't'
		when val=21 then 'u'
		when val=22 then 'v'
		when val=23 then 'w'
		when val=24 then 'x'
		when val=25 then 'y'
		when val=26 then 'z'
		else '*' 
	end);
end;
$$ language plpgsql;
select dns_get_alphabet_of_int(5)



--create or replace function dns_uuid() returns uuid as $$
--DECLARE txt varchar(36);
--BEGIN
--        select uuid_generate_v4()::text into txt;
--
--		/* prefix 001 for example for kable */
--        RETURN uuid('001'||right(txt,33));
--END;
--$$  LANGUAGE plpgsql;
--
/*#####################################################*/



--create or replace function dns_adresse_uuid() returns uuid as $$
--DECLARE txt varchar(36);
--BEGIN
--        select uuid_generate_v4()::text into txt;
--		/* prefix 001 for example for kable */
--        RETURN uuid('df0a'||right(txt,32));
--END;
--$$  LANGUAGE plpgsql;
--





CREATE OR REPLACE FUNCTION auxil_snap_split( lin geometry, pnt geometry , tol numeric) returns geometry as $$
--This function rteturns the multilinestring of splited linestring. use st_numgeometries() to get the number of results.
-- input is Simple ST_Linstring (it does not overlap itself!)
declare
	dis numeric;
	len numeric;
begin
	-- The typ of the object should be linestring
	if lower(st_geometrytype(lin))!='st_linestring' then
		RAISE exception 'Error_ Object should  be st_linestring!!' USING HINT = 'The reference object should be st_linestring!' ;
	end if;
	--The type of pnt should be point
	if lower(st_geometrytype(pnt))!='st_point' then
		RAISE exception 'Error_ Object should  be st_pointstring!!' USING HINT = 'Only point!' ;
	end if;
	--geometries should have the same SRID
	if st_srid(pnt)!=st_srid(lin) THEN
		RAISE exception 'Error_ SRID Conflict!!' USING HINT = 'Both the objects in snap should have the same SRID!' ;
	End if;
	
	select st_distance(pnt, lin) into dis;
	IF dis<=tol then
		select ST_LineLocatePoint( lin  ,  st_snap(pnt, lin, tol)) into len;
		IF Len not in (0, 1) then 
			RETURN st_collect( st_LineSubString(lin, 0, len), st_LineSubString(lin, len,1) );		
		End If;
	END if;
	RETURN st_multi(lin);
End;
$$ language plpgsql;



create or replace function dns_validate_new_abscluss_id(new_id uuid,cluster integer) returns boolean as $$
declare
	-- this function tests if a given id is already stored in the database with the given cluster id or not.
	cnt integer;
	sch text;
begin
	if cluster is null then
		return False;
	end if;
	select schema_name from _cluster where id= cluster into sch;
	if sch is null or sch not in 
		(select s.nspname as table_schema	from pg_catalog.pg_namespace s 	join pg_catalog.pg_user u on u.usesysid = s.nspowner
			where nspname not in ('information_schema', 'pg_catalog')	  and nspname not like 'pg_toast%'	  and nspname not like 'pg_temp_%'	)
		then return False;
	end if;
	execute('select count(id) from '||sch||'.abschlusspunkte where id=$1;') using new_id into cnt;
	if cnt=1 THEN
		return true;
	ELSE
		return false;
	end if;
end;
$$ language plpgsql;
