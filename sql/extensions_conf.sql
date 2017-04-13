--
-- PostgreSQL database dump
--

-- Dumped from database version 9.1.4
-- Dumped by pg_dump version 9.1.4
-- Started on 2012-09-04 20:05:53 EEST

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

SELECT pg_catalog.setval('extensions_conf_id_seq', 15, true);

COPY extensions_conf (id, context, exten, priority, app, appdata) FROM stdin;
3	default	_X!	3	Hangup	17
6	parkingslot	_X!	1	NoOp	see extensions.conf
2	default	_X!	2	AGI	PearlPBX-route.pl,${CHANNEL},${EXTEN}
1	default	_X!	1	NoOp
7	LocalOffice	_X!	1	NoOp	see extensions.conf
8	PearlPBX_Queue	_X!	1	Queue	PearlPBX,rtT,,,,NetSDS-AGI-integration.pl
\.

-- Completed on 2012-09-04 20:05:53 EEST

--
-- PostgreSQL database dump complete
--

