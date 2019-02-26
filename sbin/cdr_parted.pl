#!/usr/bin/perl  

use strict; 
use warnings; 

my @names = generate_series();
generate_cdr(@names); 
generate_recordings(@names);
generate_queue_log(@names);
generate_queue_parsed(@names);

exit(0);

sub generate_series {
    my @names = (); 
    for ( my $year = 2015; $year <= 2022; $year++ ) {
        for ( my $month = 1; $month <= 12; $month++ ) {
            my $monthz = $month < 10 ? "0".$month : $month; 
            my $name = sprintf("%d%s",$year,$monthz);
            my $name2 = sprintf("%d-%s",$year,$monthz);
            my $month3 = $month+1 <= 12 ? $month+1 : 1;
            $month3 = $month3 < 10 ? "0".$month3 : $month3;
            my $year3  = $month+1 <= 12 ? $year : $year+1;
            my $name3 = sprintf("%d-%s",$year3,$month3);
            push @names, { 'a' => $name, 'b' => $name2, 'c' => $name3 } 
        }
    }
    return @names; 
}

sub generate_cdr { 
    my @names = @_; 

    printf("SET search_path to public;\n"); 

    foreach my $name ( @names ) {

        printf("CREATE TABLE cdr_%s ( CHECK ( calldate >= '%s-01' and calldate <'%s-01' ) ) INHERITS (cdr);\n", 
            $name->{'a'}, $name->{'b'}, $name->{'c'});
        printf("create index cdr_calldate_%s on cdr_%s(calldate);\n",$name->{'a'},$name->{'a'});
        printf("create index cdr_src_%s on cdr_%s(src);\n",$name->{'a'},$name->{'a'});
        printf("create index cdr_dst_%s on cdr_%s(dst);\n",$name->{'a'},$name->{'a'});
        printf("create index cdr_disposition_%s on cdr_%s(disposition);\n",$name->{'a'},$name->{'a'});

    }

    my $name = shift @names; 
    printf("CREATE OR REPLACE FUNCTION cdr_insert_trigger() 
        RETURNS TRIGGER AS \$\$
        BEGIN
             IF ( NEW.calldate >= DATE '%s-01' AND
                  NEW.calldate < DATE '%s-01' ) THEN
                  INSERT INTO cdr_%s VALUES (NEW.*);\n", $name->{'b'},$name->{'c'},$name->{'a'} ); 

    foreach $name ( @names ) {
        printf("ELSIF ( NEW.calldate >= DATE '%s-01' AND
                        NEW.calldate < DATE '%s-01' ) THEN
                                INSERT INTO cdr_%s VALUES (NEW.*);\n",$name->{'b'},$name->{'c'},$name->{'a'} ); 

    }

    printf("ELSE RAISE EXCEPTION 'Date out of range.  Fix the cdr_insert_trigger() function!';
            END IF;
                RETURN NULL;
                END;
                \$\$
                LANGUAGE plpgsql;\n");

    printf("CREATE TRIGGER insert_cdr_trigger before insert on cdr 
       for each row execute procedure cdr_insert_trigger();\n"); 
}

sub generate_recordings { 
    my @names = @_; 
    
    print("set search_path to integration;\n"); 
    foreach my $name ( @names ) {

        printf("CREATE TABLE recordings_%s ( CHECK ( cdr_start >= '%s-01' and cdr_start <'%s-01' ) ) INHERITS (recordings);\n", 
            $name->{'a'}, $name->{'b'}, $name->{'c'});
        printf("create index recordings_idx_id_%s on recordings_%s(id);\n",$name->{'a'},$name->{'a'}); 
        printf("create index recordings_cdr_start_%s on recordings_%s(cdr_start);\n",$name->{'a'},$name->{'a'});
        printf("create index recordings_src_%s on recordings_%s(cdr_src);\n",$name->{'a'},$name->{'a'});
        printf("create index recordings_dst_%s on recordings_%s(cdr_dst);\n",$name->{'a'},$name->{'a'});
        printf("create index recordings_uniqueid_%s on recordings_%s(cdr_uniqueid);\n",$name->{'a'},$name->{'a'});

    }

    my $name = shift @names; 
    printf("CREATE OR REPLACE FUNCTION recordings_insert_trigger() 
        RETURNS TRIGGER AS \$\$
        BEGIN
             IF ( NEW.cdr_start >= DATE '%s-01' AND
                  NEW.cdr_start < DATE '%s-01' ) THEN
                  INSERT INTO recordings_%s VALUES (NEW.*);\n", $name->{'b'},$name->{'c'},$name->{'a'} ); 

    foreach $name ( @names ) {
        printf("ELSIF ( NEW.cdr_start >= DATE '%s-01' AND
                        NEW.cdr_start < DATE '%s-01' ) THEN
                                INSERT INTO recordings_%s VALUES (NEW.*);\n",$name->{'b'},$name->{'c'},$name->{'a'} ); 

    }

    printf("ELSE RAISE EXCEPTION 'Date out of range.  Fix the recordings_insert_trigger() function!';
            END IF;
                RETURN NULL;
                END;
                \$\$
                LANGUAGE plpgsql;\n");

    printf("CREATE TRIGGER insert_recordings_trigger
           BEFORE INSERT ON recordings
              FOR EACH ROW EXECUTE PROCEDURE recordings_insert_trigger();\n");  
}


sub generate_queue_log { 
    my @names = @_; 

    printf("SET search_path to public;\n"); 

    foreach my $name ( @names ) {

        printf("CREATE TABLE queue_log_%s ( CHECK ( time >= '%s-01' and time <'%s-01' ) ) INHERITS (queue_log);\n", 
            $name->{'a'}, $name->{'b'}, $name->{'c'});
        printf("create index queue_log_time_%s on queue_log_%s(time);\n",$name->{'a'},$name->{'a'});
        printf("create index queue_log_callid_%s on queue_log_%s(callid);\n",$name->{'a'},$name->{'a'});
        printf("create index queue_log_queuename_%s on queue_log_%s(queuename);\n",$name->{'a'},$name->{'a'});
        printf("create index queue_log_agent_%s on queue_log_%s(agent);\n",$name->{'a'},$name->{'a'});

    }

    my $name = shift @names; 
    printf("CREATE OR REPLACE FUNCTION queue_log_insert_trigger() 
        RETURNS TRIGGER AS \$\$
        BEGIN
             IF ( NEW.time >= DATE '%s-01' AND
                  NEW.time < DATE '%s-01' ) THEN
                  INSERT INTO queue_log_%s VALUES (NEW.*);\n", $name->{'b'},$name->{'c'},$name->{'a'} ); 

    foreach $name ( @names ) {
        printf("ELSIF ( NEW.time >= DATE '%s-01' AND
                        NEW.time < DATE '%s-01' ) THEN
                                INSERT INTO queue_log_%s VALUES (NEW.*);\n",$name->{'b'},$name->{'c'},$name->{'a'} ); 

    }

    printf("ELSE RAISE EXCEPTION 'Date out of range.  Fix the queue_log_insert_trigger() function!';
            END IF;
                RETURN NULL;
                END;
                \$\$
                LANGUAGE plpgsql;\n");

    printf("CREATE TRIGGER insert_queue_log_trigger before insert on queue_log 
       for each row execute procedure queue_log_insert_trigger();\n"); 
}

sub generate_queue_parsed { 
    my @names = @_; 

    printf("SET search_path to public;\n"); 

    foreach my $name ( @names ) {

        printf("CREATE TABLE queue_parsed_%s ( CHECK ( time >= '%s-01' and time <'%s-01' ) ) INHERITS (queue_parsed);\n", 
            $name->{'a'}, $name->{'b'}, $name->{'c'});
        printf("create index queue_parsed_time_%s on queue_parsed_%s(time);\n",$name->{'a'},$name->{'a'});
        printf("create index queue_parsed_id_%s on queue_parsed_%s(id);\n",$name->{'a'},$name->{'a'});
        printf("create index queue_parsed_queue_%s on queue_parsed_%s(queue);\n",$name->{'a'},$name->{'a'});
        printf("create index queue_parsed_status_%s on queue_parsed_%s(status);\n",$name->{'a'},$name->{'a'});

    }

    my $name = shift @names; 
    printf("CREATE OR REPLACE FUNCTION queue_parsed_insert_trigger() 
        RETURNS TRIGGER AS \$\$
        BEGIN
             IF ( NEW.time >= DATE '%s-01' AND
                  NEW.time < DATE '%s-01' ) THEN
                  INSERT INTO queue_parsed_%s VALUES (NEW.*);\n", $name->{'b'},$name->{'c'},$name->{'a'} ); 

    foreach $name ( @names ) {
        printf("ELSIF ( NEW.time >= DATE '%s-01' AND
                        NEW.time < DATE '%s-01' ) THEN
                                INSERT INTO queue_parsed_%s VALUES (NEW.*);\n",$name->{'b'},$name->{'c'},$name->{'a'} ); 

    }

    printf("ELSE RAISE EXCEPTION 'Date out of range.  Fix the queue_parsed_insert_trigger() function!';
            END IF;
                RETURN NULL;
                END;
                \$\$
                LANGUAGE plpgsql;\n");

    printf("CREATE TRIGGER insert_queue_parsed_trigger before insert on queue_parsed
       for each row execute procedure queue_parsed_insert_trigger();\n"); 
}

