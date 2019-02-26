--
-- PostgreSQL database dump
--

-- Dumped from database version 9.1.4
-- Dumped by pg_dump version 9.1.4
-- Started on 2012-09-05 13:50:27 EEST

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = routing, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

select setval('"directions_list_DLIST_ID_seq"'::regclass,21,true);

COPY directions_list (dlist_id, dlist_name) FROM stdin;
4	Express
5	parking slot
6	Local City (Kyiv)
7	Local Office
8	Emergency
9	International
2	KyivStar and InterCity
10	MTS
11	Life
18	Intertelecom 094
\.

-- Completed on 2012-09-05 13:50:27 EEST

--
-- PostgreSQL database dump complete
--

