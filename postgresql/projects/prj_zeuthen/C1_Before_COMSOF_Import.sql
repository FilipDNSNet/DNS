/*
Run it before importing comsof tables to the database
This code is to prepare the Schema "COMSOF" for inserting the Comsof's output directly to the Database

Prerequisite:
	- C0_COMSOF_BASE.sql
	- P0_Project_PreProcess.sql

DNS GIS_Group
2-11-2020
*/

DELETE FROM comsof.comsof_metadata; -- it Also drops the tables with "Out_" and "in_" prifix from comsof.

---- Feeding Metadata
--Eichwalde--  insert into comsof.comsof_metadata( datum, bundesland, _epsg_code, destination_cluster, beschreibung) values ( (select Now()), 'Brandenburg', '25833', Null, 'Test_Eichwalde');
insert into comsof.comsof_metadata( datum, bundesland, _epsg_code, destination_cluster, beschreibung) values(2, now(), 'Brandenburg', 25833,3,'Test_Zeuthen');




----                                           Now Import the Comsof output shape files.
