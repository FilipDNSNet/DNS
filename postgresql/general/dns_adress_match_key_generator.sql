-- for adress matching


CREATE OR REPLACE FUNCTION dns_adress_match_key_generator( plz TEXT,strasse TEXT, nr TEXT, zusatz TEXT DEFAULT '' , ort TEXT DEFAULT '') RETURNS TEXT AS $$
DECLARE 
	-- thiss function receives the strasse , ... and generate the key that for th address that can be used for matching.
	-- example:
	----    select dns_adress_match_key_generator('00000','A-BStraße', '1', 'B','Schönow'); --> schönow00000abstr1b
	----    select dns_adress_match_key_generator('00000','A-BStraße','1'); --> 00000abstr1
	----    select dns_adress_match_key_generator('00000',null,'1'); --> 000001
	ret TEXT;
	ky_plz TEXT;
	ky_strasse TEXT;
	ky_nr TEXT;
	ky_ort TEXT;
	
BEGIN
	--'.',' ','_', '-', 'straße', 'strasse'
	
	select  coalesce(plz,'' ) into ky_plz;
	select 
		replace(
			replace(
				replace(
					replace(
						replace(
							replace(
								replace ( 
									lower( coalesce(strasse,'') ) 
									,'straße', 'str'
								)
								,'strasse', 'str'
							)
							,'-', ''
						)
						,'.', ''
					)
					,',' , ''
				)
				,'_', ''
			)
			,' ', ''
		) into ky_strasse;
	
	select 
		replace(
			replace(
				replace(
					replace(
						replace(
							lower(
								coalesce(nr,'') || coalesce(zusatz, '')
							)
							,'-', ''
						)
						,'.', ''
					)
					,',' , ''
				)
				,'_', ''
			)
			,' ', ''
		) into ky_nr;
	
	select 
		replace(
			replace(
				replace(
					replace(
						replace(
							lower(
								coalesce(ort,'')
							)
							,'-', ''
						)
						,'.', ''
					)
					,',' , ''
				)
				,'_', ''
			)
			,' ', ''
		) into ky_ort;
	
	return ky_ort || ky_plz || ky_strasse || ky_nr ;
		
	
END ;
$$ Language PLPGSQL;