GRANT CONNECT ON DATABASE "'||dbnam||'" TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON ALL TABLES IN SCHEMA '|| schs || ' TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE      TO gr_gesamtnetz_dnsnet_viewer;
GRANT USAGE ON SCHEMA '||schs||' TO gr_gesamtnetz_dnsnet_viewer;


GRANT USAGE ON SCHEMA aa_qgis_projekte To gr_gesamtnetz_dnsnet_viewer;
Grant SELECT ON TABLE aa_qgis_projekte.qgis_projects TO gr_gesamtnetz_dnsnet_viewer;
select access.dns_set_privileges_read('dns_net_geodb', 'b_brb_monitoring', 'projektgebiete', 'gr_gesamtnetz_dnsnet_viewer')

-- Define the user group:
CREATE ROLE gr_gesamtnetz_dnsnet_viewer WITH NOSUPERUSER NOCREATEDB NOLOGIN NOREPLICATION NOCREATEROLE;

--               database  ---------------------------------------------------------------------------------------
GRANT CONNECT ON DATABASE dns_net_geodb TO gr_gesamtnetz_dnsnet_viewer;
GRANT CONNECT ON DATABASE bb_alkis TO gr_gesamtnetz_dnsnet_viewer;
GRANT CONNECT ON DATABASE bb_gbd TO gr_gesamtnetz_dnsnet_viewer;
GRANT CONNECT ON DATABASE d_gbd TO gr_gesamtnetz_dnsnet_viewer;
GRANT CONNECT ON DATABASE adressen TO gr_gesamtnetz_dnsnet_viewer;


-- DB:   dns_net_geodb ---------------------------------------------------------------------------------------
-- Schemas:
GRANT USAGE ON SCHEMA aa_qgis_projekte To gr_gesamtnetz_dnsnet_viewer;
GRANT USAGE ON SCHEMA abstimmung To gr_gesamtnetz_dnsnet_viewer;
GRANT USAGE ON SCHEMA b_brb_monitoring To gr_gesamtnetz_dnsnet_viewer;
GRANT USAGE ON SCHEMA adressen To gr_gesamtnetz_dnsnet_viewer;
GRANT USAGE ON SCHEMA monitoring_dns_net To gr_gesamtnetz_dnsnet_viewer;
GRANT USAGE ON SCHEMA carrier_backbone To gr_gesamtnetz_dnsnet_viewer;
GRANT USAGE ON SCHEMA potentialanalysen To gr_gesamtnetz_dnsnet_viewer;
GRANT USAGE ON SCHEMA st_prj_0216_zba_altmark To gr_gesamtnetz_dnsnet_viewer;
GRANT USAGE ON SCHEMA st_monitoring_arge_boerde To gr_gesamtnetz_dnsnet_viewer;
GRANT USAGE ON SCHEMA basisdaten To gr_gesamtnetz_dnsnet_viewer;
GRANT USAGE ON SCHEMA dns_dienste To gr_gesamtnetz_dnsnet_viewer;
-- Tables:
Grant SELECT ON TABLE aa_qgis_projekte.qgis_projects TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE carrier_backbone."50Hertz_lwl_kabel" TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE adressen.adressen TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE adressen.adressen_nexiga_wgs84 TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE abstimmung.ausbaugebiete_2021 TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE b_brb_monitoring.ausbaugebiete TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE carrier_backbone.avacon_trassen TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE basisdaten.brb_gemeinden TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE basisdaten.brb_landkreise TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE basisdaten.brb_ortsteile TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE monitoring_dns_net.brb_trassen_geplant TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE carrier_backbone.db_metropolregion_b_brb TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE monitoring_dns_net.dns_verfuegbarkeiten_20201021 TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE adressen.dv_adressen_berlin TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE adressen.dv_adressen_brandenburg TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE adressen.dv_adressen_sachsen_anhalt TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE carrier_backbone.ediscom_trassen TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE carrier_backbone."ewe-netz_kfs_50_brb" TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE carrier_backbone.gasline_standorte TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE carrier_backbone.gasline_trasse TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE monitoring_dns_net.gehaeuse_20201016 TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE monitoring_dns_net.gehaeuse_20201028 TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE carrier_backbone.interroute_schaechte TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE carrier_backbone.interroute_trassen TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE monitoring_dns_net.kvz_dns TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE carrier_backbone.lwl_kabel_emb_gasag TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE carrier_backbone.ngn_trassen TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE potentialanalysen.pop_cluster_analysestufe2 TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE potentialanalysen.pop_cluster_analysestufe2 TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE st_prj_0216_zba_altmark.pop_zba_altmark_entwurf TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE monitoring_dns_net.richtfunk_standorte_dns TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE monitoring_dns_net.schaechte_20201016 TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE monitoring_dns_net.schaechte_20201110 TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE basisdaten.st_einheitsgemeinde TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE basisdaten.st_gemeinde TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE basisdaten.st_landkreise_und_kreisfreie_staedte TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE basisdaten.st_stadtteil_kreisfreie_stadt TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE st_monitoring_arge_boerde.st_trassen_arge_boerde_geplante_trassen TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE basisdaten.st_verbandsgemeinde TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE basisdaten.st_wohnflaechen_gewerbe_osm TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE monitoring_dns_net.strassennamen_osm_b_brb TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE monitoring_dns_net.trasse_bb_20200921 TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE monitoring_dns_net.trasse_bb_20210126 TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE st_monitoring_arge_boerde.trasse_los4_pop41 TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE st_monitoring_arge_boerde.trasse_los_2_lk_boerde TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE st_prj_0216_zba_altmark.trasse_zba_cluster1 TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE st_prj_0216_zba_altmark.trassenplan_entwurf TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE st_prj_0216_zba_altmark.trassenplan_entwurf_backbone TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE st_monitoring_arge_boerde.weisse_flecken_202010 TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE st_prj_0216_zba_altmark.zba_weisse_flecken TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE "dns_dienste"."b2b_selfservice" TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE st_monitoring_arge_boerde.trasse_los_2_lk_boerde TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE b_brb_monitoring.projektgebiete TO gr_gesamtnetz_dnsnet_viewer;

-- DB:   bb_alkis  ---------------------------------------------------------------------------------------
-- Schemas:
GRANT USAGE ON SCHEMA zusammenstellungen To gr_gesamtnetz_dnsnet_viewer;
-- Tables:
GRANT SELECT ON TABLE zusammenstellungen.b_flure TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE zusammenstellungen.b_flurstueck TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE zusammenstellungen.b_gemarkung TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE zusammenstellungen.dv_flurstueck_eigentuemer TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE zusammenstellungen.flurstuecke_bb TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE zusammenstellungen.gemarkungen_flure TO gr_gesamtnetz_dnsnet_viewer;


-- DB:	bb_gbd  ---------------------------------------------------------------------------------------
-- Schemas:
GRANT USAGE ON SCHEMA administrativ To gr_gesamtnetz_dnsnet_viewer;
GRANT USAGE ON SCHEMA umwelt To gr_gesamtnetz_dnsnet_viewer;
-- Tables:
GRANT SELECT ON TABLE administrativ.ortznetzbereiche_deutschland_bneta TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE "umwelt"."bbk_fl" TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE "umwelt"."bbk_li" TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE "umwelt"."bbk_pu" TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE "umwelt"."ffh" TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE "umwelt"."gsg_mz_std" TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE "umwelt"."kampfmittelverdachtsflächen2008" TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE "umwelt"."lsg_mz_std" TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE "umwelt"."nsg_mz_std" TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE "umwelt"."oezg_sensible_moore" TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE "umwelt"."spa" TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE "umwelt"."nuthetal_baumkataster" TO gr_gesamtnetz_dnsnet_viewer;


-- DB:	d_gbd  ---------------------------------------------------------------------------------------
-- Schemas:
GRANT USAGE ON SCHEMA db_ag To gr_gesamtnetz_dnsnet_viewer;
-- Tables:
GRANT SELECT ON TABLE db_ag.muffenexport_17022021 TO gr_gesamtnetz_dnsnet_viewer;
GRANT SELECT ON TABLE db_ag.kilometer_db_ag TO gr_gesamtnetz_dnsnet_viewer;

-- DB:	adressen  ---------------------------------------------------------------------------------------
-- Schemas:
GRANT USAGE ON SCHEMA brandenburg To gr_gesamtnetz_dnsnet_viewer;
-- Tables:
GRANT SELECT ON TABLE brandenburg.aemter TO gr_gesamtnetz_dnsnet_viewer;

---------------------------------------------------------------------------------------












--GRANT SELECT ON TABLE carrier_backbone.50Hertz_lwl_kabel TO gr_gesamtnetz_dnsnet_viewer;
--GRANT SELECT ON TABLE adressen.adressenTO gr_gesamtnetz_dnsnet_viewer;
--GRANT SELECT ON TABLE adressen.adressen_nexiga_wgs84 TO gr_gesamtnetz_dnsnet_viewer;
--GRANT SELECT ON TABLE brandenburg.aemter TO gr_gesamtnetz_dnsnet_viewer;
--GRANT SELECT ON TABLE abstimmung.ausbaugebiete_2021TO gr_gesamtnetz_dnsnet_viewer;
--GRANT SELECT ON TABLE b_brb_monitoring.ausbaugebiete TO gr_gesamtnetz_dnsnet_viewer;
--GRANT SELECT ON TABLE carrier_backbone.avacon_trassenTO gr_gesamtnetz_dnsnet_viewer;
--GRANT SELECT ON TABLE zusammenstellungen.b_flure TO gr_gesamtnetz_dnsnet_viewer;
--GRANT SELECT ON TABLE zusammenstellungen.b_flurstueckTO gr_gesamtnetz_dnsnet_viewer;
--GRANT SELECT ON TABLE zusammenstellungen.b_gemarkung TO gr_gesamtnetz_dnsnet_viewer;
--GRANT SELECT ON TABLE basisdaten.brb_gemeinden TO gr_gesamtnetz_dnsnet_viewer;
--GRANT SELECT ON TABLE basisdaten.brb_landkreiseTO gr_gesamtnetz_dnsnet_viewer;
--GRANT SELECT ON TABLE basisdaten.brb_ortsteile TO gr_gesamtnetz_dnsnet_viewer;
--GRANT SELECT ON TABLE monitoring_dns_net.brb_trassen_geplant TO gr_gesamtnetz_dnsnet_viewer;
--GRANT SELECT ON TABLE carrier_backbone.db_metropolregion_b_brb TO gr_gesamtnetz_dnsnet_viewer;
--GRANT SELECT ON TABLE monitoring_dns_net.dns_verfuegbarkeiten_20201021 TO gr_gesamtnetz_dnsnet_viewer;
--GRANT SELECT ON TABLE adressen.dv_adressen_berlinTO gr_gesamtnetz_dnsnet_viewer;
--GRANT SELECT ON TABLE adressen.dv_adressen_brandenburg TO gr_gesamtnetz_dnsnet_viewer;
--GRANT SELECT ON TABLE adressen.dv_adressen_sachsen_anhaltTO gr_gesamtnetz_dnsnet_viewer;
--GRANT SELECT ON TABLE zusammenstellungen.dv_flurstueck_eigentuemer TO gr_gesamtnetz_dnsnet_viewer;
--GRANT SELECT ON TABLE carrier_backbone.ediscom_trassen TO gr_gesamtnetz_dnsnet_viewer;
--GRANT SELECT ON TABLE carrier_backbone.ewe-netz_kfs_50_brb TO gr_gesamtnetz_dnsnet_viewer;
--GRANT SELECT ON TABLE zusammenstellungen.flurstuecke_bbTO gr_gesamtnetz_dnsnet_viewer;
--GRANT SELECT ON TABLE carrier_backbone.gasline_standorte TO gr_gesamtnetz_dnsnet_viewer;
--GRANT SELECT ON TABLE carrier_backbone.gasline_trasseTO gr_gesamtnetz_dnsnet_viewer;
--GRANT SELECT ON TABLE monitoring_dns_net.gehaeuse_20201016 TO gr_gesamtnetz_dnsnet_viewer;
--GRANT SELECT ON TABLE monitoring_dns_net.gehaeuse_20201028 TO gr_gesamtnetz_dnsnet_viewer;
--GRANT SELECT ON TABLE zusammenstellungen.gemarkungen_flure TO gr_gesamtnetz_dnsnet_viewer;
--GRANT SELECT ON TABLE carrier_backbone.interroute_schaechteTO gr_gesamtnetz_dnsnet_viewer;
--GRANT SELECT ON TABLE carrier_backbone.interroute_trassenTO gr_gesamtnetz_dnsnet_viewer;
--GRANT SELECT ON TABLE monitoring_dns_net.kvz_dns TO gr_gesamtnetz_dnsnet_viewer;
--GRANT SELECT ON TABLE carrier_backbone.lwl_kabel_emb_gasag TO gr_gesamtnetz_dnsnet_viewer;
--GRANT SELECT ON TABLE db_ag.muffenexport_17022021TO gr_gesamtnetz_dnsnet_viewer;
--GRANT SELECT ON TABLE carrier_backbone.ngn_trassen TO gr_gesamtnetz_dnsnet_viewer;
--GRANT SELECT ON TABLE administrativ.ortznetzbereiche_deutschland_bneta TO gr_gesamtnetz_dnsnet_viewer;
--GRANT SELECT ON TABLE potentialanalysen.pop_cluster_analysestufe2TO gr_gesamtnetz_dnsnet_viewer;
--GRANT SELECT ON TABLE potentialanalysen.pop_cluster_analysestufe2TO gr_gesamtnetz_dnsnet_viewer;
--GRANT SELECT ON TABLE st_prj_0216_zba_altmark.pop_zba_altmark_entwurfTO gr_gesamtnetz_dnsnet_viewer;
--GRANT SELECT ON TABLE monitoring_dns_net.richtfunk_standorte_dns TO gr_gesamtnetz_dnsnet_viewer;
--GRANT SELECT ON TABLE monitoring_dns_net.schaechte_20201016TO gr_gesamtnetz_dnsnet_viewer;
--GRANT SELECT ON TABLE monitoring_dns_net.schaechte_20201110TO gr_gesamtnetz_dnsnet_viewer;
--GRANT SELECT ON TABLE basisdaten.st_einheitsgemeinde TO gr_gesamtnetz_dnsnet_viewer;
--GRANT SELECT ON TABLE basisdaten.st_gemeinde TO gr_gesamtnetz_dnsnet_viewer;
--GRANT SELECT ON TABLE basisdaten.st_landkreise_und_kreisfreie_staedteTO gr_gesamtnetz_dnsnet_viewer;
--GRANT SELECT ON TABLE basisdaten.st_stadtteil_kreisfreie_stadt TO gr_gesamtnetz_dnsnet_viewer;
--GRANT SELECT ON TABLE st_monitoring_arge_boerde.st_trassen_arge_boerde_geplante_trassenTO gr_gesamtnetz_dnsnet_viewer;
--GRANT SELECT ON TABLE basisdaten.st_verbandsgemeinde TO gr_gesamtnetz_dnsnet_viewer;
--GRANT SELECT ON TABLE basisdaten.st_wohnflaechen_gewerbe_osm TO gr_gesamtnetz_dnsnet_viewer;
--GRANT SELECT ON TABLE monitoring_dns_net.strassennamen_osm_b_brb TO gr_gesamtnetz_dnsnet_viewer;
--GRANT SELECT ON TABLE monitoring_dns_net.trasse_bb_20200921TO gr_gesamtnetz_dnsnet_viewer;
--GRANT SELECT ON TABLE monitoring_dns_net.trasse_bb_20210126TO gr_gesamtnetz_dnsnet_viewer;
--GRANT SELECT ON TABLE st_monitoring_arge_boerde.trasse_los4_pop41TO gr_gesamtnetz_dnsnet_viewer;
--GRANT SELECT ON TABLE st_monitoring_arge_boerde.trasse_los_2_lk_boerde TO gr_gesamtnetz_dnsnet_viewer;
--GRANT SELECT ON TABLE st_prj_0216_zba_altmark.trasse_zba_cluster1TO gr_gesamtnetz_dnsnet_viewer;
--GRANT SELECT ON TABLE st_prj_0216_zba_altmark.trassenplan_entwurfTO gr_gesamtnetz_dnsnet_viewer;
--GRANT SELECT ON TABLE st_prj_0216_zba_altmark.trassenplan_entwurf_backbone TO gr_gesamtnetz_dnsnet_viewer;
--GRANT SELECT ON TABLE st_monitoring_arge_boerde.weisse_flecken_202010TO gr_gesamtnetz_dnsnet_viewer;
--GRANT SELECT ON TABLE st_prj_0216_zba_altmark.zba_weisse_flecken TO gr_gesamtnetz_dnsnet_viewer;















---- -----                   Schemas:
---- -- DB:   dns_net_geodb
---- GRANT USAGE ON SCHEMA carrier_backbone To gr_gesamtnetz_dnsnet_viewer;
---- GRANT USAGE ON SCHEMA adressen To gr_gesamtnetz_dnsnet_viewer;
---- GRANT USAGE ON SCHEMA adressen To gr_gesamtnetz_dnsnet_viewer;
---- GRANT USAGE ON SCHEMA abstimmung To gr_gesamtnetz_dnsnet_viewer;
---- GRANT USAGE ON SCHEMA b_brb_monitoring To gr_gesamtnetz_dnsnet_viewer;
---- GRANT USAGE ON SCHEMA carrier_backbone To gr_gesamtnetz_dnsnet_viewer;
---- GRANT USAGE ON SCHEMA basisdaten To gr_gesamtnetz_dnsnet_viewer;
---- GRANT USAGE ON SCHEMA basisdaten To gr_gesamtnetz_dnsnet_viewer;
---- GRANT USAGE ON SCHEMA basisdaten To gr_gesamtnetz_dnsnet_viewer;
---- GRANT USAGE ON SCHEMA monitoring_dns_net To gr_gesamtnetz_dnsnet_viewer;
---- GRANT USAGE ON SCHEMA carrier_backbone To gr_gesamtnetz_dnsnet_viewer;
---- GRANT USAGE ON SCHEMA monitoring_dns_net To gr_gesamtnetz_dnsnet_viewer;
---- GRANT USAGE ON SCHEMA adressen To gr_gesamtnetz_dnsnet_viewer;
---- GRANT USAGE ON SCHEMA adressen To gr_gesamtnetz_dnsnet_viewer;
---- GRANT USAGE ON SCHEMA adressen To gr_gesamtnetz_dnsnet_viewer;
---- GRANT USAGE ON SCHEMA carrier_backbone To gr_gesamtnetz_dnsnet_viewer;
---- GRANT USAGE ON SCHEMA carrier_backbone To gr_gesamtnetz_dnsnet_viewer;
---- GRANT USAGE ON SCHEMA carrier_backbone To gr_gesamtnetz_dnsnet_viewer;
---- GRANT USAGE ON SCHEMA carrier_backbone To gr_gesamtnetz_dnsnet_viewer;
---- GRANT USAGE ON SCHEMA monitoring_dns_net To gr_gesamtnetz_dnsnet_viewer;
---- GRANT USAGE ON SCHEMA monitoring_dns_net To gr_gesamtnetz_dnsnet_viewer;
---- GRANT USAGE ON SCHEMA carrier_backbone To gr_gesamtnetz_dnsnet_viewer;
---- GRANT USAGE ON SCHEMA carrier_backbone To gr_gesamtnetz_dnsnet_viewer;
---- GRANT USAGE ON SCHEMA monitoring_dns_net To gr_gesamtnetz_dnsnet_viewer;
---- GRANT USAGE ON SCHEMA carrier_backbone To gr_gesamtnetz_dnsnet_viewer;
---- GRANT USAGE ON SCHEMA carrier_backbone To gr_gesamtnetz_dnsnet_viewer;
---- GRANT USAGE ON SCHEMA potentialanalysenTo gr_gesamtnetz_dnsnet_viewer;
---- GRANT USAGE ON SCHEMA potentialanalysenTo gr_gesamtnetz_dnsnet_viewer;
---- GRANT USAGE ON SCHEMA st_prj_0216_zba_altmarkTo gr_gesamtnetz_dnsnet_viewer;
---- GRANT USAGE ON SCHEMA monitoring_dns_net To gr_gesamtnetz_dnsnet_viewer;
---- GRANT USAGE ON SCHEMA monitoring_dns_net To gr_gesamtnetz_dnsnet_viewer;
---- GRANT USAGE ON SCHEMA monitoring_dns_net To gr_gesamtnetz_dnsnet_viewer;
---- GRANT USAGE ON SCHEMA basisdaten To gr_gesamtnetz_dnsnet_viewer;
---- GRANT USAGE ON SCHEMA basisdaten To gr_gesamtnetz_dnsnet_viewer;
---- GRANT USAGE ON SCHEMA basisdaten To gr_gesamtnetz_dnsnet_viewer;
---- GRANT USAGE ON SCHEMA basisdaten To gr_gesamtnetz_dnsnet_viewer;
---- GRANT USAGE ON SCHEMA st_monitoring_arge_boerdeTo gr_gesamtnetz_dnsnet_viewer;
---- GRANT USAGE ON SCHEMA basisdaten To gr_gesamtnetz_dnsnet_viewer;
---- GRANT USAGE ON SCHEMA basisdaten To gr_gesamtnetz_dnsnet_viewer;
---- GRANT USAGE ON SCHEMA monitoring_dns_net To gr_gesamtnetz_dnsnet_viewer;
---- GRANT USAGE ON SCHEMA monitoring_dns_net To gr_gesamtnetz_dnsnet_viewer;
---- GRANT USAGE ON SCHEMA monitoring_dns_net To gr_gesamtnetz_dnsnet_viewer;
---- GRANT USAGE ON SCHEMA st_monitoring_arge_boerdeTo gr_gesamtnetz_dnsnet_viewer;
---- GRANT USAGE ON SCHEMA st_monitoring_arge_boerdeTo gr_gesamtnetz_dnsnet_viewer;
---- GRANT USAGE ON SCHEMA st_prj_0216_zba_altmarkTo gr_gesamtnetz_dnsnet_viewer;
---- GRANT USAGE ON SCHEMA st_prj_0216_zba_altmarkTo gr_gesamtnetz_dnsnet_viewer;
---- GRANT USAGE ON SCHEMA st_prj_0216_zba_altmarkTo gr_gesamtnetz_dnsnet_viewer;
---- GRANT USAGE ON SCHEMA st_monitoring_arge_boerdeTo gr_gesamtnetz_dnsnet_viewer;
---- GRANT USAGE ON SCHEMA st_prj_0216_zba_altmarkTo gr_gesamtnetz_dnsnet_viewer;
---- 
---- -- DB:   bb_alkis
---- GRANT USAGE ON SCHEMA zusammenstellungen To gr_gesamtnetz_dnsnet_viewer;
---- GRANT USAGE ON SCHEMA zusammenstellungen To gr_gesamtnetz_dnsnet_viewer;
---- GRANT USAGE ON SCHEMA zusammenstellungen To gr_gesamtnetz_dnsnet_viewer;
---- GRANT USAGE ON SCHEMA zusammenstellungen To gr_gesamtnetz_dnsnet_viewer;
---- GRANT USAGE ON SCHEMA zusammenstellungen To gr_gesamtnetz_dnsnet_viewer;
---- GRANT USAGE ON SCHEMA zusammenstellungen To gr_gesamtnetz_dnsnet_viewer;
---- 
---- -- DB:	bb_gbd
---- GRANT USAGE ON SCHEMA administrativTo gr_gesamtnetz_dnsnet_viewer;
---- 
---- -- DB:	d_gbd
---- GRANT USAGE ON SCHEMA db_agTo gr_gesamtnetz_dnsnet_viewer;
---- 
---- -- DB:	adressen
---- GRANT USAGE ON SCHEMA brandenburgTo gr_gesamtnetz_dnsnet_viewer;












