--using two source layers we should update the column foerder_status in table "adressen.adressen" ony for 3 Landkreise in Sachsen-Anhalt.
-- The points which lay in the polygons of thesse layer have the value of 'weisse-Flecke' 
-- IOnly for these three Landkreise we can assign other adresses which are note located in the given polygons the value of 'schwarze-Felcke'.
-- 10..02.2021
-- DNS-NET GIS-Team

create table temp_wf (id serial primary key, geom geometry(geometry,4326));
create index inx_temp_wf_geom on temp_wf using GIST(geom);
insert into temp_wf(geom) 
	select st_transform(geom, 4326) from st_prj_0216_zba_altmark.zba_weisse_flecken
	union all
	select st_transform(geom, 4326) from st_monitoring_arge_boerde.weisse_flecken_202010;


update adressen.adressen adr set foerder_status='weisse-Flecke' from temp_wf 
	where adr.bundesland='Sachsen-Anhalt' and adr.kreis in (  'Stendal', 'Altmarkkreis Salzwedel', 'Börde') and st_contains(temp_wf.geom, adr.geom) ;
----- only for these three kreise, the other adresses are schwarz:
update adressen.adressen adr set foerder_status='schwarze-Felcke' 
 	where adr.bundesland='Sachsen-Anhalt'and adr.kreis in (  'Stendal', 'Altmarkkreis Salzwedel', 'Börde') and adr.foerder_status is null;

	
drop table temp_wf;
