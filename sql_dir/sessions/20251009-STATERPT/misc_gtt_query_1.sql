select * from asr_process_run
where source = 'PA'
and activitydate = trunc(sysdate - 1);

create table asr_process_run_PA_20251002
as
select * from asr_process_run
where source = 'PA'
and activitydate = trunc(sysdate - 1);

delete results_sent_log
where (order_number,result_test_code) IN
(select order_number,result_test_code from asr_process_run_PA_20251002);

select patient_account_state,count(1) from 
(select patient_account_state,release_date_time,order_test_code from gtt_results_extract
where trunc(release_date_time) = trunc(sysdate)
and regexp_like(order_test_code,'^(110|111|113|301|303|304|308|310|311|312|315|317L|318|319N|322|323|327|332|336)$'))
group by patient_account_state
order by patient_account_state;

select facility_state,patient_account_state,TO_CHAR(release_date_time, 'YYYY-MM-DD HH24:MI:SS') ,order_test_code,textual_result_full,result_status from gtt_results_extract
where trunc(release_date_time) = trunc(sysdate)
and regexp_like(order_test_code,'^(110|111|113|301|303|304|308|310|311|312|315|317L|318|319N|322|323|327|332|336)$')
and result_status like 'F'
order by release_date_time desc;
and patient_account_state is null;

update asr_process_run
set complete = 'R'
where (order_number,result_test_code) IN
(select order_number,result_test_code from asr_process_run_PA_20251002);