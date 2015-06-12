--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: sip_conf; Type: TABLE; Schema: public; Owner: asterisk; Tablespace: 
--

CREATE TABLE sip_conf (
    id bigint NOT NULL,
    cat_metric integer DEFAULT 0 NOT NULL,
    var_metric integer DEFAULT 0 NOT NULL,
    commented integer DEFAULT 0 NOT NULL,
    filename character varying DEFAULT ''::character varying NOT NULL,
    category character varying DEFAULT 'default'::character varying NOT NULL,
    var_name character varying DEFAULT ''::character varying NOT NULL,
    var_val character varying DEFAULT ''::character varying NOT NULL
);


ALTER TABLE public.sip_conf OWNER TO asterisk;

--
-- Name: sip_conf_id_seq; Type: SEQUENCE; Schema: public; Owner: asterisk
--

CREATE SEQUENCE sip_conf_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.sip_conf_id_seq OWNER TO asterisk;

--
-- Name: sip_conf_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: asterisk
--

ALTER SEQUENCE sip_conf_id_seq OWNED BY sip_conf.id;


--
-- Name: sip_conf_id_seq; Type: SEQUENCE SET; Schema: public; Owner: asterisk
--

SELECT pg_catalog.setval('sip_conf_id_seq', 60, true);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: asterisk
--

ALTER TABLE ONLY sip_conf ALTER COLUMN id SET DEFAULT nextval('sip_conf_id_seq'::regclass);


--
-- Data for Name: sip_conf; Type: TABLE DATA; Schema: public; Owner: asterisk
--

INSERT INTO sip_conf VALUES (20, 0, 0, 0, 'sip.conf', 'general', 'context', 'default');
INSERT INTO sip_conf VALUES (21, 0, 1, 0, 'sip.conf', 'general', 'allowoverlap', 'no');
INSERT INTO sip_conf VALUES (22, 0, 2, 0, 'sip.conf', 'general', 'bindport', '5060');
INSERT INTO sip_conf VALUES (24, 0, 4, 0, 'sip.conf', 'general', 'srvlookup', 'yes');
INSERT INTO sip_conf VALUES (26, 0, 6, 0, 'sip.conf', 'general', 'rtcachefriends', 'yes');
INSERT INTO sip_conf VALUES (27, 0, 7, 0, 'sip.conf', 'general', 'rtsavesysname', 'yes');
INSERT INTO sip_conf VALUES (28, 0, 8, 0, 'sip.conf', 'general', 'rtupdate', 'yes');
INSERT INTO sip_conf VALUES (31, 0, 10, 0, 'sip.conf', 'general', 'allowguest', 'no');
INSERT INTO sip_conf VALUES (30, 0, 11, 0, 'sip.conf', 'general', 'ignoreregexpire', 'yes');
INSERT INTO sip_conf VALUES (36, 0, 16, 0, 'sip.conf', 'general', 'defaultexpiry', '3600');
INSERT INTO sip_conf VALUES (43, 0, 18, 0, 'sip.conf', 'general', 'alwaysauthreject', 'yes');
INSERT INTO sip_conf VALUES (29, 0, 9, 0, 'sip.conf', 'general', 'rtautoclear', 'no');
INSERT INTO sip_conf VALUES (44, 0, 19, 0, 'sip.conf', 'general', 'tlsenable', 'yes');
INSERT INTO sip_conf VALUES (45, 0, 20, 0, 'sip.conf', 'general', 'tlsbindaddr', '0.0.0.0');
INSERT INTO sip_conf VALUES (48, 0, 23, 0, 'sip.conf', 'general', 'tlscipher', 'ALL');
INSERT INTO sip_conf VALUES (49, 0, 24, 0, 'sip.conf', 'general', 'tlsclientmethod', 'tlsv1');
INSERT INTO sip_conf VALUES (46, 0, 21, 0, 'sip.conf', 'general', 'tlscertfile', '/etc/asterisk/keys/1/tls/asterisk-keycert.pem');
INSERT INTO sip_conf VALUES (47, 0, 22, 0, 'sip.conf', 'general', 'tlscafile', '/etc/asterisk/keys/1/tls/rootCA/cacert.pem');
INSERT INTO sip_conf VALUES (35, 0, 15, 1, 'sip.conf', 'general', 'localnet', '192.168.0.0/24');
INSERT INTO sip_conf VALUES (50, 0, 25, 1, 'sip.conf', 'general', 'engine', 'asterisk');
INSERT INTO sip_conf VALUES (23, 0, 3, 0, 'sip.conf', 'general', 'bindaddr', '0.0.0.0');
INSERT INTO sip_conf VALUES (51, 0, 26, 0, 'sip.conf', 'general', 'accept_outofcall_message', 'yes');
INSERT INTO sip_conf VALUES (52, 0, 27, 0, 'sip.conf', 'general', 'outofcall_message_context', 'messages');
INSERT INTO sip_conf VALUES (53, 0, 28, 0, 'sip.conf', 'general', 'auth_message_requests', 'no');
INSERT INTO sip_conf VALUES (54, 0, 29, 0, 'sip.conf', 'general', 'subscribecontext', 'notifications');
INSERT INTO sip_conf VALUES (32, 0, 12, 0, 'sip.conf', 'general', 'minexpiry', '30');
INSERT INTO sip_conf VALUES (33, 0, 13, 0, 'sip.conf', 'general', 'maxexpiry', '300');
INSERT INTO sip_conf VALUES (55, 0, 30, 0, 'sip.conf', 'general', 'pedantic', 'no');
INSERT INTO sip_conf VALUES (42, 0, 17, 0, 'sip.conf', 'general', 'videosupport', 'no');
INSERT INTO sip_conf VALUES (56, 0, 31, 1, 'sip.conf', 'general', 'domain', 'asterisk');
INSERT INTO sip_conf VALUES (57, 0, 32, 0, 'sip.conf', 'general', 'directrtpsetup', 'yes');
INSERT INTO sip_conf VALUES (34, 0, 14, 1, 'sip.conf', 'general', 'externip', '204.26.62.251');
INSERT INTO sip_conf VALUES (58, 0, 33, 0, 'sip.conf', 'general', 'tcpenable', 'yes');
INSERT INTO sip_conf VALUES (59, 0, 34, 0, 'sip.conf', 'general', 'tcpbindaddr', '0.0.0.0');


--
-- Name: sip_conf_pkey; Type: CONSTRAINT; Schema: public; Owner: asterisk; Tablespace: 
--

ALTER TABLE ONLY sip_conf
    ADD CONSTRAINT sip_conf_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--

