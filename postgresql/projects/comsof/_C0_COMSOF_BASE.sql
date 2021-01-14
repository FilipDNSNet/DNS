/*
This code is preprocess before importing the row output of comsof. 
It creates base definition of tables and triggers in the schema "COMSOF"

It should be run only once.
Not For Each Project.

prerequisites:
	- 01_Enums_Domains.sql
	- 01_Functions_and_triggers.sql

DNS GIS-Group2-11-2020
*/

DROP TABLE IF EXISTS comsof.comsof_metadata;
CREATE TABLE comsof.comsof_metadata(
	/*
	This table has only one row. With the value of _id_ to be always 1
	When this row is deleted, all of the other tables get truncated. 
	It is created with som purposes
		- information about the data
		- easy to truncate other tables in comsof
		- Manage EPSG code
	DNS GIS-Group
	15-10-2020
	*/
_id_ integer Primary key Default 1, datum date, bundesland text Not Null ,  _epsg_code dom_5_digit_string Not Null, destination_cluster integer, beschreibung text );
alter table comsof.comsof_metadata add constraint fk_comsof_metadata_cluster foreign key (destination_cluster) references _cluster(id) on update cascade;
alter table comsof.comsof_metadata add constraint fk_comsof_metadata_bundeland foreign key (bundesland) references enum_bundesland(val) on update cascade;
alter table comsof.comsof_metadata add constraint fk_comsof_metadata_epsg foreign key (_epsg_code) references enum_epsg(val) on update cascade;

create or replace function tr_comsof_metadata_one_row_constraint_insert() returns trigger as $$
begin
	if exists (select from comsof.comsof_metadata) then
		execute('select pop_error($1,$2);') using 'Error',E'The "Table comsof.comsof_metadata" can contain one row at a time. First delete the row from it.\n Notice that by delete, all of the tables in the schema "comsof"  might get truncated!!!';
		return Null;
	else
		new._id_ :=1;
		return new;
	end if;
End;
$$ Language PLPGSQL;

DROP Trigger if exists tr_comsof_metadata_one_row_constraint_insert on comsof.comsof_metadata;
CREATE TRIGGER tr_comsof_metadata_one_row_constraint_insert
	before insert on comsof.comsof_metadata
		for each row
			execute procedure tr_comsof_metadata_one_row_constraint_insert();
			
create or replace function tr_comsof_metadata_one_row_constraint_update() returns trigger as $$
begin
	if new._epsg_code <> old._epsg_code then
		execute('select pop_error($1,$2);') using 'Error',E'The column "_epsg_code" cannot get changed.First delete the row, and then insert again.\n Notice that by delete, all of the tables in the schema "comsof"  might get truncated!!!';
	else
		new._id_ :=1;
	End if;
	return new;
End;
$$ Language PLPGSQL;

DROP Trigger if exists tr_comsof_metadata_one_row_constraint_update on comsof.comsof_metadata;
CREATE TRIGGER tr_comsof_metadata_one_row_constraint_update
	before update on comsof.comsof_metadata
		for each row
			execute procedure tr_comsof_metadata_one_row_constraint_update();


create or replace function tr_delete_comsof_metadata() returns trigger as $$
begin
	DROP TABLE IF EXISTS comsof.out_distributionduct CASCADE;
	DROP TABLE IF EXISTS comsof.out_feedercableslack CASCADE;
	DROP TABLE IF EXISTS comsof.out_dropductpieces CASCADE;
	DROP TABLE IF EXISTS comsof.out_splitters CASCADE;
	DROP TABLE IF EXISTS comsof.out_distributionductpieces CASCADE;
	DROP TABLE IF EXISTS comsof.out_feederclusters CASCADE;
	DROP TABLE IF EXISTS comsof.out_droppoints CASCADE;
	DROP TABLE IF EXISTS comsof.out_distributionpoints CASCADE;
	DROP TABLE IF EXISTS comsof.out_distributionroutes CASCADE;
	DROP TABLE IF EXISTS comsof.out_accessstructures CASCADE;
	DROP TABLE IF EXISTS comsof.out_droproutes CASCADE;
	DROP TABLE IF EXISTS comsof.out_usedsegments CASCADE;
	DROP TABLE IF EXISTS comsof.out_edges CASCADE;
	DROP TABLE IF EXISTS comsof.out_closures CASCADE;
	DROP TABLE IF EXISTS comsof.out_dropcableentries CASCADE;
	DROP TABLE IF EXISTS comsof.out_feederduct CASCADE;
	DROP TABLE IF EXISTS comsof.out_feedercableclusters CASCADE;
	DROP TABLE IF EXISTS comsof.out_coaxequipment CASCADE;
	DROP TABLE IF EXISTS comsof.out_feederductpieces CASCADE;
	DROP TABLE IF EXISTS comsof.out_dropcablepieces CASCADE;
	DROP TABLE IF EXISTS comsof.out_feedercableentries CASCADE;
	DROP TABLE IF EXISTS comsof.out_dropcables CASCADE;
	DROP TABLE IF EXISTS comsof.out_feederpoints CASCADE;
	DROP TABLE IF EXISTS comsof.out_demandpoints CASCADE;
	DROP TABLE IF EXISTS comsof.out_feedercablepieces CASCADE;
	DROP TABLE IF EXISTS comsof.out_dropcablesdetail CASCADE;
	DROP TABLE IF EXISTS comsof.out_distributioncableentries CASCADE;
	DROP TABLE IF EXISTS comsof.out_feederroutes CASCADE;
	DROP TABLE IF EXISTS comsof.out_distributioncablepieces CASCADE;
	DROP TABLE IF EXISTS comsof.out_distributioncables CASCADE;
	DROP TABLE IF EXISTS comsof.out_dropcableslack CASCADE;
	DROP TABLE IF EXISTS comsof.out_distributioncablesdetail CASCADE;
	DROP TABLE IF EXISTS comsof.out_distributioncableslack CASCADE;
	DROP TABLE IF EXISTS comsof.out_dropclusters CASCADE;
	DROP TABLE IF EXISTS comsof.out_nodes CASCADE;
	DROP TABLE IF EXISTS comsof.out_feedercables CASCADE;
	DROP TABLE IF EXISTS comsof.out_dropduct CASCADE;
	DROP TABLE IF EXISTS comsof.out_distributionclusters CASCADE;
	DROP TABLE IF EXISTS comsof.out_feedercablesdetail CASCADE;
	DROP TABLE IF EXISTS comsof.in_demandpoints CASCADE;
	return OLD;
End;
$$ language plpgsql;
drop trigger if exists tr_delete_comsof_metadata on comsof.comsof_metadata;
create trigger tr_delete_comsof_metadata 
	after delete on comsof.comsof_metadata
		for each row
			execute procedure tr_delete_comsof_metadata();
