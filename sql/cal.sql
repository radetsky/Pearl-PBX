--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- Name: cal; Type: SCHEMA; Schema: -; Owner: asterisk
--

CREATE SCHEMA cal;


ALTER SCHEMA cal OWNER TO asterisk;

--
-- Name: SCHEMA cal; Type: COMMENT; Schema: -; Owner: asterisk
--

COMMENT ON SCHEMA cal IS 'Calendar';


SET search_path = cal, pg_catalog;

--
-- Name: need_work(); Type: FUNCTION; Schema: cal; Owner: asterisk
--

CREATE FUNCTION need_work() RETURNS boolean
    LANGUAGE sql
    AS $$select is_work from cal.timesheet ts
  where
   (now()::time between ts.time_start and ts.time_stop)
  and
   ((date_part('year', now()) = "year") or ("year" is NULL))
  and
   ((date_part('month', now()) = mon) or (mon is NULL))
  and
   ((date_part('day', now()) = mon_day) or (mon_day is NULL))
  and
   ((date_part('dow', now()) = weekday) or (weekday is NULL))
  order by prio asc
  limit 1;$$;


ALTER FUNCTION cal.need_work() OWNER TO asterisk;

--
-- Name: FUNCTION need_work(); Type: COMMENT; Schema: cal; Owner: asterisk
--

COMMENT ON FUNCTION need_work() IS 'Do we need to work now?';


--
-- Name: need_work_group(character varying); Type: FUNCTION; Schema: cal; Owner: asterisk
--

CREATE FUNCTION need_work_group(groupname character varying) RETURNS boolean
    LANGUAGE sql
    AS $_$select is_work from cal.timesheet ts
  where
   (now()::time between ts.time_start and ts.time_stop)
  and
   ((date_part('year', now()) = "year") or ("year" is NULL))
  and
   ((date_part('month', now()) = mon) or (mon is NULL))
  and
   ((date_part('day', now()) = mon_day) or (mon_day is NULL))
  and
   ((date_part('dow', now()) = weekday) or (weekday is NULL))
  and 
   ((group_name = $1) or (group_name is NULL)) 
  order by prio asc
  limit 1;$_$;


ALTER FUNCTION cal.need_work_group(groupname character varying) OWNER TO asterisk;

--
-- Name: FUNCTION need_work_group(groupname character varying); Type: COMMENT; Schema: cal; Owner: asterisk
--

COMMENT ON FUNCTION need_work_group(groupname character varying) IS 'Is need to work group ?';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: timesheet; Type: TABLE; Schema: cal; Owner: asterisk; Tablespace: 
--

CREATE TABLE timesheet (
    id integer NOT NULL,
    weekday smallint,
    mon_day smallint,
    mon smallint,
    year integer,
    time_start time without time zone NOT NULL,
    time_stop time without time zone NOT NULL,
    group_name character varying(64),
    is_work boolean NOT NULL,
    prio integer DEFAULT 1000 NOT NULL
);


ALTER TABLE cal.timesheet OWNER TO asterisk;

--
-- Name: TABLE timesheet; Type: COMMENT; Schema: cal; Owner: asterisk
--

COMMENT ON TABLE timesheet IS 'Time sheet';


--
-- Name: timesheet_id_seq; Type: SEQUENCE; Schema: cal; Owner: asterisk
--

CREATE SEQUENCE timesheet_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE cal.timesheet_id_seq OWNER TO asterisk;

--
-- Name: timesheet_id_seq; Type: SEQUENCE OWNED BY; Schema: cal; Owner: asterisk
--

ALTER SEQUENCE timesheet_id_seq OWNED BY timesheet.id;


--
-- Name: timesheet_id_seq; Type: SEQUENCE SET; Schema: cal; Owner: asterisk
--

SELECT pg_catalog.setval('timesheet_id_seq', 11, true);


--
-- Name: id; Type: DEFAULT; Schema: cal; Owner: asterisk
--

ALTER TABLE timesheet ALTER COLUMN id SET DEFAULT nextval('timesheet_id_seq'::regclass);


--
-- Data for Name: timesheet; Type: TABLE DATA; Schema: cal; Owner: asterisk
--

COPY timesheet (id, weekday, mon_day, mon, year, time_start, time_stop, group_name, is_work, prio) FROM stdin;
8	\N	8	3	\N	00:00:00	24:00:00	\N	f	500
9	\N	\N	\N	\N	00:00:00	24:00:00	\N	f	99999
10	\N	1	1	\N	00:00:00	24:00:00	\N	f	500
1	1	\N	\N	\N	08:00:00	19:00:00	\N	t	1000
4	2	\N	\N	\N	08:00:00	19:00:00	\N	t	1000
5	3	\N	\N	\N	08:00:00	19:00:00	\N	t	1000
6	4	\N	\N	\N	08:00:00	19:00:00	\N	t	1000
7	5	\N	\N	\N	08:00:00	19:00:00	\N	t	1000
11	6	\N	\N	\N	09:00:00	18:00:00	\N	t	1000
\.


--
-- Name: timesheet_pkey; Type: CONSTRAINT; Schema: cal; Owner: asterisk; Tablespace: 
--

ALTER TABLE ONLY timesheet
    ADD CONSTRAINT timesheet_pkey PRIMARY KEY (id);


--
-- Name: cal; Type: ACL; Schema: -; Owner: asterisk
--

REVOKE ALL ON SCHEMA cal FROM PUBLIC;
REVOKE ALL ON SCHEMA cal FROM asterisk;
GRANT ALL ON SCHEMA cal TO asterisk;
GRANT ALL ON SCHEMA cal TO PUBLIC;


--
-- Name: timesheet; Type: ACL; Schema: cal; Owner: asterisk
--

REVOKE ALL ON TABLE timesheet FROM PUBLIC;
REVOKE ALL ON TABLE timesheet FROM asterisk;
GRANT ALL ON TABLE timesheet TO asterisk;
GRANT ALL ON TABLE timesheet TO PUBLIC;


--
-- PostgreSQL database dump complete
--

