declare p_count number;

begin

    SP_ASR_PROC_TRACK_RESULTS_CC('IL',p_count);
end;

/
select * from il_results_20250607
where requisition_id = '3687ZM8';

select * from il_results_20250609
where order_test_code IN
(select order_test_code from condition_master_test
where state_fk IN
(select state_master_pk from state_master
where state_abbreviation = 'IL')
and status = 'active'
and regexp_like(order_test_code,'^301'))
--and (textual_result_full = 'Reactive'
--or textual_result_full = '>11.00')
order by order_test_code,requisition_id;

select max(last_updated_date) from il_results_20250607
where order_test_code IN
(select order_test_code from condition_master_test
where state_fk IN
(select state_master_pk from state_master
where state_abbreviation = 'IL')
and status = 'active'
and not regexp_like(order_test_code,'^7'))
--and (textual_result_full = 'Reactive'
--or textual_result_full = '>11.00')
order by order_test_code,requisition_id;

select * from il_output_results
where order_test_code IN
(select order_test_code from condition_master_test
where state_fk IN
(select state_master_pk from state_master
where state_abbreviation = 'IL')
and status = 'active'
and regexp_like(order_test_code,'^301'))
and textual_result_full = 'Positive'
order by order_test_code,requisition_id;

select to_char(last_updated_date,'dd-MON-rr') from il_output_results
where last_updated_date = '06-JUN-25 12.00.09.400512000 AM';

select * from ih_dw.dw_ods_activity
where requisition_id = '3132Y38';

select * from asr_process_run
where activitydate = '05-JUN-25'
and source = 'IL';

select * from results_sent_log
where order_number = '3132Y68';

select * from condition_master_test
where state_fk IN
(select state_master_pk from state_master
where state_abbreviation = 'IL')
and order_test_code = '301';

update condition_master
set condition_filter_fk = 4,condition = 'All'
where condition_master_pk = 194;



select * from asr_process_run p
join
(SELECT r.requisition_id,
    r.result_test_code,
    TO_CHAR(TRUNC(r.last_updated_date), 'DD-MON-RR') AS formatted_date_standard
FROM
    il_output_results r) t ON t.requisition_id = p.order_number and t.result_test_code = p.result_test_code; -- Replace 'your_table' with your actual table name


select * from il_output_results
where requisition_id = '3132Y38'
and order_test_code IN ('111','110','113','310');

select * from il_output_results
where order_test_code IN
(select order_test_code from state_master
where state_abbreviation = 'IL')
and order_test_code = '301';

select * from asr_process_run
where source = 'NC'
and activitydate = '04-JUN-25';

delete results_sent_log
where order_number = '3391WH8';

select * from asr_process_tracking
where process_name = 'ASR_PROCESS_IL'
order by start_time desc;

delete asr_process_tracking
where process_name='ASR_PROCESS_IL'
and start_time < '04-JUN-25 03.16.33.719092000 AM';

update asr_process_tracking
set start_time = '02-JUN-25 11.59.33.719092000 PM'
where start_time = '04-JUN-25 03.16.33.719092000 AM'
and process_name = 'ASR_PROCESS_IL';

select order_number,result_status,last_update_time,order_test_code,textual_result_full from gtt_results_extract
where regexp_like(order_test_code,'^(311)')
order by order_number,order_test_code;

select patient_last_name from gtt_results_extract
where order_number IN ('3391WH8','3039TG8')
and order_test_code IN ('311');


select lo.initiate_id,pm.* from ih_dw.results r
join ih_dw.dim_lab_order lo ON lo.requisition_id = r.requisition_id
join patientmaster pm ON pm.eid = lo.initiate_id and r.lab_fk = pm.lab_fk
where r.requisition_id IN 
(select requisition_id from ih_dw.dw_ods_activity
where last_updated_date > '02-JUN-25 11.59.33.719092000 PM')
and rownum < 10
and pm.state = 'IL';

SELECT 
			MAX (ASR_PROCESS_TRACKING.start_time)
		
		FROM   
			STATERPT_OWNER.ASR_PROCESS_TRACKING
		WHERE  
			ASR_PROCESS_TRACKING.process_name = 'ASR_PROCESS_IL'
			and ASR_PROCESS_TRACKING.status = '1';