create table ALL_20250627_results
as
select * from results_sent_log
where order_number IN
(select order_number from asr_process_run
where regexp_like(source,'^(AL|CA|LA|TX)$')
and activitydate = '27-JUN-25'
and complete = 'R');

delete results_sent_log
where order_number IN
(select order_number from ALL_20250628_results);

insert into results_sent_log
select * from ALL_20250628_results; 

select * from results_sent_log
where last_update_time > sysdate - .01;

delete results_sent_log
where last_update_time > sysdate - .01;

select * from asr_process_run
where complete = 'N';
where regexp_like(source,'^(AL|CA|LA|TX)$')
and activitydate = '28-JUN-25';

update asr_process_run
set complete = 'R'
where order_number IN
(select order_number from ALL_20250628_results);

select * from CA_20250628_results;

select * from asr_process_tracking
where process_name = 'ASR_PROCESS_AL'
order by start_time desc;

delete asr_process_tracking
where process_name = 'ASR_PROCESS_TX'
and start_time > TO_TIMESTAMP('28-JUN-25 01.08.35.419090000 AM', 'DD-MON-RR HH.MI.SS.FF9 PM');


/
declare p_out number;
begin

    sp_asr_proc_track_results_c('AL',p_out);
end;

/

SELECT 
			MAX (start_time)
		
		FROM   
			ASR_PROCESS_TRACKING
		WHERE  
			process_name = 'ASR_PROCESS_AL'
			and status = '1';

select last_update_time from gtt_results_extract;

