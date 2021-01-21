-- Stephan and Michael

select 1,  from adressen.adressen where bundesland='Brandenburg' and plz='04932' and strasse='Wiesenweg' and hausnr='1'and adresszusatz is null
union
select 2,  from adressen.adressen where bundesland='Brandenburg' and plz='14542' and strasse='Leester Straße' and hausnr='5'and adresszusatz is null
union
select 3,  from adressen.adressen where bundesland='Brandenburg' and plz='14669' and strasse='Am Deich' and hausnr='50'and adresszusatz is null
union
select 4,  from adressen.adressen where bundesland='Brandenburg' and plz='14669' and strasse='Brandenburger Chaussee' and hausnr='7'and adresszusatz is null
union
select 5,  from adressen.adressen where bundesland='Brandenburg' and plz='16248' and strasse='Ernst-Thälmann-Straße' and hausnr='42'and adresszusatz=''
union
select 6,  from adressen.adressen where bundesland='Sachsen-Anhalt' and plz='39326' and strasse='Kanalstraße' and hausnr='4' and adresszusatz='B'
union
select 7, from adressen.adressen where bundesland='Sachsen-Anhalt' and plz='39326' and strasse='Wiesental' and hausnr='2'and adresszusatz is null



select * from adressen.adressen where bundesland='Brandenburg' and ort='Ketzin' and strasse='Am Deich' and hausnr='50'
select * from (
select count(*) cnt, bundesland,plz, strasse, hausnr, adresszusatz  from adressen.adressen group by bundesland,plz,ort, ortsteil, strasse, hausnr, adresszusatz order by cnt desc 
) sel where cnt>1



select * from adressen.adressen where bundesland='Brandenburg' and plz='14913' and strasse='Dorfstraße' and hausnr='1' and adresszusatz is null --24

select * from adressen.adressen where bundesland='Brandenburg' and plz='01945' and strasse='Hauptstraße' and hausnr='17' and adresszusatz is null --8


cnt	bundesland	plz	strasse	hausnr	adresszusatz
2	Brandenburg	04932	Wiesenweg	1	None
2	Brandenburg	14542	Leester Straße	5	None
2	Brandenburg	14669	Am Deich	50	None
2	Brandenburg	14669	Brandenburger Chaussee	7	None
2	Brandenburg	16248	Ernst-Thälmann-Straße	42	
2	Sachsen-Anhalt	39326	Kanalstraße	4	B
2	Sachsen-Anhalt	39326	Wiesental	2	None

select * from adressen.adressen where bundesland='Brandenburg' and plz='01945' and strasse='Hauptstraße' and hausnr='17' and adresszusatz is null

