create table callback_list ( 
	id bigserial primary key,
	created timestamp without time zone not null default now(), 
	callerid character varying (32) not null default '', 
	operator character varying (32) not null default '', 
	calledidnum character varying (32) not null default '', 
	calledidname character varying (32) not null default '', 
	done boolean default false not null 
); 
create index idx_cb_created on callback_list ( created ); 
create index idx_cb_callerid on callback_list ( callerid ); 
create index idx_cb_done on callback_list ( done ); 

