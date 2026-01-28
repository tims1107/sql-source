SELECT DISTINCT 
    owner as dependent_owner,
    name as dependent_object,
    type as dependent_type
FROM dba_dependencies 
WHERE referenced_name = 'HHS_FKC_NY_LOOKUP'
  AND referenced_owner = 'STATERPT_OWNER'
ORDER BY type, name;

select * from
(select to_timestamp(activitydate,'dd-MON-yy') ad, a.* from asr_process_run a
where source = 'NY'
and order_test_code IN ('331','332'))
order by ad ,result_test_code;

select order_number,result_test_code,result_test_name,textual_result_full,last_update_time from results_sent_log
where order_test_code = '332'
and patient_account_state = 'NY'
order by last_update_time desc,order_number ;
