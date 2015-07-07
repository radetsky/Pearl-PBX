--
-- PostgreSQL database dump
--

-- Dumped from database version 9.1.4
-- Dumped by pg_dump version 9.1.4
-- Started on 2012-09-05 13:51:10 EEST

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = routing, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

SELECT pg_catalog.setval('"directions_dr_id_seq"', 92, true);

COPY directions (dr_id, dr_list_item, dr_prefix, dr_prio) FROM stdin;
7	2	^098	5
6	2	^097	5
4	2	^096	5
3	2	^067	5
9	4	^2391515$	5
12	5	^0$	5
13	5	^1\\d$	5
14	5	^\\d$	5
15	5	^\\d\\d$	5
17	5	^1\\d\\d$	5
19	6	^[2-5]\\d\\d\\d\\d\\d\\d$	5
90	9	^99\\d\\d\\d	5
91	18	^094	5
23	8	^910\\d$	5
22	7	^2\\d\\d$	5
25	2	^0[3-6]	5
26	12	^068	4
27	10	^050	4
28	10	^095	4
29	10	^066	4
30	10	^099	4
31	11	^063	4
32	11	^093	4
33	11	^073	4
80	6	^091	5
\.

-- Completed on 2012-09-05 13:51:10 EEST

--
-- PostgreSQL database dump complete
--

