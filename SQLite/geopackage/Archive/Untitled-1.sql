
Insert into  gpkg_spatial_ref_sys  values(
	'ETRS89 / UTM zone 33N',
	25833,
	'EPSG',
	25833,
	'PROJCS["ETRS89 / UTM zone 33N",GEOGCS["ETRS89",DATUM["European_Terrestrial_Reference_System_1989",SPHEROID["GRS 1980",6378137,298.257222101,AUTHORITY["EPSG","7019"]],TOWGS84[0,0,0,0,0,0,0],AUTHORITY["EPSG","6258"]],PRIMEM["Greenwich",0,AUTHORITY["EPSG","8901"]],UNIT["degree",0.0174532925199433,AUTHORITY["EPSG","9122"]],AUTHORITY["EPSG","4258"]],PROJECTION["Transverse_Mercator"],PARAMETER["latitude_of_origin",0],PARAMETER["central_meridian",15],PARAMETER["scale_factor",0.9996],PARAMETER["false_easting",500000],PARAMETER["false_northing",0],UNIT["metre",1,AUTHORITY["EPSG","9001"]],AXIS["Easting",EAST],AXIS["Northing",NORTH],AUTHORITY["EPSG","25833"]]',
	'Cartesian 2D CS. Axes: easting, northing (E,N). Orientations: east, north. UoM: m.'
);

/*create a test geometry*/
create table test_geometry_point (id integer primary key Autoincrement, geom point, val integer not null unique);

insert into gpkg_contents(table_name, data_type,identifier,srs_id) values ('test_geometry_point', 'features','test_geometry_point',25833);
/*
Possible datatypes:
	'tiles','features','attributes'
*/
insert into gpkg_geometry_columns values ('test_geometry_point','geom','POINT',25833, 0, 0 );

/*creation of attribute table*/
create table test(id Integer primary key Autoincrement, val text unique not null); 
/* if the data type (here serial) is not native of sqlite, the datatype is casted, but you cannot edit in Qgis*/
insert into test(val) values ('a');
insert into test(val) values ('b');
insert into test(val) values ('c');
insert into test(val) values ('d');
/*?? Until you dont update the metadata table gpkg_contents. you cannot open this table in qgis*/


insert into gpkg_contents(table_name, data_type,identifier) values ('test', 'attributes','test');

select * from gpkg_contents


/*creation of attribute table*/
create table test1(id integer primary key Autoincrement, val text unique not null);
insert into test1(val) values ('a');
insert into test1(val) values ('b');
insert into test1(val) values ('c');
insert into test1(val) values ('d');
select * from test1;
insert into gpkg_contents(table_name, data_type,identifier) values ('test1', 'attributes','test1');


create table test2(id integer primary key Autoincrement, val text unique not null);
insert into test2(val) values ('a');
insert into test2(val) values ('b');
insert into test2(val) values ('c');
insert into test2(val) values ('d');
select * from test2;
insert into gpkg_contents(table_name, data_type,identifier) values ('test2', 'attributes','test2');


/*Foreign keys*/
create table test_fk (id integer PRIMARY key, val integer AUTOINCREMENT, constraint fk_test_fk foreign key(val) references test1(id) on delete cascade on update cascade);
insert into gpkg_contents(table_name, data_type,identifier) values ('test_fk', 'attributes','test_fk');

Insert into test_fk values(1,1 );
select  * from test_fk;
Insert into test_fk values(2,2);


/*Definition of Index*/
CREATE UNIQUE INDEX idx_contacts_email 
ON contacts (email);
/**Spatial index*/
select * from  gpkg_extensions


commit