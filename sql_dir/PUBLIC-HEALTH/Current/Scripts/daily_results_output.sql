select * from daily_results;
select date_of_birth,eid,requisition_id,patient_last_name,patient_first_name,patient_account_state,patient_race,ethnic_group from pat_results p
join daily_results d ON d.order_number = p.requisition_id and p.eid = d.patient_id
where patient_account_state = 'GA'
order by requisition_id,patient_last_name;
where requisition_id = '4620FF8';

select result_test_code,order_number,textual_result_full from results_sent_log
where patient_account_state = 'CA'
and last_update_time > sysdate -.5;

delete asr_process_tracking
where start_time > '02-JUL-25 12.35.53.910752000 AM'
and process_name = 'ASR_PROCESS_CA';

delete results_sent_log
where order_number IN ('2499V64'
,'4770AX8'
,'2428CZ4');

select * from asr_process_run
where source = 'CA'
and activitydate = '02-JUL-25';

update asr_process_run
set complete = 'N'
where order_number IN ('062499V64';

select * from condition_master
where state_fk
IN 
(select state_master_pk from state_master where state_abbreviation = 'TX')
and order_test_code = '318';

select filter from condition_filters
where condition_filter_pk = 5;

/
declare p_out number;

begin
  
  SP_ASR_PROC_TRACK_RESULTS_C('CA',p_out);
  
  for rec IN (select

end;

/

select * from GTT_RESULTS_EXTRACT
where patient_account_state = 'CA'
and value_type = 'ST' and regexp_like(textual_result_full,'Reactive') 
and regexp_like(
;



SELECT 
			--MAX (ASR_PROCESS_TRACKING.start_time)
		*
		FROM   
			STATERPT_OWNER.ASR_PROCESS_TRACKING
		WHERE  
			ASR_PROCESS_TRACKING.process_name = 'ASR_PROCESS_CA'
            order by start_time desc;
			and ASR_PROCESS_TRACKING.status = '1';