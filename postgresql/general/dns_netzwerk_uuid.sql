
/*------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	Function                                                                                                                                                      --
--	                                                                                                                                                              --
--	                                                                                                                                                              --
--	name:		dns_netzwerk_uuid                                                                                                                                 --
--	schema:		public                                                                                                                                            --
--	typ:		Function                                                                                                                                          --
--	cr.date:	24-11-2020                                                                                                                                        --
--	ed.date:	24-11-2020                                                                                                                                        --
--	impressionable_tables:                                                                                                                                        --
--				- 										                                                                                                          --
--	purpose: 	                                                                                                                                                  --
--				Generate the default value for UUID for different objects	                          			                                                  --
--	DNS-Net GIS group                                                                                                                                             --
--*/----------------------------------------------------------------------------------------------------------------------------------------------------------------


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