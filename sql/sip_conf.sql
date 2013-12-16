--
-- PostgreSQL database dump
--

-- Dumped from database version 9.1.4
-- Dumped by pg_dump version 9.1.4
-- Started on 2012-09-04 16:40:57 EEST

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET search_path = public, pg_catalog;
SET default_tablespace = '';
SET default_with_oids = false;

SELECT pg_catalog.setval('sip_conf_id_seq', 41, true);

ALTER TABLE ONLY sip_conf ALTER COLUMN id SET DEFAULT nextval('sip_conf_id_seq'::regclass);

COPY sip_conf (id, cat_metric, var_metric, commented, filename, category, var_name, var_val) FROM stdin;
20	0	0	0	sip.conf	general	context	default
21	0	1	0	sip.conf	general	allowoverlap	no
22	0	2	0	sip.conf	general	bindport	5060
23	0	3	0	sip.conf	general	bindaddr	0.0.0.0
24	0	4	0	sip.conf	general	srvlookup	yes
26	0	6	0	sip.conf	general	rtcachefriends	yes
27	0	7	0	sip.conf	general	rtsavesysname	yes
28	0	8	0	sip.conf	general	rtupdate	yes
29	0	9	0	sip.conf	general	rtautoclear	yes
31	0	10	0	sip.conf	general	allowguest	no
30	0	11	0	sip.conf	general	ignoreregexpire	yes
34	0	14	1	sip.conf	general	externip	91.212.154.3
35	0	15	0	sip.conf	general	localnet	192.168.0.0/24
33	0	13	0	sip.conf	general	maxexpiry	3600
32	0	12	0	sip.conf	general	minexpiry	60
36	0	16	0	sip.conf	general	defaultexpiry	3600
\.

insert into sip_conf (cat_metric, var_metric, commented, filename, category, var_name, var_val ) values (0,17,0,'sip.conf','general','videosupport','yes');

insert into sip_conf (cat_metric, var_metric, commented, filename, category, var_name, var_val ) values (0,18,0,'sip.conf','general','alwaysauthreject','yes');

-- Completed on 2012-09-04 16:40:58 EEST

--
-- PostgreSQL database dump complete
--

