/*--------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	Table Definition                                                                                                                                                --
--	                                                                                                                                                                --
--	adressen.adresse_abschluss                                                                                                                                      --
--	                                                                                                                                                                --
--	name:		adresse_abschluss                                                                                                                                   --
--	schema:		adressen                                                                                                                                            --
--	typ:		Dynamic-Linked_Table                                                                                                                                --
--	cr.date:	05.10.2020                                                                                                                                          --
--	ed.date:	24.11.2020                                                                                                                                          --
--	impressionable_tables:                                                                                                                                                 --
--				adressen.adressen                                                                                                                                   --
--				prj_##.*                                                                                                                                            --
--	purpose: 	This table is the connection between adressen.adressen, and abschluss_punkte.                                                                       --
--				For each address in "adressen.adressen" we have at least one row in "adressen.adresse_abschluss". If the row corresponging to a specific            --
--				address is deleted, the row stay, instead the value of "_abschluss_id" is set to NULL.												                --
--				We cannot have two rows with the same values of "abschluss_id" and "_adresse_id".            	    												--
--				Each project is registerd in the table "_cluster". For each project, we have the table "prj_###.adresse_abschluss".                                 --
--				There are some typs of columns:                                                                                                                     --
--					"Immanent": These values only belong to the table "adressen.adresse_abschluss". They can get updated.                                           --
--					"Editable-Non-Immanent": These columns are showing valiues from other tables. When you update them, the corresponding values in the             --
--							corresponding table is getting updated too.                                                                                             --
--					"Switchable": These columns references other columns in other tables, these values can only get switch from one value to other. No new          --
--							value can be assigned directly to these columns. (For some of them, it is allowed to be assigned with Null). The name of these          --
--							columns starts with "_".                                                                                                                --
--					"Non-Editable-Non-Immanent": These columns cannot be changed directly in table "adressen.adresse_abschluss". Instead the source table           --
--					should get updted. The name of such a column starts and ends with "_".                                                                          --
--				When the "abschluss_id" is updated with the values from project, the infromation from that project is summarized into                               --
--				"adressen.adresse_abschluss".                                                                                                                       --
--				Note that, when you update "_abschluss_id" in table "adressen.adresse_abschluss", the value of cluster is getting evaluated automatically           --
--				in order to check if the project exists or not. That means, you need to update "_abschluss_id" at the same time with "cluster".                     --
--				When you update "_abschluss_id", Editable-Non-Immanent columns, like "vid", cannot be symultaneously updated with column "_abschluss_id".           --
--				                                                                                                                                                    --
--	DNS-Net GIS group                                                                                                                                               --
--*/------------------------------------------------------------------------------------------------------------------------------------------------------------------


--	drop table if exists adressen.adresse_abschluss cascade;
create table adressen.adresse_abschluss(
	_adresse_id uuid, -- von    adressen.adressen
	vid text,-- von/zu    adressen.adressen
	_alkis_id_ dom_adresse_id,-- von    adressen.adressen
	_strasse_ text,-- von    adressen.adressen
	_haus_nr_  dom_numeric_string,-- von    adressen.adressen
	_adresszusatz_ text,-- von    adressen.adressen
	_plz_ dom_5_digit_string,-- von    adressen.adressen
	_ort_ text,-- von    adressen.adressen
	adresse_checked boolean,-- von/zu    adressen.adressen
	ne_checked boolean,-- von/zu    adressen.adressen
	
	projekt text, -- Inerlich
	cluster integer, -- von    _cluster
	
	_abschluss_id uuid, -- von   prj_xx.abschlusspunkte
	_knoten_id_ uuid,-- von   prj_xx.knoten
	_abschluss_bez_ text, -- von   prj_xx.knoten
	status_ap text Default 'unplanned', -- Inerlich
	valid_matching boolean default null, -- Inerlich (if the adress can be correpond to the abschlussunkt)
	
	_nvt_ uuid, -- von   prj_xx.knoten
	_nvt_bez_ text, -- von   prj_xx.knoten
	status_nvt text DeFAULT 'unplanned' ,		-- Inerlich
	
	_verbindung_id_ text, -- von function "dns_get_rohr_verbindung(knoten_id, schema)" triggered by change on  _cluster, _knoten_id_
	_verbindung_ text, -- von function "dns_get_rohr_verbindung(knoten_id, schema)" triggered by change on _cluster, _knoten_id_
	_farbe_seq_ text, -- von function "dns_get_rohr_verbindung(knoten_id, schema)" triggered by change on  _cluster, _knoten_id_
	
	_geom_ geometry(Point,4326),
	
	_trig text default 'dv',--dv  / master
	constraint pk_dv_abschluss primary key (_adresse_id)
);

ALTER TABLE adressen.adresse_abschluss ADD CONSTRAINT fk_adresseabschluss_adresse FOREIGN KEY (_adresse_id) REFERENCES adressen.adressen(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE adressen.adresse_abschluss ADD CONSTRAINT fk_adresseabschluss_nvtstatus FOREIGN KEY (status_nvt) REFERENCES enum_status_nvt(val) ON UPDATE CASCADE;
ALTER TABLE adressen.adresse_abschluss ADD CONSTRAINT fk_adresseabschluss_apstatus FOREIGN KEY (status_ap) REFERENCES enum_status_ap(val) ON UPDATE CASCADE;
ALTER TABLE adressen.adresse_abschluss ADD CONSTRAINT fk_adresse_abschluss_cluster FOREIGN KEY (cluster) REFERENCES _cluster(id) ON UPDATE CASCADE;

--CREATE INDEX inx_adresseabschluss_adresse_id on adressen.adresse_abschluss(_adresse_id);
	create unique index uinx_adresse_abschluss on adressen.adresse_abschluss(_adresse_id,_abschluss_id);
	CREATE INDEX inx_adresseabschluss_adresse_id on adressen.adresse_abschluss(_adresse_id);
	CREATE INDEX inx_adresseabschluss_abschluss_id on adressen.adresse_abschluss(_abschluss_id);
	CREATE INDEX inx_adresseabschluss_knoten_id on adressen.adresse_abschluss(_knoten_id_);
	CREATE INDEX inx_adresseabschluss_vid on adressen.adresse_abschluss(vid);
	CREATE INDEX inx_adresseabschluss_abschluss_cluster on adressen.adresse_abschluss(cluster);


---Edit: new primary key
	alter table adressen.adresse_abschluss add column fid bigserial;
	alter table adressen.adresse_abschluss drop constraint pk_dv_abschluss;
	alter table adressen.adresse_abschluss add constraint pk_adresse_abschluss primary key (fid);
	create index inx_adresse_abschluss_adresse_id on adressen.adresse_abschluss(_adresse_id);
