
select * from asr_process_run 
where order_number IN
(select order_number from results_sent_log
where patient_account_state = 'CA'
and last_update_time > sysdate - .2);

select * from results_sent_log
--delete results_sent_log
where last_update_time > TO_TIMESTAMP('22-JUN-25 12.05.42.737248000 AM', 'DD-MON-RR HH.MI.SS.FF9 PM')
and patient_account_state = 'CA';



delete results_sent_log
where order_number = '2442NN4';
where order_number IN 
('24354Z4','24354Z4','3809T58','3809T58','3809UG8','3809UG8','3995ZS8','4162VJ8','4162VJ8','40096G8','40096G8');

update asr_process_run
set complete = 'R'
where order_number IN 
('24354Z4','24354Z4','3809T58','3809T58','3809UG8','3809UG8','3995ZS8','4162VJ8','4162VJ8','40096G8','40096G8');

/
declare v_start_time timestamp;
v_last_updated TIMESTAMP;

begin
for rec IN (select process_name from asr_process_tracking
where regexp_like(process_name,'^(ASR_PROCESS_)(CA)$')
group by process_name
order by process_name)
loop
    select max(start_time),max(last_updated) into v_start_time,v_last_updated from asr_process_tracking 
    where process_name = rec.process_name
    and status = 1;
    dbms_output.put_line(rec.process_name || ' ' || v_start_time || ' - ' || v_last_updated);
    for inloop IN (select * from asr_process_tracking 
        where process_name = rec.process_name
        and start_time > v_start_time - interval '9' DAY
        and status = 1
        order by start_time desc)
        loop
            dbms_output.put_line(rec.process_name || ' ' || inloop.start_time || ' ' || inloop.last_updated);
        end loop;
    
    
end loop;
end;
