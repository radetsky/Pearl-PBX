CREATE TABLE cdr_202301 ( CHECK ( calldate >= '2023-01-01' and calldate <'2023-02-01' ) ) INHERITS (cdr);
create index cdr_calldate_202301 on cdr_202301(calldate);
create index cdr_src_202301 on cdr_202301(src);
create index cdr_dst_202301 on cdr_202301(dst);
create index cdr_disposition_202301 on cdr_202301(disposition);
CREATE TABLE cdr_202302 ( CHECK ( calldate >= '2023-02-01' and calldate <'2023-03-01' ) ) INHERITS (cdr);
create index cdr_calldate_202302 on cdr_202302(calldate);
create index cdr_src_202302 on cdr_202302(src);
create index cdr_dst_202302 on cdr_202302(dst);
create index cdr_disposition_202302 on cdr_202302(disposition);
CREATE TABLE cdr_202303 ( CHECK ( calldate >= '2023-03-01' and calldate <'2023-04-01' ) ) INHERITS (cdr);
create index cdr_calldate_202303 on cdr_202303(calldate);
create index cdr_src_202303 on cdr_202303(src);
create index cdr_dst_202303 on cdr_202303(dst);
create index cdr_disposition_202303 on cdr_202303(disposition);
CREATE TABLE cdr_202304 ( CHECK ( calldate >= '2023-04-01' and calldate <'2023-05-01' ) ) INHERITS (cdr);
create index cdr_calldate_202304 on cdr_202304(calldate);
create index cdr_src_202304 on cdr_202304(src);
create index cdr_dst_202304 on cdr_202304(dst);
create index cdr_disposition_202304 on cdr_202304(disposition);
CREATE TABLE cdr_202305 ( CHECK ( calldate >= '2023-05-01' and calldate <'2023-06-01' ) ) INHERITS (cdr);
create index cdr_calldate_202305 on cdr_202305(calldate);
create index cdr_src_202305 on cdr_202305(src);
create index cdr_dst_202305 on cdr_202305(dst);
create index cdr_disposition_202305 on cdr_202305(disposition);
CREATE TABLE cdr_202306 ( CHECK ( calldate >= '2023-06-01' and calldate <'2023-07-01' ) ) INHERITS (cdr);
create index cdr_calldate_202306 on cdr_202306(calldate);
create index cdr_src_202306 on cdr_202306(src);
create index cdr_dst_202306 on cdr_202306(dst);
create index cdr_disposition_202306 on cdr_202306(disposition);
CREATE TABLE cdr_202307 ( CHECK ( calldate >= '2023-07-01' and calldate <'2023-08-01' ) ) INHERITS (cdr);
create index cdr_calldate_202307 on cdr_202307(calldate);
create index cdr_src_202307 on cdr_202307(src);
create index cdr_dst_202307 on cdr_202307(dst);
create index cdr_disposition_202307 on cdr_202307(disposition);
CREATE TABLE cdr_202308 ( CHECK ( calldate >= '2023-08-01' and calldate <'2023-09-01' ) ) INHERITS (cdr);
create index cdr_calldate_202308 on cdr_202308(calldate);
create index cdr_src_202308 on cdr_202308(src);
create index cdr_dst_202308 on cdr_202308(dst);
create index cdr_disposition_202308 on cdr_202308(disposition);
CREATE TABLE cdr_202309 ( CHECK ( calldate >= '2023-09-01' and calldate <'2023-10-01' ) ) INHERITS (cdr);
create index cdr_calldate_202309 on cdr_202309(calldate);
create index cdr_src_202309 on cdr_202309(src);
create index cdr_dst_202309 on cdr_202309(dst);
create index cdr_disposition_202309 on cdr_202309(disposition);
CREATE TABLE cdr_202310 ( CHECK ( calldate >= '2023-10-01' and calldate <'2023-11-01' ) ) INHERITS (cdr);
create index cdr_calldate_202310 on cdr_202310(calldate);
create index cdr_src_202310 on cdr_202310(src);
create index cdr_dst_202310 on cdr_202310(dst);
create index cdr_disposition_202310 on cdr_202310(disposition);
CREATE TABLE cdr_202311 ( CHECK ( calldate >= '2023-11-01' and calldate <'2023-12-01' ) ) INHERITS (cdr);
create index cdr_calldate_202311 on cdr_202311(calldate);
create index cdr_src_202311 on cdr_202311(src);
create index cdr_dst_202311 on cdr_202311(dst);
create index cdr_disposition_202311 on cdr_202311(disposition);
CREATE TABLE cdr_202312 ( CHECK ( calldate >= '2023-12-01' and calldate <'2024-01-01' ) ) INHERITS (cdr);
create index cdr_calldate_202312 on cdr_202312(calldate);
create index cdr_src_202312 on cdr_202312(src);
create index cdr_dst_202312 on cdr_202312(dst);
create index cdr_disposition_202312 on cdr_202312(disposition);
CREATE TABLE cdr_202401 ( CHECK ( calldate >= '2024-01-01' and calldate <'2024-02-01' ) ) INHERITS (cdr);
create index cdr_calldate_202401 on cdr_202401(calldate);
create index cdr_src_202401 on cdr_202401(src);
create index cdr_dst_202401 on cdr_202401(dst);
create index cdr_disposition_202401 on cdr_202401(disposition);
CREATE TABLE cdr_202402 ( CHECK ( calldate >= '2024-02-01' and calldate <'2024-03-01' ) ) INHERITS (cdr);
create index cdr_calldate_202402 on cdr_202402(calldate);
create index cdr_src_202402 on cdr_202402(src);
create index cdr_dst_202402 on cdr_202402(dst);
create index cdr_disposition_202402 on cdr_202402(disposition);
CREATE TABLE cdr_202403 ( CHECK ( calldate >= '2024-03-01' and calldate <'2024-04-01' ) ) INHERITS (cdr);
create index cdr_calldate_202403 on cdr_202403(calldate);
create index cdr_src_202403 on cdr_202403(src);
create index cdr_dst_202403 on cdr_202403(dst);
create index cdr_disposition_202403 on cdr_202403(disposition);
CREATE TABLE cdr_202404 ( CHECK ( calldate >= '2024-04-01' and calldate <'2024-05-01' ) ) INHERITS (cdr);
create index cdr_calldate_202404 on cdr_202404(calldate);
create index cdr_src_202404 on cdr_202404(src);
create index cdr_dst_202404 on cdr_202404(dst);
create index cdr_disposition_202404 on cdr_202404(disposition);
CREATE TABLE cdr_202405 ( CHECK ( calldate >= '2024-05-01' and calldate <'2024-06-01' ) ) INHERITS (cdr);
create index cdr_calldate_202405 on cdr_202405(calldate);
create index cdr_src_202405 on cdr_202405(src);
create index cdr_dst_202405 on cdr_202405(dst);
create index cdr_disposition_202405 on cdr_202405(disposition);
CREATE TABLE cdr_202406 ( CHECK ( calldate >= '2024-06-01' and calldate <'2024-07-01' ) ) INHERITS (cdr);
create index cdr_calldate_202406 on cdr_202406(calldate);
create index cdr_src_202406 on cdr_202406(src);
create index cdr_dst_202406 on cdr_202406(dst);
create index cdr_disposition_202406 on cdr_202406(disposition);
CREATE TABLE cdr_202407 ( CHECK ( calldate >= '2024-07-01' and calldate <'2024-08-01' ) ) INHERITS (cdr);
create index cdr_calldate_202407 on cdr_202407(calldate);
create index cdr_src_202407 on cdr_202407(src);
create index cdr_dst_202407 on cdr_202407(dst);
create index cdr_disposition_202407 on cdr_202407(disposition);
CREATE TABLE cdr_202408 ( CHECK ( calldate >= '2024-08-01' and calldate <'2024-09-01' ) ) INHERITS (cdr);
create index cdr_calldate_202408 on cdr_202408(calldate);
create index cdr_src_202408 on cdr_202408(src);
create index cdr_dst_202408 on cdr_202408(dst);
create index cdr_disposition_202408 on cdr_202408(disposition);
CREATE TABLE cdr_202409 ( CHECK ( calldate >= '2024-09-01' and calldate <'2024-10-01' ) ) INHERITS (cdr);
create index cdr_calldate_202409 on cdr_202409(calldate);
create index cdr_src_202409 on cdr_202409(src);
create index cdr_dst_202409 on cdr_202409(dst);
create index cdr_disposition_202409 on cdr_202409(disposition);
CREATE TABLE cdr_202410 ( CHECK ( calldate >= '2024-10-01' and calldate <'2024-11-01' ) ) INHERITS (cdr);
create index cdr_calldate_202410 on cdr_202410(calldate);
create index cdr_src_202410 on cdr_202410(src);
create index cdr_dst_202410 on cdr_202410(dst);
create index cdr_disposition_202410 on cdr_202410(disposition);
CREATE TABLE cdr_202411 ( CHECK ( calldate >= '2024-11-01' and calldate <'2024-12-01' ) ) INHERITS (cdr);
create index cdr_calldate_202411 on cdr_202411(calldate);
create index cdr_src_202411 on cdr_202411(src);
create index cdr_dst_202411 on cdr_202411(dst);
create index cdr_disposition_202411 on cdr_202411(disposition);
CREATE TABLE cdr_202412 ( CHECK ( calldate >= '2024-12-01' and calldate <'2017-01-01' ) ) INHERITS (cdr);
create index cdr_calldate_202412 on cdr_202412(calldate);
create index cdr_src_202412 on cdr_202412(src);
create index cdr_dst_202412 on cdr_202412(dst);
create index cdr_disposition_202412 on cdr_202412(disposition);

CREATE OR REPLACE FUNCTION cdr_insert_trigger() 
        RETURNS TRIGGER AS $$
        BEGIN
             IF ( NEW.calldate >= DATE '2023-01-01' AND
                  NEW.calldate < DATE '2023-02-01' ) THEN
                  INSERT INTO cdr_202301 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2023-02-01' AND
                        NEW.calldate < DATE '2023-03-01' ) THEN
                                INSERT INTO cdr_202302 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2023-03-01' AND
                        NEW.calldate < DATE '2023-04-01' ) THEN
                                INSERT INTO cdr_202303 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2023-04-01' AND
                        NEW.calldate < DATE '2023-05-01' ) THEN
                                INSERT INTO cdr_202304 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2023-05-01' AND
                        NEW.calldate < DATE '2023-06-01' ) THEN
                                INSERT INTO cdr_202305 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2023-06-01' AND
                        NEW.calldate < DATE '2023-07-01' ) THEN
                                INSERT INTO cdr_202306 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2023-07-01' AND
                        NEW.calldate < DATE '2023-08-01' ) THEN
                                INSERT INTO cdr_202307 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2023-08-01' AND
                        NEW.calldate < DATE '2023-09-01' ) THEN
                                INSERT INTO cdr_202308 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2023-09-01' AND
                        NEW.calldate < DATE '2023-10-01' ) THEN
                                INSERT INTO cdr_202309 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2023-10-01' AND
                        NEW.calldate < DATE '2023-11-01' ) THEN
                                INSERT INTO cdr_202310 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2023-11-01' AND
                        NEW.calldate < DATE '2023-12-01' ) THEN
                                INSERT INTO cdr_202311 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2023-12-01' AND
                        NEW.calldate < DATE '2024-01-01' ) THEN
                                INSERT INTO cdr_202312 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2024-01-01' AND
                        NEW.calldate < DATE '2024-02-01' ) THEN
                                INSERT INTO cdr_202401 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2024-02-01' AND
                        NEW.calldate < DATE '2024-03-01' ) THEN
                                INSERT INTO cdr_202402 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2024-03-01' AND
                        NEW.calldate < DATE '2024-04-01' ) THEN
                                INSERT INTO cdr_202403 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2024-04-01' AND
                        NEW.calldate < DATE '2024-05-01' ) THEN
                                INSERT INTO cdr_202404 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2024-05-01' AND
                        NEW.calldate < DATE '2024-06-01' ) THEN
                                INSERT INTO cdr_202405 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2024-06-01' AND
                        NEW.calldate < DATE '2024-07-01' ) THEN
                                INSERT INTO cdr_202406 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2024-07-01' AND
                        NEW.calldate < DATE '2024-08-01' ) THEN
                                INSERT INTO cdr_202407 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2024-08-01' AND
                        NEW.calldate < DATE '2024-09-01' ) THEN
                                INSERT INTO cdr_202408 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2024-09-01' AND
                        NEW.calldate < DATE '2024-10-01' ) THEN
                                INSERT INTO cdr_202409 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2024-10-01' AND
                        NEW.calldate < DATE '2024-11-01' ) THEN
                                INSERT INTO cdr_202410 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2024-11-01' AND
                        NEW.calldate < DATE '2024-12-01' ) THEN
                                INSERT INTO cdr_202411 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2024-12-01' AND
                        NEW.calldate < DATE '2017-01-01' ) THEN
                                INSERT INTO cdr_202412 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2022-01-01' AND
                        NEW.calldate < DATE '2022-02-01' ) THEN
                                INSERT INTO cdr_202201 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2022-02-01' AND
                        NEW.calldate < DATE '2022-03-01' ) THEN
                                INSERT INTO cdr_202202 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2022-03-01' AND
                        NEW.calldate < DATE '2022-04-01' ) THEN
                                INSERT INTO cdr_202203 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2022-04-01' AND
                        NEW.calldate < DATE '2022-05-01' ) THEN
                                INSERT INTO cdr_202204 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2022-05-01' AND
                        NEW.calldate < DATE '2022-06-01' ) THEN
                                INSERT INTO cdr_202205 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2022-06-01' AND
                        NEW.calldate < DATE '2022-07-01' ) THEN
                                INSERT INTO cdr_202206 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2022-07-01' AND
                        NEW.calldate < DATE '2022-08-01' ) THEN
                                INSERT INTO cdr_202207 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2022-08-01' AND
                        NEW.calldate < DATE '2022-09-01' ) THEN
                                INSERT INTO cdr_202208 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2022-09-01' AND
                        NEW.calldate < DATE '2022-10-01' ) THEN
                                INSERT INTO cdr_202209 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2022-10-01' AND
                        NEW.calldate < DATE '2022-11-01' ) THEN
                                INSERT INTO cdr_202210 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2022-11-01' AND
                        NEW.calldate < DATE '2022-12-01' ) THEN
                                INSERT INTO cdr_202211 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2022-12-01' AND
                        NEW.calldate < DATE '2023-01-01' ) THEN
                                INSERT INTO cdr_202212 VALUES (NEW.*);
ELSE RAISE EXCEPTION 'Date out of range.  Fix the cdr_insert_trigger() function!';
            END IF;
                RETURN NULL;
                END;
                $$
                LANGUAGE plpgsql;


CREATE TRIGGER insert_cdr_trigger
           BEFORE INSERT ON cdr
              FOR EACH ROW EXECUTE PROCEDURE cdr_insert_trigger();


set search_path to integration;
CREATE TABLE recordings_202301 ( CHECK ( cdr_start >= '2023-01-01' and cdr_start <'2023-02-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202301 on recordings_202301(cdr_start);
create index recordings_src_202301 on recordings_202301(cdr_src);
create index recordings_dst_202301 on recordings_202301(cdr_dst);
create index recordings_uniqueid_202301 on recordings_202301(cdr_uniqueid);
CREATE TABLE recordings_202302 ( CHECK ( cdr_start >= '2023-02-01' and cdr_start <'2023-03-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202302 on recordings_202302(cdr_start);
create index recordings_src_202302 on recordings_202302(cdr_src);
create index recordings_dst_202302 on recordings_202302(cdr_dst);
create index recordings_uniqueid_202302 on recordings_202302(cdr_uniqueid);
CREATE TABLE recordings_202303 ( CHECK ( cdr_start >= '2023-03-01' and cdr_start <'2023-04-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202303 on recordings_202303(cdr_start);
create index recordings_src_202303 on recordings_202303(cdr_src);
create index recordings_dst_202303 on recordings_202303(cdr_dst);
create index recordings_uniqueid_202303 on recordings_202303(cdr_uniqueid);
CREATE TABLE recordings_202304 ( CHECK ( cdr_start >= '2023-04-01' and cdr_start <'2023-05-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202304 on recordings_202304(cdr_start);
create index recordings_src_202304 on recordings_202304(cdr_src);
create index recordings_dst_202304 on recordings_202304(cdr_dst);
create index recordings_uniqueid_202304 on recordings_202304(cdr_uniqueid);
CREATE TABLE recordings_202305 ( CHECK ( cdr_start >= '2023-05-01' and cdr_start <'2023-06-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202305 on recordings_202305(cdr_start);
create index recordings_src_202305 on recordings_202305(cdr_src);
create index recordings_dst_202305 on recordings_202305(cdr_dst);
create index recordings_uniqueid_202305 on recordings_202305(cdr_uniqueid);
CREATE TABLE recordings_202306 ( CHECK ( cdr_start >= '2023-06-01' and cdr_start <'2023-07-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202306 on recordings_202306(cdr_start);
create index recordings_src_202306 on recordings_202306(cdr_src);
create index recordings_dst_202306 on recordings_202306(cdr_dst);
create index recordings_uniqueid_202306 on recordings_202306(cdr_uniqueid);
CREATE TABLE recordings_202307 ( CHECK ( cdr_start >= '2023-07-01' and cdr_start <'2023-08-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202307 on recordings_202307(cdr_start);
create index recordings_src_202307 on recordings_202307(cdr_src);
create index recordings_dst_202307 on recordings_202307(cdr_dst);
create index recordings_uniqueid_202307 on recordings_202307(cdr_uniqueid);
CREATE TABLE recordings_202308 ( CHECK ( cdr_start >= '2023-08-01' and cdr_start <'2023-09-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202308 on recordings_202308(cdr_start);
create index recordings_src_202308 on recordings_202308(cdr_src);
create index recordings_dst_202308 on recordings_202308(cdr_dst);
create index recordings_uniqueid_202308 on recordings_202308(cdr_uniqueid);
CREATE TABLE recordings_202309 ( CHECK ( cdr_start >= '2023-09-01' and cdr_start <'2023-10-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202309 on recordings_202309(cdr_start);
create index recordings_src_202309 on recordings_202309(cdr_src);
create index recordings_dst_202309 on recordings_202309(cdr_dst);
create index recordings_uniqueid_202309 on recordings_202309(cdr_uniqueid);
CREATE TABLE recordings_202310 ( CHECK ( cdr_start >= '2023-10-01' and cdr_start <'2023-11-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202310 on recordings_202310(cdr_start);
create index recordings_src_202310 on recordings_202310(cdr_src);
create index recordings_dst_202310 on recordings_202310(cdr_dst);
create index recordings_uniqueid_202310 on recordings_202310(cdr_uniqueid);
CREATE TABLE recordings_202311 ( CHECK ( cdr_start >= '2023-11-01' and cdr_start <'2023-12-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202311 on recordings_202311(cdr_start);
create index recordings_src_202311 on recordings_202311(cdr_src);
create index recordings_dst_202311 on recordings_202311(cdr_dst);
create index recordings_uniqueid_202311 on recordings_202311(cdr_uniqueid);
CREATE TABLE recordings_202312 ( CHECK ( cdr_start >= '2023-12-01' and cdr_start <'2024-01-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202312 on recordings_202312(cdr_start);
create index recordings_src_202312 on recordings_202312(cdr_src);
create index recordings_dst_202312 on recordings_202312(cdr_dst);
create index recordings_uniqueid_202312 on recordings_202312(cdr_uniqueid);
CREATE TABLE recordings_202401 ( CHECK ( cdr_start >= '2024-01-01' and cdr_start <'2024-02-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202401 on recordings_202401(cdr_start);
create index recordings_src_202401 on recordings_202401(cdr_src);
create index recordings_dst_202401 on recordings_202401(cdr_dst);
create index recordings_uniqueid_202401 on recordings_202401(cdr_uniqueid);
CREATE TABLE recordings_202402 ( CHECK ( cdr_start >= '2024-02-01' and cdr_start <'2024-03-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202402 on recordings_202402(cdr_start);
create index recordings_src_202402 on recordings_202402(cdr_src);
create index recordings_dst_202402 on recordings_202402(cdr_dst);
create index recordings_uniqueid_202402 on recordings_202402(cdr_uniqueid);
CREATE TABLE recordings_202403 ( CHECK ( cdr_start >= '2024-03-01' and cdr_start <'2024-04-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202403 on recordings_202403(cdr_start);
create index recordings_src_202403 on recordings_202403(cdr_src);
create index recordings_dst_202403 on recordings_202403(cdr_dst);
create index recordings_uniqueid_202403 on recordings_202403(cdr_uniqueid);
CREATE TABLE recordings_202404 ( CHECK ( cdr_start >= '2024-04-01' and cdr_start <'2024-05-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202404 on recordings_202404(cdr_start);
create index recordings_src_202404 on recordings_202404(cdr_src);
create index recordings_dst_202404 on recordings_202404(cdr_dst);
create index recordings_uniqueid_202404 on recordings_202404(cdr_uniqueid);
CREATE TABLE recordings_202405 ( CHECK ( cdr_start >= '2024-05-01' and cdr_start <'2024-06-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202405 on recordings_202405(cdr_start);
create index recordings_src_202405 on recordings_202405(cdr_src);
create index recordings_dst_202405 on recordings_202405(cdr_dst);
create index recordings_uniqueid_202405 on recordings_202405(cdr_uniqueid);
CREATE TABLE recordings_202406 ( CHECK ( cdr_start >= '2024-06-01' and cdr_start <'2024-07-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202406 on recordings_202406(cdr_start);
create index recordings_src_202406 on recordings_202406(cdr_src);
create index recordings_dst_202406 on recordings_202406(cdr_dst);
create index recordings_uniqueid_202406 on recordings_202406(cdr_uniqueid);
CREATE TABLE recordings_202407 ( CHECK ( cdr_start >= '2024-07-01' and cdr_start <'2024-08-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202407 on recordings_202407(cdr_start);
create index recordings_src_202407 on recordings_202407(cdr_src);
create index recordings_dst_202407 on recordings_202407(cdr_dst);
create index recordings_uniqueid_202407 on recordings_202407(cdr_uniqueid);
CREATE TABLE recordings_202408 ( CHECK ( cdr_start >= '2024-08-01' and cdr_start <'2024-09-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202408 on recordings_202408(cdr_start);
create index recordings_src_202408 on recordings_202408(cdr_src);
create index recordings_dst_202408 on recordings_202408(cdr_dst);
create index recordings_uniqueid_202408 on recordings_202408(cdr_uniqueid);
CREATE TABLE recordings_202409 ( CHECK ( cdr_start >= '2024-09-01' and cdr_start <'2024-10-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202409 on recordings_202409(cdr_start);
create index recordings_src_202409 on recordings_202409(cdr_src);
create index recordings_dst_202409 on recordings_202409(cdr_dst);
create index recordings_uniqueid_202409 on recordings_202409(cdr_uniqueid);
CREATE TABLE recordings_202410 ( CHECK ( cdr_start >= '2024-10-01' and cdr_start <'2024-11-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202410 on recordings_202410(cdr_start);
create index recordings_src_202410 on recordings_202410(cdr_src);
create index recordings_dst_202410 on recordings_202410(cdr_dst);
create index recordings_uniqueid_202410 on recordings_202410(cdr_uniqueid);
CREATE TABLE recordings_202411 ( CHECK ( cdr_start >= '2024-11-01' and cdr_start <'2024-12-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202411 on recordings_202411(cdr_start);
create index recordings_src_202411 on recordings_202411(cdr_src);
create index recordings_dst_202411 on recordings_202411(cdr_dst);
create index recordings_uniqueid_202411 on recordings_202411(cdr_uniqueid);
CREATE TABLE recordings_202412 ( CHECK ( cdr_start >= '2024-12-01' and cdr_start <'2017-01-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202412 on recordings_202412(cdr_start);
create index recordings_src_202412 on recordings_202412(cdr_src);
create index recordings_dst_202412 on recordings_202412(cdr_dst);
create index recordings_uniqueid_202412 on recordings_202412(cdr_uniqueid);

CREATE OR REPLACE FUNCTION recordings_insert_trigger() 
        RETURNS TRIGGER AS $$
        BEGIN
             IF ( NEW.cdr_start >= DATE '2023-01-01' AND
                  NEW.cdr_start < DATE '2023-02-01' ) THEN
                  INSERT INTO recordings_202301 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2023-02-01' AND
                        NEW.cdr_start < DATE '2023-03-01' ) THEN
                                INSERT INTO recordings_202302 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2023-03-01' AND
                        NEW.cdr_start < DATE '2023-04-01' ) THEN
                                INSERT INTO recordings_202303 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2023-04-01' AND
                        NEW.cdr_start < DATE '2023-05-01' ) THEN
                                INSERT INTO recordings_202304 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2023-05-01' AND
                        NEW.cdr_start < DATE '2023-06-01' ) THEN
                                INSERT INTO recordings_202305 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2023-06-01' AND
                        NEW.cdr_start < DATE '2023-07-01' ) THEN
                                INSERT INTO recordings_202306 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2023-07-01' AND
                        NEW.cdr_start < DATE '2023-08-01' ) THEN
                                INSERT INTO recordings_202307 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2023-08-01' AND
                        NEW.cdr_start < DATE '2023-09-01' ) THEN
                                INSERT INTO recordings_202308 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2023-09-01' AND
                        NEW.cdr_start < DATE '2023-10-01' ) THEN
                                INSERT INTO recordings_202309 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2023-10-01' AND
                        NEW.cdr_start < DATE '2023-11-01' ) THEN
                                INSERT INTO recordings_202310 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2023-11-01' AND
                        NEW.cdr_start < DATE '2023-12-01' ) THEN
                                INSERT INTO recordings_202311 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2023-12-01' AND
                        NEW.cdr_start < DATE '2024-01-01' ) THEN
                                INSERT INTO recordings_202312 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2024-01-01' AND
                        NEW.cdr_start < DATE '2024-02-01' ) THEN
                                INSERT INTO recordings_202401 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2024-02-01' AND
                        NEW.cdr_start < DATE '2024-03-01' ) THEN
                                INSERT INTO recordings_202402 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2024-03-01' AND
                        NEW.cdr_start < DATE '2024-04-01' ) THEN
                                INSERT INTO recordings_202403 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2024-04-01' AND
                        NEW.cdr_start < DATE '2024-05-01' ) THEN
                                INSERT INTO recordings_202404 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2024-05-01' AND
                        NEW.cdr_start < DATE '2024-06-01' ) THEN
                                INSERT INTO recordings_202405 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2024-06-01' AND
                        NEW.cdr_start < DATE '2024-07-01' ) THEN
                                INSERT INTO recordings_202406 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2024-07-01' AND
                        NEW.cdr_start < DATE '2024-08-01' ) THEN
                                INSERT INTO recordings_202407 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2024-08-01' AND
                        NEW.cdr_start < DATE '2024-09-01' ) THEN
                                INSERT INTO recordings_202408 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2024-09-01' AND
                        NEW.cdr_start < DATE '2024-10-01' ) THEN
                                INSERT INTO recordings_202409 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2024-10-01' AND
                        NEW.cdr_start < DATE '2024-11-01' ) THEN
                                INSERT INTO recordings_202410 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2024-11-01' AND
                        NEW.cdr_start < DATE '2024-12-01' ) THEN
                                INSERT INTO recordings_202411 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2024-12-01' AND
                        NEW.cdr_start < DATE '2017-01-01' ) THEN
                                INSERT INTO recordings_202412 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2022-01-01' AND
                        NEW.cdr_start < DATE '2022-02-01' ) THEN
                                INSERT INTO recordings_202201 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2022-02-01' AND
                        NEW.cdr_start < DATE '2022-03-01' ) THEN
                                INSERT INTO recordings_202202 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2022-03-01' AND
                        NEW.cdr_start < DATE '2022-04-01' ) THEN
                                INSERT INTO recordings_202203 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2022-04-01' AND
                        NEW.cdr_start < DATE '2022-05-01' ) THEN
                                INSERT INTO recordings_202204 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2022-05-01' AND
                        NEW.cdr_start < DATE '2022-06-01' ) THEN
                                INSERT INTO recordings_202205 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2022-06-01' AND
                        NEW.cdr_start < DATE '2022-07-01' ) THEN
                                INSERT INTO recordings_202206 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2022-07-01' AND
                        NEW.cdr_start < DATE '2022-08-01' ) THEN
                                INSERT INTO recordings_202207 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2022-08-01' AND
                        NEW.cdr_start < DATE '2022-09-01' ) THEN
                                INSERT INTO recordings_202208 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2022-09-01' AND
                        NEW.cdr_start < DATE '2022-10-01' ) THEN
                                INSERT INTO recordings_202209 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2022-10-01' AND
                        NEW.cdr_start < DATE '2022-11-01' ) THEN
                                INSERT INTO recordings_202210 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2022-11-01' AND
                        NEW.cdr_start < DATE '2022-12-01' ) THEN
                                INSERT INTO recordings_202211 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2022-12-01' AND
                        NEW.cdr_start < DATE '2023-01-01' ) THEN
                                INSERT INTO recordings_202212 VALUES (NEW.*);
ELSE RAISE EXCEPTION 'Date out of range.  Fix the recordings_insert_trigger() function!';
            END IF;
                RETURN NULL;
                END;
                $$
                LANGUAGE plpgsql;

CREATE TRIGGER insert_recordings_trigger
           BEFORE INSERT ON recordings
              FOR EACH ROW EXECUTE PROCEDURE recordings_insert_trigger();


