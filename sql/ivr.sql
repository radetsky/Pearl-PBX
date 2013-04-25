set search_path to ivr; 

create table hints ( id bigserial primary key, 
msisdn varchar(20) not null,
since timestamp without time zone not null, 
till timestamp without time zone  not null, 
hint_id bigint not null, 
message varchar(32) not null );

create SEQUENCE hints_hint_id_seq  minvalue 1 maxvalue 9223372036854775807  start 1 increment 1;
create index ivr_hints_msisdn on hints (msisdn); 
create index ivr_hints_hint_id on hints (hint_id); 

create table advfilter ( id bigserial primary key, 
msisdn varchar(20) not null,
since timestamp without time zone not null,
till timestamp without time zone not null,
playback varchar(64) not null ); 

create index advfilter_msisdn on advfilter ( msisdn ); 


create table language ( msisdn varchar(20) not null primary key, lang_code varchar(2) not null default 'ru' ); 
create index ivr_language_msisdn on language ( msisdn );

create table personal_operator (
	id bigserial primary key, 
	msisdn varchar(20) not null, 
	operator varchar(20) not null, 
  calldate timestamp without time zone default now(), 
	priority integer default 0,
  comment varchar(64) 
); 

create index ivr_poperator on personal_operator ( msisdn ); 
create UNIQUE index ivr_poperator_msisdn on ivr.personal_operator (msisdn,operator);

create table addressbook ( 
	id bigserial primary key,
	msisdn varchar(20) not null, 
	displayname varchar(32) not null 
); 

create unique index ivr_displayname_msisdn on ivr.addressbook ( msisdn, displayname); 
create UNIQUE INDEX ivr_ad_msisdn on addressbook (msisdn);

create table audiofiles ( 
	id bigserial primary key, 
	filename varchar(64) not null, 
	typeOfMusic varchar(3) not null, 
	description varchar(64) not null
);

create unique index ivr_audiofiles_filename on ivr.audiofiles  ( filename ); 


