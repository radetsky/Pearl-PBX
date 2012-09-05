--
-- PostgreSQL database dump
--

-- Dumped from database version 9.1.4
-- Dumped by pg_dump version 9.1.4
-- Started on 2012-09-05 13:51:38 EEST

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = routing, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

SELECT pg_catalog.setval('route_route_id_seq', 125, true);

--
-- TOC entry 2241 (class 0 OID 24797)
-- Dependencies: 197
-- Data for Name: route; Type: TABLE DATA; Schema: routing; Owner: asterisk
--

COPY route (route_id, route_direction_id, route_step, route_type, route_dest_id, route_sip_id) FROM stdin;
11	4	1	context	8	\N
14	5	1	context	6	\N
16	7	1	lmask	0	\N
\.


-- Completed on 2012-09-05 13:51:38 EEST

--
-- PostgreSQL database dump complete
--

