GRANT USAGE ON SCHEMA aa_qgis_projekte To gr_gesamtnetz_dnsnet_viewer;
Grant SELECT ON TABLE aa_qgis_projekte.qgis_projects TO gr_gesamtnetz_dnsnet_viewer;



CREATE ROLE ruediger_gerndt  WITH NOSUPERUSER NOCREATEDB LOGIN NOREPLICATION NOCREATEROLE PASSWORD  'VWR_re_y1q_22';
grant dns_viewer to ruediger_gerndt;
grant gr_gesamtnetz_dnsnet_viewer to ruediger_gerndt;

CREATE ROLE sebastian_dochan  WITH NOSUPERUSER NOCREATEDB LOGIN NOREPLICATION NOCREATEROLE PASSWORD  'VWR_re_y1q_22';
grant dns_viewer to sebastian_dochan;
grant gr_gesamtnetz_dnsnet_viewer to sebastian_dochan;


CREATE ROLE christian_sieron  WITH NOSUPERUSER NOCREATEDB LOGIN NOREPLICATION NOCREATEROLE PASSWORD  'VWR_tz_cXb_44';
grant dns_viewer to christian_sieron;
grant gr_gesamtnetz_dnsnet_viewer to christian_sieron;


CREATE ROLE christian_feck  WITH NOSUPERUSER NOCREATEDB LOGIN NOREPLICATION NOCREATEROLE PASSWORD  'VWR_tt_wqe_11';
grant dns_viewer to christian_feck;
grant gr_gesamtnetz_dnsnet_viewer to christian_feck;


CREATE ROLE michael_fiel  WITH NOSUPERUSER NOCREATEDB LOGIN NOREPLICATION NOCREATEROLE PASSWORD  'VWR_tt_wqe_11';
grant dns_viewer to michael_fiel;
grant gr_gesamtnetz_dnsnet_viewer to michael_fiel;


CREATE ROLE andre_kehl  WITH NOSUPERUSER NOCREATEDB LOGIN NOREPLICATION NOCREATEROLE PASSWORD  'VWR_et_wqz_21';
grant dns_viewer to andre_kehl;
grant gr_gesamtnetz_dnsnet_viewer to andre_kehl;


CREATE ROLE philipp_stein  WITH NOSUPERUSER NOCREATEDB LOGIN NOREPLICATION NOCREATEROLE PASSWORD  'VWR_ss_wrt_21';
grant dns_viewer to philipp_stein;
grant gr_gesamtnetz_dnsnet_viewer to philipp_stein;


CREATE ROLE norbert_renz  WITH NOSUPERUSER NOCREATEDB LOGIN NOREPLICATION NOCREATEROLE PASSWORD  'VWR_nb_wrk_21';
grant dns_viewer to norbert_renz;
grant gr_gesamtnetz_dnsnet_viewer to norbert_renz;



CREATE ROLE mandy_schalow  WITH NOSUPERUSER NOCREATEDB LOGIN NOREPLICATION NOCREATEROLE PASSWORD  'VWR_ms_wrR_71';
grant dns_viewer to mandy_schalow;
grant gr_gesamtnetz_dnsnet_viewer to mandy_schalow;



CREATE ROLE frank_seyffert  WITH NOSUPERUSER NOCREATEDB LOGIN NOREPLICATION NOCREATEROLE PASSWORD  'VWR_fs_wRR_71';
grant dns_viewer to frank_seyffert;
grant gr_gesamtnetz_dnsnet_viewer to frank_seyffert;



CREATE ROLE anja_hartlieb  WITH NOSUPERUSER NOCREATEDB LOGIN NOREPLICATION NOCREATEROLE PASSWORD  'VWR_ah_wxR_74';
grant dns_viewer to anja_hartlieb;
grant gr_gesamtnetz_dnsnet_viewer to anja_hartlieb;



CREATE ROLE erhard_brix  WITH NOSUPERUSER NOCREATEDB LOGIN NOREPLICATION NOCREATEROLE PASSWORD  'VWR_EG_wzR_74';
grant dns_viewer to erhard_brix;
grant gr_gesamtnetz_dnsnet_viewer to erhard_brix;


CREATE ROLE stefan_holighaus  WITH NOSUPERUSER NOCREATEDB LOGIN NOREPLICATION NOCREATEROLE PASSWORD  'VWR_shM_dzR_74';
grant dns_viewer to stefan_holighaus;
grant gr_gesamtnetz_dnsnet_viewer to stefan_holighaus;




CREATE ROLE thomas_baron  WITH NOSUPERUSER NOCREATEDB LOGIN NOREPLICATION NOCREATEROLE PASSWORD  'VWR_tms_dzR_54';
grant dns_viewer to thomas_baron;
grant gr_gesamtnetz_dnsnet_viewer to thomas_baron;



CREATE ROLE thomas_schubert  WITH NOSUPERUSER NOCREATEDB LOGIN NOREPLICATION NOCREATEROLE PASSWORD  'VWR_KPL_WqY_32';
grant dns_viewer to thomas_schubert;
grant gr_gesamtnetz_dnsnet_viewer to thomas_schubert;



CREATE ROLE katja_franke  WITH NOSUPERUSER NOCREATEDB LOGIN NOREPLICATION NOCREATEROLE PASSWORD  'VWR_kFz_WqY_20';
grant dns_viewer to katja_franke;
grant gr_gesamtnetz_dnsnet_viewer to katja_franke;


CREATE ROLE marion_kuster  WITH NOSUPERUSER NOCREATEDB LOGIN NOREPLICATION NOCREATEROLE PASSWORD  'VWR_mk_KAv_85';
grant dns_viewer to marion_kuster;
grant gr_gesamtnetz_dnsnet_viewer to marion_kuster;


CREATE ROLE friedrich  WITH NOSUPERUSER NOCREATEDB LOGIN NOREPLICATION NOCREATEROLE PASSWORD  'VWR_FE_Ksn_85';
grant dns_viewer to friedrich;
grant gr_gesamtnetz_dnsnet_viewer to friedrich;



grant dns_viewer to benedict;
grant gr_gesamtnetz_dnsnet_viewer to benedict;


grant dns_viewer to victoria;
grant gr_gesamtnetz_dnsnet_viewer to victoria;

grant dns_viewer to tihomir;
grant gr_gesamtnetz_dnsnet_viewer to tihomir;


Alter user daniel with password 'Daniel_R_DNS_net#132';
grant dns_viewer to daniel;
grant gr_gesamtnetz_dnsnet_viewer to daniel;
