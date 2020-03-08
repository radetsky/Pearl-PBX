CREATE TABLE cdr_201501 ( CHECK ( calldate >= '2015-01-01' and calldate <'2015-02-01' ) ) INHERITS (cdr);
create index cdr_calldate_201501 on cdr_201501(calldate);
create index cdr_src_201501 on cdr_201501(src);
create index cdr_dst_201501 on cdr_201501(dst);
create index cdr_disposition_201501 on cdr_201501(disposition);
CREATE TABLE cdr_201502 ( CHECK ( calldate >= '2015-02-01' and calldate <'2015-03-01' ) ) INHERITS (cdr);
create index cdr_calldate_201502 on cdr_201502(calldate);
create index cdr_src_201502 on cdr_201502(src);
create index cdr_dst_201502 on cdr_201502(dst);
create index cdr_disposition_201502 on cdr_201502(disposition);
CREATE TABLE cdr_201503 ( CHECK ( calldate >= '2015-03-01' and calldate <'2015-04-01' ) ) INHERITS (cdr);
create index cdr_calldate_201503 on cdr_201503(calldate);
create index cdr_src_201503 on cdr_201503(src);
create index cdr_dst_201503 on cdr_201503(dst);
create index cdr_disposition_201503 on cdr_201503(disposition);
CREATE TABLE cdr_201504 ( CHECK ( calldate >= '2015-04-01' and calldate <'2015-05-01' ) ) INHERITS (cdr);
create index cdr_calldate_201504 on cdr_201504(calldate);
create index cdr_src_201504 on cdr_201504(src);
create index cdr_dst_201504 on cdr_201504(dst);
create index cdr_disposition_201504 on cdr_201504(disposition);
CREATE TABLE cdr_201505 ( CHECK ( calldate >= '2015-05-01' and calldate <'2015-06-01' ) ) INHERITS (cdr);
create index cdr_calldate_201505 on cdr_201505(calldate);
create index cdr_src_201505 on cdr_201505(src);
create index cdr_dst_201505 on cdr_201505(dst);
create index cdr_disposition_201505 on cdr_201505(disposition);
CREATE TABLE cdr_201506 ( CHECK ( calldate >= '2015-06-01' and calldate <'2015-07-01' ) ) INHERITS (cdr);
create index cdr_calldate_201506 on cdr_201506(calldate);
create index cdr_src_201506 on cdr_201506(src);
create index cdr_dst_201506 on cdr_201506(dst);
create index cdr_disposition_201506 on cdr_201506(disposition);
CREATE TABLE cdr_201507 ( CHECK ( calldate >= '2015-07-01' and calldate <'2015-08-01' ) ) INHERITS (cdr);
create index cdr_calldate_201507 on cdr_201507(calldate);
create index cdr_src_201507 on cdr_201507(src);
create index cdr_dst_201507 on cdr_201507(dst);
create index cdr_disposition_201507 on cdr_201507(disposition);
CREATE TABLE cdr_201508 ( CHECK ( calldate >= '2015-08-01' and calldate <'2015-09-01' ) ) INHERITS (cdr);
create index cdr_calldate_201508 on cdr_201508(calldate);
create index cdr_src_201508 on cdr_201508(src);
create index cdr_dst_201508 on cdr_201508(dst);
create index cdr_disposition_201508 on cdr_201508(disposition);
CREATE TABLE cdr_201509 ( CHECK ( calldate >= '2015-09-01' and calldate <'2015-10-01' ) ) INHERITS (cdr);
create index cdr_calldate_201509 on cdr_201509(calldate);
create index cdr_src_201509 on cdr_201509(src);
create index cdr_dst_201509 on cdr_201509(dst);
create index cdr_disposition_201509 on cdr_201509(disposition);
CREATE TABLE cdr_201510 ( CHECK ( calldate >= '2015-10-01' and calldate <'2015-11-01' ) ) INHERITS (cdr);
create index cdr_calldate_201510 on cdr_201510(calldate);
create index cdr_src_201510 on cdr_201510(src);
create index cdr_dst_201510 on cdr_201510(dst);
create index cdr_disposition_201510 on cdr_201510(disposition);
CREATE TABLE cdr_201511 ( CHECK ( calldate >= '2015-11-01' and calldate <'2015-12-01' ) ) INHERITS (cdr);
create index cdr_calldate_201511 on cdr_201511(calldate);
create index cdr_src_201511 on cdr_201511(src);
create index cdr_dst_201511 on cdr_201511(dst);
create index cdr_disposition_201511 on cdr_201511(disposition);
CREATE TABLE cdr_201512 ( CHECK ( calldate >= '2015-12-01' and calldate <'2016-01-01' ) ) INHERITS (cdr);
create index cdr_calldate_201512 on cdr_201512(calldate);
create index cdr_src_201512 on cdr_201512(src);
create index cdr_dst_201512 on cdr_201512(dst);
create index cdr_disposition_201512 on cdr_201512(disposition);
CREATE TABLE cdr_201601 ( CHECK ( calldate >= '2016-01-01' and calldate <'2016-02-01' ) ) INHERITS (cdr);
create index cdr_calldate_201601 on cdr_201601(calldate);
create index cdr_src_201601 on cdr_201601(src);
create index cdr_dst_201601 on cdr_201601(dst);
create index cdr_disposition_201601 on cdr_201601(disposition);
CREATE TABLE cdr_201602 ( CHECK ( calldate >= '2016-02-01' and calldate <'2016-03-01' ) ) INHERITS (cdr);
create index cdr_calldate_201602 on cdr_201602(calldate);
create index cdr_src_201602 on cdr_201602(src);
create index cdr_dst_201602 on cdr_201602(dst);
create index cdr_disposition_201602 on cdr_201602(disposition);
CREATE TABLE cdr_201603 ( CHECK ( calldate >= '2016-03-01' and calldate <'2016-04-01' ) ) INHERITS (cdr);
create index cdr_calldate_201603 on cdr_201603(calldate);
create index cdr_src_201603 on cdr_201603(src);
create index cdr_dst_201603 on cdr_201603(dst);
create index cdr_disposition_201603 on cdr_201603(disposition);
CREATE TABLE cdr_201604 ( CHECK ( calldate >= '2016-04-01' and calldate <'2016-05-01' ) ) INHERITS (cdr);
create index cdr_calldate_201604 on cdr_201604(calldate);
create index cdr_src_201604 on cdr_201604(src);
create index cdr_dst_201604 on cdr_201604(dst);
create index cdr_disposition_201604 on cdr_201604(disposition);
CREATE TABLE cdr_201605 ( CHECK ( calldate >= '2016-05-01' and calldate <'2016-06-01' ) ) INHERITS (cdr);
create index cdr_calldate_201605 on cdr_201605(calldate);
create index cdr_src_201605 on cdr_201605(src);
create index cdr_dst_201605 on cdr_201605(dst);
create index cdr_disposition_201605 on cdr_201605(disposition);
CREATE TABLE cdr_201606 ( CHECK ( calldate >= '2016-06-01' and calldate <'2016-07-01' ) ) INHERITS (cdr);
create index cdr_calldate_201606 on cdr_201606(calldate);
create index cdr_src_201606 on cdr_201606(src);
create index cdr_dst_201606 on cdr_201606(dst);
create index cdr_disposition_201606 on cdr_201606(disposition);
CREATE TABLE cdr_201607 ( CHECK ( calldate >= '2016-07-01' and calldate <'2016-08-01' ) ) INHERITS (cdr);
create index cdr_calldate_201607 on cdr_201607(calldate);
create index cdr_src_201607 on cdr_201607(src);
create index cdr_dst_201607 on cdr_201607(dst);
create index cdr_disposition_201607 on cdr_201607(disposition);
CREATE TABLE cdr_201608 ( CHECK ( calldate >= '2016-08-01' and calldate <'2016-09-01' ) ) INHERITS (cdr);
create index cdr_calldate_201608 on cdr_201608(calldate);
create index cdr_src_201608 on cdr_201608(src);
create index cdr_dst_201608 on cdr_201608(dst);
create index cdr_disposition_201608 on cdr_201608(disposition);
CREATE TABLE cdr_201609 ( CHECK ( calldate >= '2016-09-01' and calldate <'2016-10-01' ) ) INHERITS (cdr);
create index cdr_calldate_201609 on cdr_201609(calldate);
create index cdr_src_201609 on cdr_201609(src);
create index cdr_dst_201609 on cdr_201609(dst);
create index cdr_disposition_201609 on cdr_201609(disposition);
CREATE TABLE cdr_201610 ( CHECK ( calldate >= '2016-10-01' and calldate <'2016-11-01' ) ) INHERITS (cdr);
create index cdr_calldate_201610 on cdr_201610(calldate);
create index cdr_src_201610 on cdr_201610(src);
create index cdr_dst_201610 on cdr_201610(dst);
create index cdr_disposition_201610 on cdr_201610(disposition);
CREATE TABLE cdr_201611 ( CHECK ( calldate >= '2016-11-01' and calldate <'2016-12-01' ) ) INHERITS (cdr);
create index cdr_calldate_201611 on cdr_201611(calldate);
create index cdr_src_201611 on cdr_201611(src);
create index cdr_dst_201611 on cdr_201611(dst);
create index cdr_disposition_201611 on cdr_201611(disposition);
CREATE TABLE cdr_201612 ( CHECK ( calldate >= '2016-12-01' and calldate <'2017-01-01' ) ) INHERITS (cdr);
create index cdr_calldate_201612 on cdr_201612(calldate);
create index cdr_src_201612 on cdr_201612(src);
create index cdr_dst_201612 on cdr_201612(dst);
create index cdr_disposition_201612 on cdr_201612(disposition);
CREATE TABLE cdr_201701 ( CHECK ( calldate >= '2017-01-01' and calldate <'2017-02-01' ) ) INHERITS (cdr);
create index cdr_calldate_201701 on cdr_201701(calldate);
create index cdr_src_201701 on cdr_201701(src);
create index cdr_dst_201701 on cdr_201701(dst);
create index cdr_disposition_201701 on cdr_201701(disposition);
CREATE TABLE cdr_201702 ( CHECK ( calldate >= '2017-02-01' and calldate <'2017-03-01' ) ) INHERITS (cdr);
create index cdr_calldate_201702 on cdr_201702(calldate);
create index cdr_src_201702 on cdr_201702(src);
create index cdr_dst_201702 on cdr_201702(dst);
create index cdr_disposition_201702 on cdr_201702(disposition);
CREATE TABLE cdr_201703 ( CHECK ( calldate >= '2017-03-01' and calldate <'2017-04-01' ) ) INHERITS (cdr);
create index cdr_calldate_201703 on cdr_201703(calldate);
create index cdr_src_201703 on cdr_201703(src);
create index cdr_dst_201703 on cdr_201703(dst);
create index cdr_disposition_201703 on cdr_201703(disposition);
CREATE TABLE cdr_201704 ( CHECK ( calldate >= '2017-04-01' and calldate <'2017-05-01' ) ) INHERITS (cdr);
create index cdr_calldate_201704 on cdr_201704(calldate);
create index cdr_src_201704 on cdr_201704(src);
create index cdr_dst_201704 on cdr_201704(dst);
create index cdr_disposition_201704 on cdr_201704(disposition);
CREATE TABLE cdr_201705 ( CHECK ( calldate >= '2017-05-01' and calldate <'2017-06-01' ) ) INHERITS (cdr);
create index cdr_calldate_201705 on cdr_201705(calldate);
create index cdr_src_201705 on cdr_201705(src);
create index cdr_dst_201705 on cdr_201705(dst);
create index cdr_disposition_201705 on cdr_201705(disposition);
CREATE TABLE cdr_201706 ( CHECK ( calldate >= '2017-06-01' and calldate <'2017-07-01' ) ) INHERITS (cdr);
create index cdr_calldate_201706 on cdr_201706(calldate);
create index cdr_src_201706 on cdr_201706(src);
create index cdr_dst_201706 on cdr_201706(dst);
create index cdr_disposition_201706 on cdr_201706(disposition);
CREATE TABLE cdr_201707 ( CHECK ( calldate >= '2017-07-01' and calldate <'2017-08-01' ) ) INHERITS (cdr);
create index cdr_calldate_201707 on cdr_201707(calldate);
create index cdr_src_201707 on cdr_201707(src);
create index cdr_dst_201707 on cdr_201707(dst);
create index cdr_disposition_201707 on cdr_201707(disposition);
CREATE TABLE cdr_201708 ( CHECK ( calldate >= '2017-08-01' and calldate <'2017-09-01' ) ) INHERITS (cdr);
create index cdr_calldate_201708 on cdr_201708(calldate);
create index cdr_src_201708 on cdr_201708(src);
create index cdr_dst_201708 on cdr_201708(dst);
create index cdr_disposition_201708 on cdr_201708(disposition);
CREATE TABLE cdr_201709 ( CHECK ( calldate >= '2017-09-01' and calldate <'2017-10-01' ) ) INHERITS (cdr);
create index cdr_calldate_201709 on cdr_201709(calldate);
create index cdr_src_201709 on cdr_201709(src);
create index cdr_dst_201709 on cdr_201709(dst);
create index cdr_disposition_201709 on cdr_201709(disposition);
CREATE TABLE cdr_201710 ( CHECK ( calldate >= '2017-10-01' and calldate <'2017-11-01' ) ) INHERITS (cdr);
create index cdr_calldate_201710 on cdr_201710(calldate);
create index cdr_src_201710 on cdr_201710(src);
create index cdr_dst_201710 on cdr_201710(dst);
create index cdr_disposition_201710 on cdr_201710(disposition);
CREATE TABLE cdr_201711 ( CHECK ( calldate >= '2017-11-01' and calldate <'2017-12-01' ) ) INHERITS (cdr);
create index cdr_calldate_201711 on cdr_201711(calldate);
create index cdr_src_201711 on cdr_201711(src);
create index cdr_dst_201711 on cdr_201711(dst);
create index cdr_disposition_201711 on cdr_201711(disposition);
CREATE TABLE cdr_201712 ( CHECK ( calldate >= '2017-12-01' and calldate <'2018-01-01' ) ) INHERITS (cdr);
create index cdr_calldate_201712 on cdr_201712(calldate);
create index cdr_src_201712 on cdr_201712(src);
create index cdr_dst_201712 on cdr_201712(dst);
create index cdr_disposition_201712 on cdr_201712(disposition);
CREATE TABLE cdr_201801 ( CHECK ( calldate >= '2018-01-01' and calldate <'2018-02-01' ) ) INHERITS (cdr);
create index cdr_calldate_201801 on cdr_201801(calldate);
create index cdr_src_201801 on cdr_201801(src);
create index cdr_dst_201801 on cdr_201801(dst);
create index cdr_disposition_201801 on cdr_201801(disposition);
CREATE TABLE cdr_201802 ( CHECK ( calldate >= '2018-02-01' and calldate <'2018-03-01' ) ) INHERITS (cdr);
create index cdr_calldate_201802 on cdr_201802(calldate);
create index cdr_src_201802 on cdr_201802(src);
create index cdr_dst_201802 on cdr_201802(dst);
create index cdr_disposition_201802 on cdr_201802(disposition);
CREATE TABLE cdr_201803 ( CHECK ( calldate >= '2018-03-01' and calldate <'2018-04-01' ) ) INHERITS (cdr);
create index cdr_calldate_201803 on cdr_201803(calldate);
create index cdr_src_201803 on cdr_201803(src);
create index cdr_dst_201803 on cdr_201803(dst);
create index cdr_disposition_201803 on cdr_201803(disposition);
CREATE TABLE cdr_201804 ( CHECK ( calldate >= '2018-04-01' and calldate <'2018-05-01' ) ) INHERITS (cdr);
create index cdr_calldate_201804 on cdr_201804(calldate);
create index cdr_src_201804 on cdr_201804(src);
create index cdr_dst_201804 on cdr_201804(dst);
create index cdr_disposition_201804 on cdr_201804(disposition);
CREATE TABLE cdr_201805 ( CHECK ( calldate >= '2018-05-01' and calldate <'2018-06-01' ) ) INHERITS (cdr);
create index cdr_calldate_201805 on cdr_201805(calldate);
create index cdr_src_201805 on cdr_201805(src);
create index cdr_dst_201805 on cdr_201805(dst);
create index cdr_disposition_201805 on cdr_201805(disposition);
CREATE TABLE cdr_201806 ( CHECK ( calldate >= '2018-06-01' and calldate <'2018-07-01' ) ) INHERITS (cdr);
create index cdr_calldate_201806 on cdr_201806(calldate);
create index cdr_src_201806 on cdr_201806(src);
create index cdr_dst_201806 on cdr_201806(dst);
create index cdr_disposition_201806 on cdr_201806(disposition);
CREATE TABLE cdr_201807 ( CHECK ( calldate >= '2018-07-01' and calldate <'2018-08-01' ) ) INHERITS (cdr);
create index cdr_calldate_201807 on cdr_201807(calldate);
create index cdr_src_201807 on cdr_201807(src);
create index cdr_dst_201807 on cdr_201807(dst);
create index cdr_disposition_201807 on cdr_201807(disposition);
CREATE TABLE cdr_201808 ( CHECK ( calldate >= '2018-08-01' and calldate <'2018-09-01' ) ) INHERITS (cdr);
create index cdr_calldate_201808 on cdr_201808(calldate);
create index cdr_src_201808 on cdr_201808(src);
create index cdr_dst_201808 on cdr_201808(dst);
create index cdr_disposition_201808 on cdr_201808(disposition);
CREATE TABLE cdr_201809 ( CHECK ( calldate >= '2018-09-01' and calldate <'2018-10-01' ) ) INHERITS (cdr);
create index cdr_calldate_201809 on cdr_201809(calldate);
create index cdr_src_201809 on cdr_201809(src);
create index cdr_dst_201809 on cdr_201809(dst);
create index cdr_disposition_201809 on cdr_201809(disposition);
CREATE TABLE cdr_201810 ( CHECK ( calldate >= '2018-10-01' and calldate <'2018-11-01' ) ) INHERITS (cdr);
create index cdr_calldate_201810 on cdr_201810(calldate);
create index cdr_src_201810 on cdr_201810(src);
create index cdr_dst_201810 on cdr_201810(dst);
create index cdr_disposition_201810 on cdr_201810(disposition);
CREATE TABLE cdr_201811 ( CHECK ( calldate >= '2018-11-01' and calldate <'2018-12-01' ) ) INHERITS (cdr);
create index cdr_calldate_201811 on cdr_201811(calldate);
create index cdr_src_201811 on cdr_201811(src);
create index cdr_dst_201811 on cdr_201811(dst);
create index cdr_disposition_201811 on cdr_201811(disposition);
CREATE TABLE cdr_201812 ( CHECK ( calldate >= '2018-12-01' and calldate <'2019-01-01' ) ) INHERITS (cdr);
create index cdr_calldate_201812 on cdr_201812(calldate);
create index cdr_src_201812 on cdr_201812(src);
create index cdr_dst_201812 on cdr_201812(dst);
create index cdr_disposition_201812 on cdr_201812(disposition);
CREATE TABLE cdr_201901 ( CHECK ( calldate >= '2019-01-01' and calldate <'2019-02-01' ) ) INHERITS (cdr);
create index cdr_calldate_201901 on cdr_201901(calldate);
create index cdr_src_201901 on cdr_201901(src);
create index cdr_dst_201901 on cdr_201901(dst);
create index cdr_disposition_201901 on cdr_201901(disposition);
CREATE TABLE cdr_201902 ( CHECK ( calldate >= '2019-02-01' and calldate <'2019-03-01' ) ) INHERITS (cdr);
create index cdr_calldate_201902 on cdr_201902(calldate);
create index cdr_src_201902 on cdr_201902(src);
create index cdr_dst_201902 on cdr_201902(dst);
create index cdr_disposition_201902 on cdr_201902(disposition);
CREATE TABLE cdr_201903 ( CHECK ( calldate >= '2019-03-01' and calldate <'2019-04-01' ) ) INHERITS (cdr);
create index cdr_calldate_201903 on cdr_201903(calldate);
create index cdr_src_201903 on cdr_201903(src);
create index cdr_dst_201903 on cdr_201903(dst);
create index cdr_disposition_201903 on cdr_201903(disposition);
CREATE TABLE cdr_201904 ( CHECK ( calldate >= '2019-04-01' and calldate <'2019-05-01' ) ) INHERITS (cdr);
create index cdr_calldate_201904 on cdr_201904(calldate);
create index cdr_src_201904 on cdr_201904(src);
create index cdr_dst_201904 on cdr_201904(dst);
create index cdr_disposition_201904 on cdr_201904(disposition);
CREATE TABLE cdr_201905 ( CHECK ( calldate >= '2019-05-01' and calldate <'2019-06-01' ) ) INHERITS (cdr);
create index cdr_calldate_201905 on cdr_201905(calldate);
create index cdr_src_201905 on cdr_201905(src);
create index cdr_dst_201905 on cdr_201905(dst);
create index cdr_disposition_201905 on cdr_201905(disposition);
CREATE TABLE cdr_201906 ( CHECK ( calldate >= '2019-06-01' and calldate <'2019-07-01' ) ) INHERITS (cdr);
create index cdr_calldate_201906 on cdr_201906(calldate);
create index cdr_src_201906 on cdr_201906(src);
create index cdr_dst_201906 on cdr_201906(dst);
create index cdr_disposition_201906 on cdr_201906(disposition);
CREATE TABLE cdr_201907 ( CHECK ( calldate >= '2019-07-01' and calldate <'2019-08-01' ) ) INHERITS (cdr);
create index cdr_calldate_201907 on cdr_201907(calldate);
create index cdr_src_201907 on cdr_201907(src);
create index cdr_dst_201907 on cdr_201907(dst);
create index cdr_disposition_201907 on cdr_201907(disposition);
CREATE TABLE cdr_201908 ( CHECK ( calldate >= '2019-08-01' and calldate <'2019-09-01' ) ) INHERITS (cdr);
create index cdr_calldate_201908 on cdr_201908(calldate);
create index cdr_src_201908 on cdr_201908(src);
create index cdr_dst_201908 on cdr_201908(dst);
create index cdr_disposition_201908 on cdr_201908(disposition);
CREATE TABLE cdr_201909 ( CHECK ( calldate >= '2019-09-01' and calldate <'2019-10-01' ) ) INHERITS (cdr);
create index cdr_calldate_201909 on cdr_201909(calldate);
create index cdr_src_201909 on cdr_201909(src);
create index cdr_dst_201909 on cdr_201909(dst);
create index cdr_disposition_201909 on cdr_201909(disposition);
CREATE TABLE cdr_201910 ( CHECK ( calldate >= '2019-10-01' and calldate <'2019-11-01' ) ) INHERITS (cdr);
create index cdr_calldate_201910 on cdr_201910(calldate);
create index cdr_src_201910 on cdr_201910(src);
create index cdr_dst_201910 on cdr_201910(dst);
create index cdr_disposition_201910 on cdr_201910(disposition);
CREATE TABLE cdr_201911 ( CHECK ( calldate >= '2019-11-01' and calldate <'2019-12-01' ) ) INHERITS (cdr);
create index cdr_calldate_201911 on cdr_201911(calldate);
create index cdr_src_201911 on cdr_201911(src);
create index cdr_dst_201911 on cdr_201911(dst);
create index cdr_disposition_201911 on cdr_201911(disposition);
CREATE TABLE cdr_201912 ( CHECK ( calldate >= '2019-12-01' and calldate <'2020-01-01' ) ) INHERITS (cdr);
create index cdr_calldate_201912 on cdr_201912(calldate);
create index cdr_src_201912 on cdr_201912(src);
create index cdr_dst_201912 on cdr_201912(dst);
create index cdr_disposition_201912 on cdr_201912(disposition);
CREATE TABLE cdr_202001 ( CHECK ( calldate >= '2020-01-01' and calldate <'2020-02-01' ) ) INHERITS (cdr);
create index cdr_calldate_202001 on cdr_202001(calldate);
create index cdr_src_202001 on cdr_202001(src);
create index cdr_dst_202001 on cdr_202001(dst);
create index cdr_disposition_202001 on cdr_202001(disposition);
CREATE TABLE cdr_202002 ( CHECK ( calldate >= '2020-02-01' and calldate <'2020-03-01' ) ) INHERITS (cdr);
create index cdr_calldate_202002 on cdr_202002(calldate);
create index cdr_src_202002 on cdr_202002(src);
create index cdr_dst_202002 on cdr_202002(dst);
create index cdr_disposition_202002 on cdr_202002(disposition);
CREATE TABLE cdr_202003 ( CHECK ( calldate >= '2020-03-01' and calldate <'2020-04-01' ) ) INHERITS (cdr);
create index cdr_calldate_202003 on cdr_202003(calldate);
create index cdr_src_202003 on cdr_202003(src);
create index cdr_dst_202003 on cdr_202003(dst);
create index cdr_disposition_202003 on cdr_202003(disposition);
CREATE TABLE cdr_202004 ( CHECK ( calldate >= '2020-04-01' and calldate <'2020-05-01' ) ) INHERITS (cdr);
create index cdr_calldate_202004 on cdr_202004(calldate);
create index cdr_src_202004 on cdr_202004(src);
create index cdr_dst_202004 on cdr_202004(dst);
create index cdr_disposition_202004 on cdr_202004(disposition);
CREATE TABLE cdr_202005 ( CHECK ( calldate >= '2020-05-01' and calldate <'2020-06-01' ) ) INHERITS (cdr);
create index cdr_calldate_202005 on cdr_202005(calldate);
create index cdr_src_202005 on cdr_202005(src);
create index cdr_dst_202005 on cdr_202005(dst);
create index cdr_disposition_202005 on cdr_202005(disposition);
CREATE TABLE cdr_202006 ( CHECK ( calldate >= '2020-06-01' and calldate <'2020-07-01' ) ) INHERITS (cdr);
create index cdr_calldate_202006 on cdr_202006(calldate);
create index cdr_src_202006 on cdr_202006(src);
create index cdr_dst_202006 on cdr_202006(dst);
create index cdr_disposition_202006 on cdr_202006(disposition);
CREATE TABLE cdr_202007 ( CHECK ( calldate >= '2020-07-01' and calldate <'2020-08-01' ) ) INHERITS (cdr);
create index cdr_calldate_202007 on cdr_202007(calldate);
create index cdr_src_202007 on cdr_202007(src);
create index cdr_dst_202007 on cdr_202007(dst);
create index cdr_disposition_202007 on cdr_202007(disposition);
CREATE TABLE cdr_202008 ( CHECK ( calldate >= '2020-08-01' and calldate <'2020-09-01' ) ) INHERITS (cdr);
create index cdr_calldate_202008 on cdr_202008(calldate);
create index cdr_src_202008 on cdr_202008(src);
create index cdr_dst_202008 on cdr_202008(dst);
create index cdr_disposition_202008 on cdr_202008(disposition);
CREATE TABLE cdr_202009 ( CHECK ( calldate >= '2020-09-01' and calldate <'2020-10-01' ) ) INHERITS (cdr);
create index cdr_calldate_202009 on cdr_202009(calldate);
create index cdr_src_202009 on cdr_202009(src);
create index cdr_dst_202009 on cdr_202009(dst);
create index cdr_disposition_202009 on cdr_202009(disposition);
CREATE TABLE cdr_202010 ( CHECK ( calldate >= '2020-10-01' and calldate <'2020-11-01' ) ) INHERITS (cdr);
create index cdr_calldate_202010 on cdr_202010(calldate);
create index cdr_src_202010 on cdr_202010(src);
create index cdr_dst_202010 on cdr_202010(dst);
create index cdr_disposition_202010 on cdr_202010(disposition);
CREATE TABLE cdr_202011 ( CHECK ( calldate >= '2020-11-01' and calldate <'2020-12-01' ) ) INHERITS (cdr);
create index cdr_calldate_202011 on cdr_202011(calldate);
create index cdr_src_202011 on cdr_202011(src);
create index cdr_dst_202011 on cdr_202011(dst);
create index cdr_disposition_202011 on cdr_202011(disposition);
CREATE TABLE cdr_202012 ( CHECK ( calldate >= '2020-12-01' and calldate <'2021-01-01' ) ) INHERITS (cdr);
create index cdr_calldate_202012 on cdr_202012(calldate);
create index cdr_src_202012 on cdr_202012(src);
create index cdr_dst_202012 on cdr_202012(dst);
create index cdr_disposition_202012 on cdr_202012(disposition);
CREATE TABLE cdr_202101 ( CHECK ( calldate >= '2021-01-01' and calldate <'2021-02-01' ) ) INHERITS (cdr);
create index cdr_calldate_202101 on cdr_202101(calldate);
create index cdr_src_202101 on cdr_202101(src);
create index cdr_dst_202101 on cdr_202101(dst);
create index cdr_disposition_202101 on cdr_202101(disposition);
CREATE TABLE cdr_202102 ( CHECK ( calldate >= '2021-02-01' and calldate <'2021-03-01' ) ) INHERITS (cdr);
create index cdr_calldate_202102 on cdr_202102(calldate);
create index cdr_src_202102 on cdr_202102(src);
create index cdr_dst_202102 on cdr_202102(dst);
create index cdr_disposition_202102 on cdr_202102(disposition);
CREATE TABLE cdr_202103 ( CHECK ( calldate >= '2021-03-01' and calldate <'2021-04-01' ) ) INHERITS (cdr);
create index cdr_calldate_202103 on cdr_202103(calldate);
create index cdr_src_202103 on cdr_202103(src);
create index cdr_dst_202103 on cdr_202103(dst);
create index cdr_disposition_202103 on cdr_202103(disposition);
CREATE TABLE cdr_202104 ( CHECK ( calldate >= '2021-04-01' and calldate <'2021-05-01' ) ) INHERITS (cdr);
create index cdr_calldate_202104 on cdr_202104(calldate);
create index cdr_src_202104 on cdr_202104(src);
create index cdr_dst_202104 on cdr_202104(dst);
create index cdr_disposition_202104 on cdr_202104(disposition);
CREATE TABLE cdr_202105 ( CHECK ( calldate >= '2021-05-01' and calldate <'2021-06-01' ) ) INHERITS (cdr);
create index cdr_calldate_202105 on cdr_202105(calldate);
create index cdr_src_202105 on cdr_202105(src);
create index cdr_dst_202105 on cdr_202105(dst);
create index cdr_disposition_202105 on cdr_202105(disposition);
CREATE TABLE cdr_202106 ( CHECK ( calldate >= '2021-06-01' and calldate <'2021-07-01' ) ) INHERITS (cdr);
create index cdr_calldate_202106 on cdr_202106(calldate);
create index cdr_src_202106 on cdr_202106(src);
create index cdr_dst_202106 on cdr_202106(dst);
create index cdr_disposition_202106 on cdr_202106(disposition);
CREATE TABLE cdr_202107 ( CHECK ( calldate >= '2021-07-01' and calldate <'2021-08-01' ) ) INHERITS (cdr);
create index cdr_calldate_202107 on cdr_202107(calldate);
create index cdr_src_202107 on cdr_202107(src);
create index cdr_dst_202107 on cdr_202107(dst);
create index cdr_disposition_202107 on cdr_202107(disposition);
CREATE TABLE cdr_202108 ( CHECK ( calldate >= '2021-08-01' and calldate <'2021-09-01' ) ) INHERITS (cdr);
create index cdr_calldate_202108 on cdr_202108(calldate);
create index cdr_src_202108 on cdr_202108(src);
create index cdr_dst_202108 on cdr_202108(dst);
create index cdr_disposition_202108 on cdr_202108(disposition);
CREATE TABLE cdr_202109 ( CHECK ( calldate >= '2021-09-01' and calldate <'2021-10-01' ) ) INHERITS (cdr);
create index cdr_calldate_202109 on cdr_202109(calldate);
create index cdr_src_202109 on cdr_202109(src);
create index cdr_dst_202109 on cdr_202109(dst);
create index cdr_disposition_202109 on cdr_202109(disposition);
CREATE TABLE cdr_202110 ( CHECK ( calldate >= '2021-10-01' and calldate <'2021-11-01' ) ) INHERITS (cdr);
create index cdr_calldate_202110 on cdr_202110(calldate);
create index cdr_src_202110 on cdr_202110(src);
create index cdr_dst_202110 on cdr_202110(dst);
create index cdr_disposition_202110 on cdr_202110(disposition);
CREATE TABLE cdr_202111 ( CHECK ( calldate >= '2021-11-01' and calldate <'2021-12-01' ) ) INHERITS (cdr);
create index cdr_calldate_202111 on cdr_202111(calldate);
create index cdr_src_202111 on cdr_202111(src);
create index cdr_dst_202111 on cdr_202111(dst);
create index cdr_disposition_202111 on cdr_202111(disposition);
CREATE TABLE cdr_202112 ( CHECK ( calldate >= '2021-12-01' and calldate <'2022-01-01' ) ) INHERITS (cdr);
create index cdr_calldate_202112 on cdr_202112(calldate);
create index cdr_src_202112 on cdr_202112(src);
create index cdr_dst_202112 on cdr_202112(dst);
create index cdr_disposition_202112 on cdr_202112(disposition);
CREATE TABLE cdr_202201 ( CHECK ( calldate >= '2022-01-01' and calldate <'2022-02-01' ) ) INHERITS (cdr);
create index cdr_calldate_202201 on cdr_202201(calldate);
create index cdr_src_202201 on cdr_202201(src);
create index cdr_dst_202201 on cdr_202201(dst);
create index cdr_disposition_202201 on cdr_202201(disposition);
CREATE TABLE cdr_202202 ( CHECK ( calldate >= '2022-02-01' and calldate <'2022-03-01' ) ) INHERITS (cdr);
create index cdr_calldate_202202 on cdr_202202(calldate);
create index cdr_src_202202 on cdr_202202(src);
create index cdr_dst_202202 on cdr_202202(dst);
create index cdr_disposition_202202 on cdr_202202(disposition);
CREATE TABLE cdr_202203 ( CHECK ( calldate >= '2022-03-01' and calldate <'2022-04-01' ) ) INHERITS (cdr);
create index cdr_calldate_202203 on cdr_202203(calldate);
create index cdr_src_202203 on cdr_202203(src);
create index cdr_dst_202203 on cdr_202203(dst);
create index cdr_disposition_202203 on cdr_202203(disposition);
CREATE TABLE cdr_202204 ( CHECK ( calldate >= '2022-04-01' and calldate <'2022-05-01' ) ) INHERITS (cdr);
create index cdr_calldate_202204 on cdr_202204(calldate);
create index cdr_src_202204 on cdr_202204(src);
create index cdr_dst_202204 on cdr_202204(dst);
create index cdr_disposition_202204 on cdr_202204(disposition);
CREATE TABLE cdr_202205 ( CHECK ( calldate >= '2022-05-01' and calldate <'2022-06-01' ) ) INHERITS (cdr);
create index cdr_calldate_202205 on cdr_202205(calldate);
create index cdr_src_202205 on cdr_202205(src);
create index cdr_dst_202205 on cdr_202205(dst);
create index cdr_disposition_202205 on cdr_202205(disposition);
CREATE TABLE cdr_202206 ( CHECK ( calldate >= '2022-06-01' and calldate <'2022-07-01' ) ) INHERITS (cdr);
create index cdr_calldate_202206 on cdr_202206(calldate);
create index cdr_src_202206 on cdr_202206(src);
create index cdr_dst_202206 on cdr_202206(dst);
create index cdr_disposition_202206 on cdr_202206(disposition);
CREATE TABLE cdr_202207 ( CHECK ( calldate >= '2022-07-01' and calldate <'2022-08-01' ) ) INHERITS (cdr);
create index cdr_calldate_202207 on cdr_202207(calldate);
create index cdr_src_202207 on cdr_202207(src);
create index cdr_dst_202207 on cdr_202207(dst);
create index cdr_disposition_202207 on cdr_202207(disposition);
CREATE TABLE cdr_202208 ( CHECK ( calldate >= '2022-08-01' and calldate <'2022-09-01' ) ) INHERITS (cdr);
create index cdr_calldate_202208 on cdr_202208(calldate);
create index cdr_src_202208 on cdr_202208(src);
create index cdr_dst_202208 on cdr_202208(dst);
create index cdr_disposition_202208 on cdr_202208(disposition);
CREATE TABLE cdr_202209 ( CHECK ( calldate >= '2022-09-01' and calldate <'2022-10-01' ) ) INHERITS (cdr);
create index cdr_calldate_202209 on cdr_202209(calldate);
create index cdr_src_202209 on cdr_202209(src);
create index cdr_dst_202209 on cdr_202209(dst);
create index cdr_disposition_202209 on cdr_202209(disposition);
CREATE TABLE cdr_202210 ( CHECK ( calldate >= '2022-10-01' and calldate <'2022-11-01' ) ) INHERITS (cdr);
create index cdr_calldate_202210 on cdr_202210(calldate);
create index cdr_src_202210 on cdr_202210(src);
create index cdr_dst_202210 on cdr_202210(dst);
create index cdr_disposition_202210 on cdr_202210(disposition);
CREATE TABLE cdr_202211 ( CHECK ( calldate >= '2022-11-01' and calldate <'2022-12-01' ) ) INHERITS (cdr);
create index cdr_calldate_202211 on cdr_202211(calldate);
create index cdr_src_202211 on cdr_202211(src);
create index cdr_dst_202211 on cdr_202211(dst);
create index cdr_disposition_202211 on cdr_202211(disposition);
CREATE TABLE cdr_202212 ( CHECK ( calldate >= '2022-12-01' and calldate <'2023-01-01' ) ) INHERITS (cdr);
create index cdr_calldate_202212 on cdr_202212(calldate);
create index cdr_src_202212 on cdr_202212(src);
create index cdr_dst_202212 on cdr_202212(dst);
create index cdr_disposition_202212 on cdr_202212(disposition);
CREATE OR REPLACE FUNCTION cdr_insert_trigger() 
        RETURNS TRIGGER AS $$
        BEGIN
             IF ( NEW.calldate >= DATE '2015-01-01' AND
                  NEW.calldate < DATE '2015-02-01' ) THEN
                  INSERT INTO cdr_201501 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2015-02-01' AND
                        NEW.calldate < DATE '2015-03-01' ) THEN
                                INSERT INTO cdr_201502 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2015-03-01' AND
                        NEW.calldate < DATE '2015-04-01' ) THEN
                                INSERT INTO cdr_201503 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2015-04-01' AND
                        NEW.calldate < DATE '2015-05-01' ) THEN
                                INSERT INTO cdr_201504 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2015-05-01' AND
                        NEW.calldate < DATE '2015-06-01' ) THEN
                                INSERT INTO cdr_201505 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2015-06-01' AND
                        NEW.calldate < DATE '2015-07-01' ) THEN
                                INSERT INTO cdr_201506 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2015-07-01' AND
                        NEW.calldate < DATE '2015-08-01' ) THEN
                                INSERT INTO cdr_201507 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2015-08-01' AND
                        NEW.calldate < DATE '2015-09-01' ) THEN
                                INSERT INTO cdr_201508 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2015-09-01' AND
                        NEW.calldate < DATE '2015-10-01' ) THEN
                                INSERT INTO cdr_201509 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2015-10-01' AND
                        NEW.calldate < DATE '2015-11-01' ) THEN
                                INSERT INTO cdr_201510 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2015-11-01' AND
                        NEW.calldate < DATE '2015-12-01' ) THEN
                                INSERT INTO cdr_201511 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2015-12-01' AND
                        NEW.calldate < DATE '2016-01-01' ) THEN
                                INSERT INTO cdr_201512 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2016-01-01' AND
                        NEW.calldate < DATE '2016-02-01' ) THEN
                                INSERT INTO cdr_201601 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2016-02-01' AND
                        NEW.calldate < DATE '2016-03-01' ) THEN
                                INSERT INTO cdr_201602 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2016-03-01' AND
                        NEW.calldate < DATE '2016-04-01' ) THEN
                                INSERT INTO cdr_201603 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2016-04-01' AND
                        NEW.calldate < DATE '2016-05-01' ) THEN
                                INSERT INTO cdr_201604 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2016-05-01' AND
                        NEW.calldate < DATE '2016-06-01' ) THEN
                                INSERT INTO cdr_201605 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2016-06-01' AND
                        NEW.calldate < DATE '2016-07-01' ) THEN
                                INSERT INTO cdr_201606 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2016-07-01' AND
                        NEW.calldate < DATE '2016-08-01' ) THEN
                                INSERT INTO cdr_201607 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2016-08-01' AND
                        NEW.calldate < DATE '2016-09-01' ) THEN
                                INSERT INTO cdr_201608 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2016-09-01' AND
                        NEW.calldate < DATE '2016-10-01' ) THEN
                                INSERT INTO cdr_201609 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2016-10-01' AND
                        NEW.calldate < DATE '2016-11-01' ) THEN
                                INSERT INTO cdr_201610 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2016-11-01' AND
                        NEW.calldate < DATE '2016-12-01' ) THEN
                                INSERT INTO cdr_201611 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2016-12-01' AND
                        NEW.calldate < DATE '2017-01-01' ) THEN
                                INSERT INTO cdr_201612 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2017-01-01' AND
                        NEW.calldate < DATE '2017-02-01' ) THEN
                                INSERT INTO cdr_201701 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2017-02-01' AND
                        NEW.calldate < DATE '2017-03-01' ) THEN
                                INSERT INTO cdr_201702 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2017-03-01' AND
                        NEW.calldate < DATE '2017-04-01' ) THEN
                                INSERT INTO cdr_201703 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2017-04-01' AND
                        NEW.calldate < DATE '2017-05-01' ) THEN
                                INSERT INTO cdr_201704 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2017-05-01' AND
                        NEW.calldate < DATE '2017-06-01' ) THEN
                                INSERT INTO cdr_201705 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2017-06-01' AND
                        NEW.calldate < DATE '2017-07-01' ) THEN
                                INSERT INTO cdr_201706 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2017-07-01' AND
                        NEW.calldate < DATE '2017-08-01' ) THEN
                                INSERT INTO cdr_201707 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2017-08-01' AND
                        NEW.calldate < DATE '2017-09-01' ) THEN
                                INSERT INTO cdr_201708 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2017-09-01' AND
                        NEW.calldate < DATE '2017-10-01' ) THEN
                                INSERT INTO cdr_201709 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2017-10-01' AND
                        NEW.calldate < DATE '2017-11-01' ) THEN
                                INSERT INTO cdr_201710 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2017-11-01' AND
                        NEW.calldate < DATE '2017-12-01' ) THEN
                                INSERT INTO cdr_201711 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2017-12-01' AND
                        NEW.calldate < DATE '2018-01-01' ) THEN
                                INSERT INTO cdr_201712 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2018-01-01' AND
                        NEW.calldate < DATE '2018-02-01' ) THEN
                                INSERT INTO cdr_201801 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2018-02-01' AND
                        NEW.calldate < DATE '2018-03-01' ) THEN
                                INSERT INTO cdr_201802 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2018-03-01' AND
                        NEW.calldate < DATE '2018-04-01' ) THEN
                                INSERT INTO cdr_201803 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2018-04-01' AND
                        NEW.calldate < DATE '2018-05-01' ) THEN
                                INSERT INTO cdr_201804 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2018-05-01' AND
                        NEW.calldate < DATE '2018-06-01' ) THEN
                                INSERT INTO cdr_201805 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2018-06-01' AND
                        NEW.calldate < DATE '2018-07-01' ) THEN
                                INSERT INTO cdr_201806 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2018-07-01' AND
                        NEW.calldate < DATE '2018-08-01' ) THEN
                                INSERT INTO cdr_201807 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2018-08-01' AND
                        NEW.calldate < DATE '2018-09-01' ) THEN
                                INSERT INTO cdr_201808 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2018-09-01' AND
                        NEW.calldate < DATE '2018-10-01' ) THEN
                                INSERT INTO cdr_201809 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2018-10-01' AND
                        NEW.calldate < DATE '2018-11-01' ) THEN
                                INSERT INTO cdr_201810 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2018-11-01' AND
                        NEW.calldate < DATE '2018-12-01' ) THEN
                                INSERT INTO cdr_201811 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2018-12-01' AND
                        NEW.calldate < DATE '2019-01-01' ) THEN
                                INSERT INTO cdr_201812 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2019-01-01' AND
                        NEW.calldate < DATE '2019-02-01' ) THEN
                                INSERT INTO cdr_201901 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2019-02-01' AND
                        NEW.calldate < DATE '2019-03-01' ) THEN
                                INSERT INTO cdr_201902 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2019-03-01' AND
                        NEW.calldate < DATE '2019-04-01' ) THEN
                                INSERT INTO cdr_201903 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2019-04-01' AND
                        NEW.calldate < DATE '2019-05-01' ) THEN
                                INSERT INTO cdr_201904 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2019-05-01' AND
                        NEW.calldate < DATE '2019-06-01' ) THEN
                                INSERT INTO cdr_201905 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2019-06-01' AND
                        NEW.calldate < DATE '2019-07-01' ) THEN
                                INSERT INTO cdr_201906 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2019-07-01' AND
                        NEW.calldate < DATE '2019-08-01' ) THEN
                                INSERT INTO cdr_201907 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2019-08-01' AND
                        NEW.calldate < DATE '2019-09-01' ) THEN
                                INSERT INTO cdr_201908 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2019-09-01' AND
                        NEW.calldate < DATE '2019-10-01' ) THEN
                                INSERT INTO cdr_201909 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2019-10-01' AND
                        NEW.calldate < DATE '2019-11-01' ) THEN
                                INSERT INTO cdr_201910 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2019-11-01' AND
                        NEW.calldate < DATE '2019-12-01' ) THEN
                                INSERT INTO cdr_201911 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2019-12-01' AND
                        NEW.calldate < DATE '2020-01-01' ) THEN
                                INSERT INTO cdr_201912 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2020-01-01' AND
                        NEW.calldate < DATE '2020-02-01' ) THEN
                                INSERT INTO cdr_202001 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2020-02-01' AND
                        NEW.calldate < DATE '2020-03-01' ) THEN
                                INSERT INTO cdr_202002 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2020-03-01' AND
                        NEW.calldate < DATE '2020-04-01' ) THEN
                                INSERT INTO cdr_202003 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2020-04-01' AND
                        NEW.calldate < DATE '2020-05-01' ) THEN
                                INSERT INTO cdr_202004 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2020-05-01' AND
                        NEW.calldate < DATE '2020-06-01' ) THEN
                                INSERT INTO cdr_202005 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2020-06-01' AND
                        NEW.calldate < DATE '2020-07-01' ) THEN
                                INSERT INTO cdr_202006 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2020-07-01' AND
                        NEW.calldate < DATE '2020-08-01' ) THEN
                                INSERT INTO cdr_202007 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2020-08-01' AND
                        NEW.calldate < DATE '2020-09-01' ) THEN
                                INSERT INTO cdr_202008 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2020-09-01' AND
                        NEW.calldate < DATE '2020-10-01' ) THEN
                                INSERT INTO cdr_202009 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2020-10-01' AND
                        NEW.calldate < DATE '2020-11-01' ) THEN
                                INSERT INTO cdr_202010 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2020-11-01' AND
                        NEW.calldate < DATE '2020-12-01' ) THEN
                                INSERT INTO cdr_202011 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2020-12-01' AND
                        NEW.calldate < DATE '2021-01-01' ) THEN
                                INSERT INTO cdr_202012 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2021-01-01' AND
                        NEW.calldate < DATE '2021-02-01' ) THEN
                                INSERT INTO cdr_202101 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2021-02-01' AND
                        NEW.calldate < DATE '2021-03-01' ) THEN
                                INSERT INTO cdr_202102 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2021-03-01' AND
                        NEW.calldate < DATE '2021-04-01' ) THEN
                                INSERT INTO cdr_202103 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2021-04-01' AND
                        NEW.calldate < DATE '2021-05-01' ) THEN
                                INSERT INTO cdr_202104 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2021-05-01' AND
                        NEW.calldate < DATE '2021-06-01' ) THEN
                                INSERT INTO cdr_202105 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2021-06-01' AND
                        NEW.calldate < DATE '2021-07-01' ) THEN
                                INSERT INTO cdr_202106 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2021-07-01' AND
                        NEW.calldate < DATE '2021-08-01' ) THEN
                                INSERT INTO cdr_202107 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2021-08-01' AND
                        NEW.calldate < DATE '2021-09-01' ) THEN
                                INSERT INTO cdr_202108 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2021-09-01' AND
                        NEW.calldate < DATE '2021-10-01' ) THEN
                                INSERT INTO cdr_202109 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2021-10-01' AND
                        NEW.calldate < DATE '2021-11-01' ) THEN
                                INSERT INTO cdr_202110 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2021-11-01' AND
                        NEW.calldate < DATE '2021-12-01' ) THEN
                                INSERT INTO cdr_202111 VALUES (NEW.*);
ELSIF ( NEW.calldate >= DATE '2021-12-01' AND
                        NEW.calldate < DATE '2022-01-01' ) THEN
                                INSERT INTO cdr_202112 VALUES (NEW.*);
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
CREATE TABLE recordings_201501 ( CHECK ( cdr_start >= '2015-01-01' and cdr_start <'2015-02-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201501 on recordings_201501(cdr_start);
create index recordings_src_201501 on recordings_201501(cdr_src);
create index recordings_dst_201501 on recordings_201501(cdr_dst);
create index recordings_uniqueid_201501 on recordings_201501(cdr_uniqueid);
CREATE TABLE recordings_201502 ( CHECK ( cdr_start >= '2015-02-01' and cdr_start <'2015-03-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201502 on recordings_201502(cdr_start);
create index recordings_src_201502 on recordings_201502(cdr_src);
create index recordings_dst_201502 on recordings_201502(cdr_dst);
create index recordings_uniqueid_201502 on recordings_201502(cdr_uniqueid);
CREATE TABLE recordings_201503 ( CHECK ( cdr_start >= '2015-03-01' and cdr_start <'2015-04-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201503 on recordings_201503(cdr_start);
create index recordings_src_201503 on recordings_201503(cdr_src);
create index recordings_dst_201503 on recordings_201503(cdr_dst);
create index recordings_uniqueid_201503 on recordings_201503(cdr_uniqueid);
CREATE TABLE recordings_201504 ( CHECK ( cdr_start >= '2015-04-01' and cdr_start <'2015-05-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201504 on recordings_201504(cdr_start);
create index recordings_src_201504 on recordings_201504(cdr_src);
create index recordings_dst_201504 on recordings_201504(cdr_dst);
create index recordings_uniqueid_201504 on recordings_201504(cdr_uniqueid);
CREATE TABLE recordings_201505 ( CHECK ( cdr_start >= '2015-05-01' and cdr_start <'2015-06-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201505 on recordings_201505(cdr_start);
create index recordings_src_201505 on recordings_201505(cdr_src);
create index recordings_dst_201505 on recordings_201505(cdr_dst);
create index recordings_uniqueid_201505 on recordings_201505(cdr_uniqueid);
CREATE TABLE recordings_201506 ( CHECK ( cdr_start >= '2015-06-01' and cdr_start <'2015-07-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201506 on recordings_201506(cdr_start);
create index recordings_src_201506 on recordings_201506(cdr_src);
create index recordings_dst_201506 on recordings_201506(cdr_dst);
create index recordings_uniqueid_201506 on recordings_201506(cdr_uniqueid);
CREATE TABLE recordings_201507 ( CHECK ( cdr_start >= '2015-07-01' and cdr_start <'2015-08-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201507 on recordings_201507(cdr_start);
create index recordings_src_201507 on recordings_201507(cdr_src);
create index recordings_dst_201507 on recordings_201507(cdr_dst);
create index recordings_uniqueid_201507 on recordings_201507(cdr_uniqueid);
CREATE TABLE recordings_201508 ( CHECK ( cdr_start >= '2015-08-01' and cdr_start <'2015-09-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201508 on recordings_201508(cdr_start);
create index recordings_src_201508 on recordings_201508(cdr_src);
create index recordings_dst_201508 on recordings_201508(cdr_dst);
create index recordings_uniqueid_201508 on recordings_201508(cdr_uniqueid);
CREATE TABLE recordings_201509 ( CHECK ( cdr_start >= '2015-09-01' and cdr_start <'2015-10-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201509 on recordings_201509(cdr_start);
create index recordings_src_201509 on recordings_201509(cdr_src);
create index recordings_dst_201509 on recordings_201509(cdr_dst);
create index recordings_uniqueid_201509 on recordings_201509(cdr_uniqueid);
CREATE TABLE recordings_201510 ( CHECK ( cdr_start >= '2015-10-01' and cdr_start <'2015-11-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201510 on recordings_201510(cdr_start);
create index recordings_src_201510 on recordings_201510(cdr_src);
create index recordings_dst_201510 on recordings_201510(cdr_dst);
create index recordings_uniqueid_201510 on recordings_201510(cdr_uniqueid);
CREATE TABLE recordings_201511 ( CHECK ( cdr_start >= '2015-11-01' and cdr_start <'2015-12-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201511 on recordings_201511(cdr_start);
create index recordings_src_201511 on recordings_201511(cdr_src);
create index recordings_dst_201511 on recordings_201511(cdr_dst);
create index recordings_uniqueid_201511 on recordings_201511(cdr_uniqueid);
CREATE TABLE recordings_201512 ( CHECK ( cdr_start >= '2015-12-01' and cdr_start <'2016-01-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201512 on recordings_201512(cdr_start);
create index recordings_src_201512 on recordings_201512(cdr_src);
create index recordings_dst_201512 on recordings_201512(cdr_dst);
create index recordings_uniqueid_201512 on recordings_201512(cdr_uniqueid);
CREATE TABLE recordings_201601 ( CHECK ( cdr_start >= '2016-01-01' and cdr_start <'2016-02-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201601 on recordings_201601(cdr_start);
create index recordings_src_201601 on recordings_201601(cdr_src);
create index recordings_dst_201601 on recordings_201601(cdr_dst);
create index recordings_uniqueid_201601 on recordings_201601(cdr_uniqueid);
CREATE TABLE recordings_201602 ( CHECK ( cdr_start >= '2016-02-01' and cdr_start <'2016-03-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201602 on recordings_201602(cdr_start);
create index recordings_src_201602 on recordings_201602(cdr_src);
create index recordings_dst_201602 on recordings_201602(cdr_dst);
create index recordings_uniqueid_201602 on recordings_201602(cdr_uniqueid);
CREATE TABLE recordings_201603 ( CHECK ( cdr_start >= '2016-03-01' and cdr_start <'2016-04-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201603 on recordings_201603(cdr_start);
create index recordings_src_201603 on recordings_201603(cdr_src);
create index recordings_dst_201603 on recordings_201603(cdr_dst);
create index recordings_uniqueid_201603 on recordings_201603(cdr_uniqueid);
CREATE TABLE recordings_201604 ( CHECK ( cdr_start >= '2016-04-01' and cdr_start <'2016-05-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201604 on recordings_201604(cdr_start);
create index recordings_src_201604 on recordings_201604(cdr_src);
create index recordings_dst_201604 on recordings_201604(cdr_dst);
create index recordings_uniqueid_201604 on recordings_201604(cdr_uniqueid);
CREATE TABLE recordings_201605 ( CHECK ( cdr_start >= '2016-05-01' and cdr_start <'2016-06-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201605 on recordings_201605(cdr_start);
create index recordings_src_201605 on recordings_201605(cdr_src);
create index recordings_dst_201605 on recordings_201605(cdr_dst);
create index recordings_uniqueid_201605 on recordings_201605(cdr_uniqueid);
CREATE TABLE recordings_201606 ( CHECK ( cdr_start >= '2016-06-01' and cdr_start <'2016-07-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201606 on recordings_201606(cdr_start);
create index recordings_src_201606 on recordings_201606(cdr_src);
create index recordings_dst_201606 on recordings_201606(cdr_dst);
create index recordings_uniqueid_201606 on recordings_201606(cdr_uniqueid);
CREATE TABLE recordings_201607 ( CHECK ( cdr_start >= '2016-07-01' and cdr_start <'2016-08-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201607 on recordings_201607(cdr_start);
create index recordings_src_201607 on recordings_201607(cdr_src);
create index recordings_dst_201607 on recordings_201607(cdr_dst);
create index recordings_uniqueid_201607 on recordings_201607(cdr_uniqueid);
CREATE TABLE recordings_201608 ( CHECK ( cdr_start >= '2016-08-01' and cdr_start <'2016-09-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201608 on recordings_201608(cdr_start);
create index recordings_src_201608 on recordings_201608(cdr_src);
create index recordings_dst_201608 on recordings_201608(cdr_dst);
create index recordings_uniqueid_201608 on recordings_201608(cdr_uniqueid);
CREATE TABLE recordings_201609 ( CHECK ( cdr_start >= '2016-09-01' and cdr_start <'2016-10-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201609 on recordings_201609(cdr_start);
create index recordings_src_201609 on recordings_201609(cdr_src);
create index recordings_dst_201609 on recordings_201609(cdr_dst);
create index recordings_uniqueid_201609 on recordings_201609(cdr_uniqueid);
CREATE TABLE recordings_201610 ( CHECK ( cdr_start >= '2016-10-01' and cdr_start <'2016-11-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201610 on recordings_201610(cdr_start);
create index recordings_src_201610 on recordings_201610(cdr_src);
create index recordings_dst_201610 on recordings_201610(cdr_dst);
create index recordings_uniqueid_201610 on recordings_201610(cdr_uniqueid);
CREATE TABLE recordings_201611 ( CHECK ( cdr_start >= '2016-11-01' and cdr_start <'2016-12-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201611 on recordings_201611(cdr_start);
create index recordings_src_201611 on recordings_201611(cdr_src);
create index recordings_dst_201611 on recordings_201611(cdr_dst);
create index recordings_uniqueid_201611 on recordings_201611(cdr_uniqueid);
CREATE TABLE recordings_201612 ( CHECK ( cdr_start >= '2016-12-01' and cdr_start <'2017-01-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201612 on recordings_201612(cdr_start);
create index recordings_src_201612 on recordings_201612(cdr_src);
create index recordings_dst_201612 on recordings_201612(cdr_dst);
create index recordings_uniqueid_201612 on recordings_201612(cdr_uniqueid);
CREATE TABLE recordings_201701 ( CHECK ( cdr_start >= '2017-01-01' and cdr_start <'2017-02-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201701 on recordings_201701(cdr_start);
create index recordings_src_201701 on recordings_201701(cdr_src);
create index recordings_dst_201701 on recordings_201701(cdr_dst);
create index recordings_uniqueid_201701 on recordings_201701(cdr_uniqueid);
CREATE TABLE recordings_201702 ( CHECK ( cdr_start >= '2017-02-01' and cdr_start <'2017-03-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201702 on recordings_201702(cdr_start);
create index recordings_src_201702 on recordings_201702(cdr_src);
create index recordings_dst_201702 on recordings_201702(cdr_dst);
create index recordings_uniqueid_201702 on recordings_201702(cdr_uniqueid);
CREATE TABLE recordings_201703 ( CHECK ( cdr_start >= '2017-03-01' and cdr_start <'2017-04-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201703 on recordings_201703(cdr_start);
create index recordings_src_201703 on recordings_201703(cdr_src);
create index recordings_dst_201703 on recordings_201703(cdr_dst);
create index recordings_uniqueid_201703 on recordings_201703(cdr_uniqueid);
CREATE TABLE recordings_201704 ( CHECK ( cdr_start >= '2017-04-01' and cdr_start <'2017-05-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201704 on recordings_201704(cdr_start);
create index recordings_src_201704 on recordings_201704(cdr_src);
create index recordings_dst_201704 on recordings_201704(cdr_dst);
create index recordings_uniqueid_201704 on recordings_201704(cdr_uniqueid);
CREATE TABLE recordings_201705 ( CHECK ( cdr_start >= '2017-05-01' and cdr_start <'2017-06-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201705 on recordings_201705(cdr_start);
create index recordings_src_201705 on recordings_201705(cdr_src);
create index recordings_dst_201705 on recordings_201705(cdr_dst);
create index recordings_uniqueid_201705 on recordings_201705(cdr_uniqueid);
CREATE TABLE recordings_201706 ( CHECK ( cdr_start >= '2017-06-01' and cdr_start <'2017-07-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201706 on recordings_201706(cdr_start);
create index recordings_src_201706 on recordings_201706(cdr_src);
create index recordings_dst_201706 on recordings_201706(cdr_dst);
create index recordings_uniqueid_201706 on recordings_201706(cdr_uniqueid);
CREATE TABLE recordings_201707 ( CHECK ( cdr_start >= '2017-07-01' and cdr_start <'2017-08-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201707 on recordings_201707(cdr_start);
create index recordings_src_201707 on recordings_201707(cdr_src);
create index recordings_dst_201707 on recordings_201707(cdr_dst);
create index recordings_uniqueid_201707 on recordings_201707(cdr_uniqueid);
CREATE TABLE recordings_201708 ( CHECK ( cdr_start >= '2017-08-01' and cdr_start <'2017-09-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201708 on recordings_201708(cdr_start);
create index recordings_src_201708 on recordings_201708(cdr_src);
create index recordings_dst_201708 on recordings_201708(cdr_dst);
create index recordings_uniqueid_201708 on recordings_201708(cdr_uniqueid);
CREATE TABLE recordings_201709 ( CHECK ( cdr_start >= '2017-09-01' and cdr_start <'2017-10-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201709 on recordings_201709(cdr_start);
create index recordings_src_201709 on recordings_201709(cdr_src);
create index recordings_dst_201709 on recordings_201709(cdr_dst);
create index recordings_uniqueid_201709 on recordings_201709(cdr_uniqueid);
CREATE TABLE recordings_201710 ( CHECK ( cdr_start >= '2017-10-01' and cdr_start <'2017-11-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201710 on recordings_201710(cdr_start);
create index recordings_src_201710 on recordings_201710(cdr_src);
create index recordings_dst_201710 on recordings_201710(cdr_dst);
create index recordings_uniqueid_201710 on recordings_201710(cdr_uniqueid);
CREATE TABLE recordings_201711 ( CHECK ( cdr_start >= '2017-11-01' and cdr_start <'2017-12-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201711 on recordings_201711(cdr_start);
create index recordings_src_201711 on recordings_201711(cdr_src);
create index recordings_dst_201711 on recordings_201711(cdr_dst);
create index recordings_uniqueid_201711 on recordings_201711(cdr_uniqueid);
CREATE TABLE recordings_201712 ( CHECK ( cdr_start >= '2017-12-01' and cdr_start <'2018-01-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201712 on recordings_201712(cdr_start);
create index recordings_src_201712 on recordings_201712(cdr_src);
create index recordings_dst_201712 on recordings_201712(cdr_dst);
create index recordings_uniqueid_201712 on recordings_201712(cdr_uniqueid);
CREATE TABLE recordings_201801 ( CHECK ( cdr_start >= '2018-01-01' and cdr_start <'2018-02-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201801 on recordings_201801(cdr_start);
create index recordings_src_201801 on recordings_201801(cdr_src);
create index recordings_dst_201801 on recordings_201801(cdr_dst);
create index recordings_uniqueid_201801 on recordings_201801(cdr_uniqueid);
CREATE TABLE recordings_201802 ( CHECK ( cdr_start >= '2018-02-01' and cdr_start <'2018-03-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201802 on recordings_201802(cdr_start);
create index recordings_src_201802 on recordings_201802(cdr_src);
create index recordings_dst_201802 on recordings_201802(cdr_dst);
create index recordings_uniqueid_201802 on recordings_201802(cdr_uniqueid);
CREATE TABLE recordings_201803 ( CHECK ( cdr_start >= '2018-03-01' and cdr_start <'2018-04-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201803 on recordings_201803(cdr_start);
create index recordings_src_201803 on recordings_201803(cdr_src);
create index recordings_dst_201803 on recordings_201803(cdr_dst);
create index recordings_uniqueid_201803 on recordings_201803(cdr_uniqueid);
CREATE TABLE recordings_201804 ( CHECK ( cdr_start >= '2018-04-01' and cdr_start <'2018-05-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201804 on recordings_201804(cdr_start);
create index recordings_src_201804 on recordings_201804(cdr_src);
create index recordings_dst_201804 on recordings_201804(cdr_dst);
create index recordings_uniqueid_201804 on recordings_201804(cdr_uniqueid);
CREATE TABLE recordings_201805 ( CHECK ( cdr_start >= '2018-05-01' and cdr_start <'2018-06-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201805 on recordings_201805(cdr_start);
create index recordings_src_201805 on recordings_201805(cdr_src);
create index recordings_dst_201805 on recordings_201805(cdr_dst);
create index recordings_uniqueid_201805 on recordings_201805(cdr_uniqueid);
CREATE TABLE recordings_201806 ( CHECK ( cdr_start >= '2018-06-01' and cdr_start <'2018-07-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201806 on recordings_201806(cdr_start);
create index recordings_src_201806 on recordings_201806(cdr_src);
create index recordings_dst_201806 on recordings_201806(cdr_dst);
create index recordings_uniqueid_201806 on recordings_201806(cdr_uniqueid);
CREATE TABLE recordings_201807 ( CHECK ( cdr_start >= '2018-07-01' and cdr_start <'2018-08-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201807 on recordings_201807(cdr_start);
create index recordings_src_201807 on recordings_201807(cdr_src);
create index recordings_dst_201807 on recordings_201807(cdr_dst);
create index recordings_uniqueid_201807 on recordings_201807(cdr_uniqueid);
CREATE TABLE recordings_201808 ( CHECK ( cdr_start >= '2018-08-01' and cdr_start <'2018-09-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201808 on recordings_201808(cdr_start);
create index recordings_src_201808 on recordings_201808(cdr_src);
create index recordings_dst_201808 on recordings_201808(cdr_dst);
create index recordings_uniqueid_201808 on recordings_201808(cdr_uniqueid);
CREATE TABLE recordings_201809 ( CHECK ( cdr_start >= '2018-09-01' and cdr_start <'2018-10-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201809 on recordings_201809(cdr_start);
create index recordings_src_201809 on recordings_201809(cdr_src);
create index recordings_dst_201809 on recordings_201809(cdr_dst);
create index recordings_uniqueid_201809 on recordings_201809(cdr_uniqueid);
CREATE TABLE recordings_201810 ( CHECK ( cdr_start >= '2018-10-01' and cdr_start <'2018-11-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201810 on recordings_201810(cdr_start);
create index recordings_src_201810 on recordings_201810(cdr_src);
create index recordings_dst_201810 on recordings_201810(cdr_dst);
create index recordings_uniqueid_201810 on recordings_201810(cdr_uniqueid);
CREATE TABLE recordings_201811 ( CHECK ( cdr_start >= '2018-11-01' and cdr_start <'2018-12-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201811 on recordings_201811(cdr_start);
create index recordings_src_201811 on recordings_201811(cdr_src);
create index recordings_dst_201811 on recordings_201811(cdr_dst);
create index recordings_uniqueid_201811 on recordings_201811(cdr_uniqueid);
CREATE TABLE recordings_201812 ( CHECK ( cdr_start >= '2018-12-01' and cdr_start <'2019-01-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201812 on recordings_201812(cdr_start);
create index recordings_src_201812 on recordings_201812(cdr_src);
create index recordings_dst_201812 on recordings_201812(cdr_dst);
create index recordings_uniqueid_201812 on recordings_201812(cdr_uniqueid);
CREATE TABLE recordings_201901 ( CHECK ( cdr_start >= '2019-01-01' and cdr_start <'2019-02-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201901 on recordings_201901(cdr_start);
create index recordings_src_201901 on recordings_201901(cdr_src);
create index recordings_dst_201901 on recordings_201901(cdr_dst);
create index recordings_uniqueid_201901 on recordings_201901(cdr_uniqueid);
CREATE TABLE recordings_201902 ( CHECK ( cdr_start >= '2019-02-01' and cdr_start <'2019-03-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201902 on recordings_201902(cdr_start);
create index recordings_src_201902 on recordings_201902(cdr_src);
create index recordings_dst_201902 on recordings_201902(cdr_dst);
create index recordings_uniqueid_201902 on recordings_201902(cdr_uniqueid);
CREATE TABLE recordings_201903 ( CHECK ( cdr_start >= '2019-03-01' and cdr_start <'2019-04-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201903 on recordings_201903(cdr_start);
create index recordings_src_201903 on recordings_201903(cdr_src);
create index recordings_dst_201903 on recordings_201903(cdr_dst);
create index recordings_uniqueid_201903 on recordings_201903(cdr_uniqueid);
CREATE TABLE recordings_201904 ( CHECK ( cdr_start >= '2019-04-01' and cdr_start <'2019-05-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201904 on recordings_201904(cdr_start);
create index recordings_src_201904 on recordings_201904(cdr_src);
create index recordings_dst_201904 on recordings_201904(cdr_dst);
create index recordings_uniqueid_201904 on recordings_201904(cdr_uniqueid);
CREATE TABLE recordings_201905 ( CHECK ( cdr_start >= '2019-05-01' and cdr_start <'2019-06-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201905 on recordings_201905(cdr_start);
create index recordings_src_201905 on recordings_201905(cdr_src);
create index recordings_dst_201905 on recordings_201905(cdr_dst);
create index recordings_uniqueid_201905 on recordings_201905(cdr_uniqueid);
CREATE TABLE recordings_201906 ( CHECK ( cdr_start >= '2019-06-01' and cdr_start <'2019-07-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201906 on recordings_201906(cdr_start);
create index recordings_src_201906 on recordings_201906(cdr_src);
create index recordings_dst_201906 on recordings_201906(cdr_dst);
create index recordings_uniqueid_201906 on recordings_201906(cdr_uniqueid);
CREATE TABLE recordings_201907 ( CHECK ( cdr_start >= '2019-07-01' and cdr_start <'2019-08-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201907 on recordings_201907(cdr_start);
create index recordings_src_201907 on recordings_201907(cdr_src);
create index recordings_dst_201907 on recordings_201907(cdr_dst);
create index recordings_uniqueid_201907 on recordings_201907(cdr_uniqueid);
CREATE TABLE recordings_201908 ( CHECK ( cdr_start >= '2019-08-01' and cdr_start <'2019-09-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201908 on recordings_201908(cdr_start);
create index recordings_src_201908 on recordings_201908(cdr_src);
create index recordings_dst_201908 on recordings_201908(cdr_dst);
create index recordings_uniqueid_201908 on recordings_201908(cdr_uniqueid);
CREATE TABLE recordings_201909 ( CHECK ( cdr_start >= '2019-09-01' and cdr_start <'2019-10-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201909 on recordings_201909(cdr_start);
create index recordings_src_201909 on recordings_201909(cdr_src);
create index recordings_dst_201909 on recordings_201909(cdr_dst);
create index recordings_uniqueid_201909 on recordings_201909(cdr_uniqueid);
CREATE TABLE recordings_201910 ( CHECK ( cdr_start >= '2019-10-01' and cdr_start <'2019-11-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201910 on recordings_201910(cdr_start);
create index recordings_src_201910 on recordings_201910(cdr_src);
create index recordings_dst_201910 on recordings_201910(cdr_dst);
create index recordings_uniqueid_201910 on recordings_201910(cdr_uniqueid);
CREATE TABLE recordings_201911 ( CHECK ( cdr_start >= '2019-11-01' and cdr_start <'2019-12-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201911 on recordings_201911(cdr_start);
create index recordings_src_201911 on recordings_201911(cdr_src);
create index recordings_dst_201911 on recordings_201911(cdr_dst);
create index recordings_uniqueid_201911 on recordings_201911(cdr_uniqueid);
CREATE TABLE recordings_201912 ( CHECK ( cdr_start >= '2019-12-01' and cdr_start <'2020-01-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_201912 on recordings_201912(cdr_start);
create index recordings_src_201912 on recordings_201912(cdr_src);
create index recordings_dst_201912 on recordings_201912(cdr_dst);
create index recordings_uniqueid_201912 on recordings_201912(cdr_uniqueid);
CREATE TABLE recordings_202001 ( CHECK ( cdr_start >= '2020-01-01' and cdr_start <'2020-02-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202001 on recordings_202001(cdr_start);
create index recordings_src_202001 on recordings_202001(cdr_src);
create index recordings_dst_202001 on recordings_202001(cdr_dst);
create index recordings_uniqueid_202001 on recordings_202001(cdr_uniqueid);
CREATE TABLE recordings_202002 ( CHECK ( cdr_start >= '2020-02-01' and cdr_start <'2020-03-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202002 on recordings_202002(cdr_start);
create index recordings_src_202002 on recordings_202002(cdr_src);
create index recordings_dst_202002 on recordings_202002(cdr_dst);
create index recordings_uniqueid_202002 on recordings_202002(cdr_uniqueid);
CREATE TABLE recordings_202003 ( CHECK ( cdr_start >= '2020-03-01' and cdr_start <'2020-04-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202003 on recordings_202003(cdr_start);
create index recordings_src_202003 on recordings_202003(cdr_src);
create index recordings_dst_202003 on recordings_202003(cdr_dst);
create index recordings_uniqueid_202003 on recordings_202003(cdr_uniqueid);
CREATE TABLE recordings_202004 ( CHECK ( cdr_start >= '2020-04-01' and cdr_start <'2020-05-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202004 on recordings_202004(cdr_start);
create index recordings_src_202004 on recordings_202004(cdr_src);
create index recordings_dst_202004 on recordings_202004(cdr_dst);
create index recordings_uniqueid_202004 on recordings_202004(cdr_uniqueid);
CREATE TABLE recordings_202005 ( CHECK ( cdr_start >= '2020-05-01' and cdr_start <'2020-06-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202005 on recordings_202005(cdr_start);
create index recordings_src_202005 on recordings_202005(cdr_src);
create index recordings_dst_202005 on recordings_202005(cdr_dst);
create index recordings_uniqueid_202005 on recordings_202005(cdr_uniqueid);
CREATE TABLE recordings_202006 ( CHECK ( cdr_start >= '2020-06-01' and cdr_start <'2020-07-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202006 on recordings_202006(cdr_start);
create index recordings_src_202006 on recordings_202006(cdr_src);
create index recordings_dst_202006 on recordings_202006(cdr_dst);
create index recordings_uniqueid_202006 on recordings_202006(cdr_uniqueid);
CREATE TABLE recordings_202007 ( CHECK ( cdr_start >= '2020-07-01' and cdr_start <'2020-08-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202007 on recordings_202007(cdr_start);
create index recordings_src_202007 on recordings_202007(cdr_src);
create index recordings_dst_202007 on recordings_202007(cdr_dst);
create index recordings_uniqueid_202007 on recordings_202007(cdr_uniqueid);
CREATE TABLE recordings_202008 ( CHECK ( cdr_start >= '2020-08-01' and cdr_start <'2020-09-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202008 on recordings_202008(cdr_start);
create index recordings_src_202008 on recordings_202008(cdr_src);
create index recordings_dst_202008 on recordings_202008(cdr_dst);
create index recordings_uniqueid_202008 on recordings_202008(cdr_uniqueid);
CREATE TABLE recordings_202009 ( CHECK ( cdr_start >= '2020-09-01' and cdr_start <'2020-10-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202009 on recordings_202009(cdr_start);
create index recordings_src_202009 on recordings_202009(cdr_src);
create index recordings_dst_202009 on recordings_202009(cdr_dst);
create index recordings_uniqueid_202009 on recordings_202009(cdr_uniqueid);
CREATE TABLE recordings_202010 ( CHECK ( cdr_start >= '2020-10-01' and cdr_start <'2020-11-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202010 on recordings_202010(cdr_start);
create index recordings_src_202010 on recordings_202010(cdr_src);
create index recordings_dst_202010 on recordings_202010(cdr_dst);
create index recordings_uniqueid_202010 on recordings_202010(cdr_uniqueid);
CREATE TABLE recordings_202011 ( CHECK ( cdr_start >= '2020-11-01' and cdr_start <'2020-12-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202011 on recordings_202011(cdr_start);
create index recordings_src_202011 on recordings_202011(cdr_src);
create index recordings_dst_202011 on recordings_202011(cdr_dst);
create index recordings_uniqueid_202011 on recordings_202011(cdr_uniqueid);
CREATE TABLE recordings_202012 ( CHECK ( cdr_start >= '2020-12-01' and cdr_start <'2021-01-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202012 on recordings_202012(cdr_start);
create index recordings_src_202012 on recordings_202012(cdr_src);
create index recordings_dst_202012 on recordings_202012(cdr_dst);
create index recordings_uniqueid_202012 on recordings_202012(cdr_uniqueid);
CREATE TABLE recordings_202101 ( CHECK ( cdr_start >= '2021-01-01' and cdr_start <'2021-02-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202101 on recordings_202101(cdr_start);
create index recordings_src_202101 on recordings_202101(cdr_src);
create index recordings_dst_202101 on recordings_202101(cdr_dst);
create index recordings_uniqueid_202101 on recordings_202101(cdr_uniqueid);
CREATE TABLE recordings_202102 ( CHECK ( cdr_start >= '2021-02-01' and cdr_start <'2021-03-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202102 on recordings_202102(cdr_start);
create index recordings_src_202102 on recordings_202102(cdr_src);
create index recordings_dst_202102 on recordings_202102(cdr_dst);
create index recordings_uniqueid_202102 on recordings_202102(cdr_uniqueid);
CREATE TABLE recordings_202103 ( CHECK ( cdr_start >= '2021-03-01' and cdr_start <'2021-04-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202103 on recordings_202103(cdr_start);
create index recordings_src_202103 on recordings_202103(cdr_src);
create index recordings_dst_202103 on recordings_202103(cdr_dst);
create index recordings_uniqueid_202103 on recordings_202103(cdr_uniqueid);
CREATE TABLE recordings_202104 ( CHECK ( cdr_start >= '2021-04-01' and cdr_start <'2021-05-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202104 on recordings_202104(cdr_start);
create index recordings_src_202104 on recordings_202104(cdr_src);
create index recordings_dst_202104 on recordings_202104(cdr_dst);
create index recordings_uniqueid_202104 on recordings_202104(cdr_uniqueid);
CREATE TABLE recordings_202105 ( CHECK ( cdr_start >= '2021-05-01' and cdr_start <'2021-06-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202105 on recordings_202105(cdr_start);
create index recordings_src_202105 on recordings_202105(cdr_src);
create index recordings_dst_202105 on recordings_202105(cdr_dst);
create index recordings_uniqueid_202105 on recordings_202105(cdr_uniqueid);
CREATE TABLE recordings_202106 ( CHECK ( cdr_start >= '2021-06-01' and cdr_start <'2021-07-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202106 on recordings_202106(cdr_start);
create index recordings_src_202106 on recordings_202106(cdr_src);
create index recordings_dst_202106 on recordings_202106(cdr_dst);
create index recordings_uniqueid_202106 on recordings_202106(cdr_uniqueid);
CREATE TABLE recordings_202107 ( CHECK ( cdr_start >= '2021-07-01' and cdr_start <'2021-08-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202107 on recordings_202107(cdr_start);
create index recordings_src_202107 on recordings_202107(cdr_src);
create index recordings_dst_202107 on recordings_202107(cdr_dst);
create index recordings_uniqueid_202107 on recordings_202107(cdr_uniqueid);
CREATE TABLE recordings_202108 ( CHECK ( cdr_start >= '2021-08-01' and cdr_start <'2021-09-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202108 on recordings_202108(cdr_start);
create index recordings_src_202108 on recordings_202108(cdr_src);
create index recordings_dst_202108 on recordings_202108(cdr_dst);
create index recordings_uniqueid_202108 on recordings_202108(cdr_uniqueid);
CREATE TABLE recordings_202109 ( CHECK ( cdr_start >= '2021-09-01' and cdr_start <'2021-10-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202109 on recordings_202109(cdr_start);
create index recordings_src_202109 on recordings_202109(cdr_src);
create index recordings_dst_202109 on recordings_202109(cdr_dst);
create index recordings_uniqueid_202109 on recordings_202109(cdr_uniqueid);
CREATE TABLE recordings_202110 ( CHECK ( cdr_start >= '2021-10-01' and cdr_start <'2021-11-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202110 on recordings_202110(cdr_start);
create index recordings_src_202110 on recordings_202110(cdr_src);
create index recordings_dst_202110 on recordings_202110(cdr_dst);
create index recordings_uniqueid_202110 on recordings_202110(cdr_uniqueid);
CREATE TABLE recordings_202111 ( CHECK ( cdr_start >= '2021-11-01' and cdr_start <'2021-12-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202111 on recordings_202111(cdr_start);
create index recordings_src_202111 on recordings_202111(cdr_src);
create index recordings_dst_202111 on recordings_202111(cdr_dst);
create index recordings_uniqueid_202111 on recordings_202111(cdr_uniqueid);
CREATE TABLE recordings_202112 ( CHECK ( cdr_start >= '2021-12-01' and cdr_start <'2022-01-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202112 on recordings_202112(cdr_start);
create index recordings_src_202112 on recordings_202112(cdr_src);
create index recordings_dst_202112 on recordings_202112(cdr_dst);
create index recordings_uniqueid_202112 on recordings_202112(cdr_uniqueid);
CREATE TABLE recordings_202201 ( CHECK ( cdr_start >= '2022-01-01' and cdr_start <'2022-02-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202201 on recordings_202201(cdr_start);
create index recordings_src_202201 on recordings_202201(cdr_src);
create index recordings_dst_202201 on recordings_202201(cdr_dst);
create index recordings_uniqueid_202201 on recordings_202201(cdr_uniqueid);
CREATE TABLE recordings_202202 ( CHECK ( cdr_start >= '2022-02-01' and cdr_start <'2022-03-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202202 on recordings_202202(cdr_start);
create index recordings_src_202202 on recordings_202202(cdr_src);
create index recordings_dst_202202 on recordings_202202(cdr_dst);
create index recordings_uniqueid_202202 on recordings_202202(cdr_uniqueid);
CREATE TABLE recordings_202203 ( CHECK ( cdr_start >= '2022-03-01' and cdr_start <'2022-04-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202203 on recordings_202203(cdr_start);
create index recordings_src_202203 on recordings_202203(cdr_src);
create index recordings_dst_202203 on recordings_202203(cdr_dst);
create index recordings_uniqueid_202203 on recordings_202203(cdr_uniqueid);
CREATE TABLE recordings_202204 ( CHECK ( cdr_start >= '2022-04-01' and cdr_start <'2022-05-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202204 on recordings_202204(cdr_start);
create index recordings_src_202204 on recordings_202204(cdr_src);
create index recordings_dst_202204 on recordings_202204(cdr_dst);
create index recordings_uniqueid_202204 on recordings_202204(cdr_uniqueid);
CREATE TABLE recordings_202205 ( CHECK ( cdr_start >= '2022-05-01' and cdr_start <'2022-06-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202205 on recordings_202205(cdr_start);
create index recordings_src_202205 on recordings_202205(cdr_src);
create index recordings_dst_202205 on recordings_202205(cdr_dst);
create index recordings_uniqueid_202205 on recordings_202205(cdr_uniqueid);
CREATE TABLE recordings_202206 ( CHECK ( cdr_start >= '2022-06-01' and cdr_start <'2022-07-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202206 on recordings_202206(cdr_start);
create index recordings_src_202206 on recordings_202206(cdr_src);
create index recordings_dst_202206 on recordings_202206(cdr_dst);
create index recordings_uniqueid_202206 on recordings_202206(cdr_uniqueid);
CREATE TABLE recordings_202207 ( CHECK ( cdr_start >= '2022-07-01' and cdr_start <'2022-08-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202207 on recordings_202207(cdr_start);
create index recordings_src_202207 on recordings_202207(cdr_src);
create index recordings_dst_202207 on recordings_202207(cdr_dst);
create index recordings_uniqueid_202207 on recordings_202207(cdr_uniqueid);
CREATE TABLE recordings_202208 ( CHECK ( cdr_start >= '2022-08-01' and cdr_start <'2022-09-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202208 on recordings_202208(cdr_start);
create index recordings_src_202208 on recordings_202208(cdr_src);
create index recordings_dst_202208 on recordings_202208(cdr_dst);
create index recordings_uniqueid_202208 on recordings_202208(cdr_uniqueid);
CREATE TABLE recordings_202209 ( CHECK ( cdr_start >= '2022-09-01' and cdr_start <'2022-10-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202209 on recordings_202209(cdr_start);
create index recordings_src_202209 on recordings_202209(cdr_src);
create index recordings_dst_202209 on recordings_202209(cdr_dst);
create index recordings_uniqueid_202209 on recordings_202209(cdr_uniqueid);
CREATE TABLE recordings_202210 ( CHECK ( cdr_start >= '2022-10-01' and cdr_start <'2022-11-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202210 on recordings_202210(cdr_start);
create index recordings_src_202210 on recordings_202210(cdr_src);
create index recordings_dst_202210 on recordings_202210(cdr_dst);
create index recordings_uniqueid_202210 on recordings_202210(cdr_uniqueid);
CREATE TABLE recordings_202211 ( CHECK ( cdr_start >= '2022-11-01' and cdr_start <'2022-12-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202211 on recordings_202211(cdr_start);
create index recordings_src_202211 on recordings_202211(cdr_src);
create index recordings_dst_202211 on recordings_202211(cdr_dst);
create index recordings_uniqueid_202211 on recordings_202211(cdr_uniqueid);
CREATE TABLE recordings_202212 ( CHECK ( cdr_start >= '2022-12-01' and cdr_start <'2023-01-01' ) ) INHERITS (recordings);
create index recordings_cdr_start_202212 on recordings_202212(cdr_start);
create index recordings_src_202212 on recordings_202212(cdr_src);
create index recordings_dst_202212 on recordings_202212(cdr_dst);
create index recordings_uniqueid_202212 on recordings_202212(cdr_uniqueid);
CREATE OR REPLACE FUNCTION recordings_insert_trigger() 
        RETURNS TRIGGER AS $$
        BEGIN
             IF ( NEW.cdr_start >= DATE '2015-01-01' AND
                  NEW.cdr_start < DATE '2015-02-01' ) THEN
                  INSERT INTO recordings_201501 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2015-02-01' AND
                        NEW.cdr_start < DATE '2015-03-01' ) THEN
                                INSERT INTO recordings_201502 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2015-03-01' AND
                        NEW.cdr_start < DATE '2015-04-01' ) THEN
                                INSERT INTO recordings_201503 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2015-04-01' AND
                        NEW.cdr_start < DATE '2015-05-01' ) THEN
                                INSERT INTO recordings_201504 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2015-05-01' AND
                        NEW.cdr_start < DATE '2015-06-01' ) THEN
                                INSERT INTO recordings_201505 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2015-06-01' AND
                        NEW.cdr_start < DATE '2015-07-01' ) THEN
                                INSERT INTO recordings_201506 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2015-07-01' AND
                        NEW.cdr_start < DATE '2015-08-01' ) THEN
                                INSERT INTO recordings_201507 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2015-08-01' AND
                        NEW.cdr_start < DATE '2015-09-01' ) THEN
                                INSERT INTO recordings_201508 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2015-09-01' AND
                        NEW.cdr_start < DATE '2015-10-01' ) THEN
                                INSERT INTO recordings_201509 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2015-10-01' AND
                        NEW.cdr_start < DATE '2015-11-01' ) THEN
                                INSERT INTO recordings_201510 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2015-11-01' AND
                        NEW.cdr_start < DATE '2015-12-01' ) THEN
                                INSERT INTO recordings_201511 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2015-12-01' AND
                        NEW.cdr_start < DATE '2016-01-01' ) THEN
                                INSERT INTO recordings_201512 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2016-01-01' AND
                        NEW.cdr_start < DATE '2016-02-01' ) THEN
                                INSERT INTO recordings_201601 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2016-02-01' AND
                        NEW.cdr_start < DATE '2016-03-01' ) THEN
                                INSERT INTO recordings_201602 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2016-03-01' AND
                        NEW.cdr_start < DATE '2016-04-01' ) THEN
                                INSERT INTO recordings_201603 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2016-04-01' AND
                        NEW.cdr_start < DATE '2016-05-01' ) THEN
                                INSERT INTO recordings_201604 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2016-05-01' AND
                        NEW.cdr_start < DATE '2016-06-01' ) THEN
                                INSERT INTO recordings_201605 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2016-06-01' AND
                        NEW.cdr_start < DATE '2016-07-01' ) THEN
                                INSERT INTO recordings_201606 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2016-07-01' AND
                        NEW.cdr_start < DATE '2016-08-01' ) THEN
                                INSERT INTO recordings_201607 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2016-08-01' AND
                        NEW.cdr_start < DATE '2016-09-01' ) THEN
                                INSERT INTO recordings_201608 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2016-09-01' AND
                        NEW.cdr_start < DATE '2016-10-01' ) THEN
                                INSERT INTO recordings_201609 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2016-10-01' AND
                        NEW.cdr_start < DATE '2016-11-01' ) THEN
                                INSERT INTO recordings_201610 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2016-11-01' AND
                        NEW.cdr_start < DATE '2016-12-01' ) THEN
                                INSERT INTO recordings_201611 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2016-12-01' AND
                        NEW.cdr_start < DATE '2017-01-01' ) THEN
                                INSERT INTO recordings_201612 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2017-01-01' AND
                        NEW.cdr_start < DATE '2017-02-01' ) THEN
                                INSERT INTO recordings_201701 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2017-02-01' AND
                        NEW.cdr_start < DATE '2017-03-01' ) THEN
                                INSERT INTO recordings_201702 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2017-03-01' AND
                        NEW.cdr_start < DATE '2017-04-01' ) THEN
                                INSERT INTO recordings_201703 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2017-04-01' AND
                        NEW.cdr_start < DATE '2017-05-01' ) THEN
                                INSERT INTO recordings_201704 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2017-05-01' AND
                        NEW.cdr_start < DATE '2017-06-01' ) THEN
                                INSERT INTO recordings_201705 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2017-06-01' AND
                        NEW.cdr_start < DATE '2017-07-01' ) THEN
                                INSERT INTO recordings_201706 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2017-07-01' AND
                        NEW.cdr_start < DATE '2017-08-01' ) THEN
                                INSERT INTO recordings_201707 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2017-08-01' AND
                        NEW.cdr_start < DATE '2017-09-01' ) THEN
                                INSERT INTO recordings_201708 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2017-09-01' AND
                        NEW.cdr_start < DATE '2017-10-01' ) THEN
                                INSERT INTO recordings_201709 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2017-10-01' AND
                        NEW.cdr_start < DATE '2017-11-01' ) THEN
                                INSERT INTO recordings_201710 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2017-11-01' AND
                        NEW.cdr_start < DATE '2017-12-01' ) THEN
                                INSERT INTO recordings_201711 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2017-12-01' AND
                        NEW.cdr_start < DATE '2018-01-01' ) THEN
                                INSERT INTO recordings_201712 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2018-01-01' AND
                        NEW.cdr_start < DATE '2018-02-01' ) THEN
                                INSERT INTO recordings_201801 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2018-02-01' AND
                        NEW.cdr_start < DATE '2018-03-01' ) THEN
                                INSERT INTO recordings_201802 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2018-03-01' AND
                        NEW.cdr_start < DATE '2018-04-01' ) THEN
                                INSERT INTO recordings_201803 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2018-04-01' AND
                        NEW.cdr_start < DATE '2018-05-01' ) THEN
                                INSERT INTO recordings_201804 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2018-05-01' AND
                        NEW.cdr_start < DATE '2018-06-01' ) THEN
                                INSERT INTO recordings_201805 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2018-06-01' AND
                        NEW.cdr_start < DATE '2018-07-01' ) THEN
                                INSERT INTO recordings_201806 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2018-07-01' AND
                        NEW.cdr_start < DATE '2018-08-01' ) THEN
                                INSERT INTO recordings_201807 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2018-08-01' AND
                        NEW.cdr_start < DATE '2018-09-01' ) THEN
                                INSERT INTO recordings_201808 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2018-09-01' AND
                        NEW.cdr_start < DATE '2018-10-01' ) THEN
                                INSERT INTO recordings_201809 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2018-10-01' AND
                        NEW.cdr_start < DATE '2018-11-01' ) THEN
                                INSERT INTO recordings_201810 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2018-11-01' AND
                        NEW.cdr_start < DATE '2018-12-01' ) THEN
                                INSERT INTO recordings_201811 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2018-12-01' AND
                        NEW.cdr_start < DATE '2019-01-01' ) THEN
                                INSERT INTO recordings_201812 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2019-01-01' AND
                        NEW.cdr_start < DATE '2019-02-01' ) THEN
                                INSERT INTO recordings_201901 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2019-02-01' AND
                        NEW.cdr_start < DATE '2019-03-01' ) THEN
                                INSERT INTO recordings_201902 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2019-03-01' AND
                        NEW.cdr_start < DATE '2019-04-01' ) THEN
                                INSERT INTO recordings_201903 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2019-04-01' AND
                        NEW.cdr_start < DATE '2019-05-01' ) THEN
                                INSERT INTO recordings_201904 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2019-05-01' AND
                        NEW.cdr_start < DATE '2019-06-01' ) THEN
                                INSERT INTO recordings_201905 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2019-06-01' AND
                        NEW.cdr_start < DATE '2019-07-01' ) THEN
                                INSERT INTO recordings_201906 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2019-07-01' AND
                        NEW.cdr_start < DATE '2019-08-01' ) THEN
                                INSERT INTO recordings_201907 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2019-08-01' AND
                        NEW.cdr_start < DATE '2019-09-01' ) THEN
                                INSERT INTO recordings_201908 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2019-09-01' AND
                        NEW.cdr_start < DATE '2019-10-01' ) THEN
                                INSERT INTO recordings_201909 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2019-10-01' AND
                        NEW.cdr_start < DATE '2019-11-01' ) THEN
                                INSERT INTO recordings_201910 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2019-11-01' AND
                        NEW.cdr_start < DATE '2019-12-01' ) THEN
                                INSERT INTO recordings_201911 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2019-12-01' AND
                        NEW.cdr_start < DATE '2020-01-01' ) THEN
                                INSERT INTO recordings_201912 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2020-01-01' AND
                        NEW.cdr_start < DATE '2020-02-01' ) THEN
                                INSERT INTO recordings_202001 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2020-02-01' AND
                        NEW.cdr_start < DATE '2020-03-01' ) THEN
                                INSERT INTO recordings_202002 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2020-03-01' AND
                        NEW.cdr_start < DATE '2020-04-01' ) THEN
                                INSERT INTO recordings_202003 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2020-04-01' AND
                        NEW.cdr_start < DATE '2020-05-01' ) THEN
                                INSERT INTO recordings_202004 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2020-05-01' AND
                        NEW.cdr_start < DATE '2020-06-01' ) THEN
                                INSERT INTO recordings_202005 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2020-06-01' AND
                        NEW.cdr_start < DATE '2020-07-01' ) THEN
                                INSERT INTO recordings_202006 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2020-07-01' AND
                        NEW.cdr_start < DATE '2020-08-01' ) THEN
                                INSERT INTO recordings_202007 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2020-08-01' AND
                        NEW.cdr_start < DATE '2020-09-01' ) THEN
                                INSERT INTO recordings_202008 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2020-09-01' AND
                        NEW.cdr_start < DATE '2020-10-01' ) THEN
                                INSERT INTO recordings_202009 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2020-10-01' AND
                        NEW.cdr_start < DATE '2020-11-01' ) THEN
                                INSERT INTO recordings_202010 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2020-11-01' AND
                        NEW.cdr_start < DATE '2020-12-01' ) THEN
                                INSERT INTO recordings_202011 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2020-12-01' AND
                        NEW.cdr_start < DATE '2021-01-01' ) THEN
                                INSERT INTO recordings_202012 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2021-01-01' AND
                        NEW.cdr_start < DATE '2021-02-01' ) THEN
                                INSERT INTO recordings_202101 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2021-02-01' AND
                        NEW.cdr_start < DATE '2021-03-01' ) THEN
                                INSERT INTO recordings_202102 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2021-03-01' AND
                        NEW.cdr_start < DATE '2021-04-01' ) THEN
                                INSERT INTO recordings_202103 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2021-04-01' AND
                        NEW.cdr_start < DATE '2021-05-01' ) THEN
                                INSERT INTO recordings_202104 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2021-05-01' AND
                        NEW.cdr_start < DATE '2021-06-01' ) THEN
                                INSERT INTO recordings_202105 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2021-06-01' AND
                        NEW.cdr_start < DATE '2021-07-01' ) THEN
                                INSERT INTO recordings_202106 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2021-07-01' AND
                        NEW.cdr_start < DATE '2021-08-01' ) THEN
                                INSERT INTO recordings_202107 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2021-08-01' AND
                        NEW.cdr_start < DATE '2021-09-01' ) THEN
                                INSERT INTO recordings_202108 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2021-09-01' AND
                        NEW.cdr_start < DATE '2021-10-01' ) THEN
                                INSERT INTO recordings_202109 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2021-10-01' AND
                        NEW.cdr_start < DATE '2021-11-01' ) THEN
                                INSERT INTO recordings_202110 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2021-11-01' AND
                        NEW.cdr_start < DATE '2021-12-01' ) THEN
                                INSERT INTO recordings_202111 VALUES (NEW.*);
ELSIF ( NEW.cdr_start >= DATE '2021-12-01' AND
                        NEW.cdr_start < DATE '2022-01-01' ) THEN
                                INSERT INTO recordings_202112 VALUES (NEW.*);
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


