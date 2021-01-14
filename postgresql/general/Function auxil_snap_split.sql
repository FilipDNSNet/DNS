
/*------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	Function                                                                                                                                                      --
--	                                                                                                                                                              --
--	                                                                                                                                                              --
--	name:		auxil_snap_split                                                                                                                                  --
--	schema:		public                                                                                                                                            --
--	typ:		Function                                                                                                                                          --
--	cr.date:	24-11-2020                                                                                                                                        --
--	ed.date:	24-11-2020                                                                                                                                        --
--	impressionable_tables:                                                                                                                                        --
--				- 										                                                                                                          --
--	purpose: 	                                                                                                                                                  --
--				-								                                                      			                                                  --
--	DNS-Net GIS group                                                                                                                                             --
--*/----------------------------------------------------------------------------------------------------------------------------------------------------------------


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

