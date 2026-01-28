select * from asr_process_run
where activitydate = trunc(sysdate)
and complete = 'N'
order by source,order_number;

select * from results_sent_log
where last_update_time > sysdate - .9;

select ethnic_group from gtt_results_extract
group by ethnic_group;
order by patient_race;

select textual_result_full,patient_account_state,count(1) from gtt_results_extract
where regexp_like(order_test_code,'332')
and textual_result_full = 'Positive'
group by textual_result_full,patient_account_state
order by patient_account_state;

select * from asr_process_run
where  regexp_like(source,'^(CA|NC|TX)$')
and complete = 'N'
and order_test_code = '332';

select * from asr_process_run
where complete = 'N'
order by source;

select source,order_test_code,complete,count(1) from asr_process_run
where activitydate = trunc(sysdate)
group by source,order_test_code,complete
order by source;

select patient_account_state,release_date_time,apr.order_number,apr.result_test_code,complete from gtt_results_extract gtt
join asr_process_run apr ON apr.order_number = gtt.order_number and apr.result_test_code = gtt.result_test_code
where trunc(release_date_time) = trunc(sysdate - 3)
and complete IN ('R','S');

select patient_account_state,patient_account_city,patient_account_zip,patient_account_state,release_date_time,order_number,result_test_code,textual_result_full from gtt_results_extract gtt
join patientmaster pm ON pm.eid = gtt.patient_id and gtt.lab_fk = pm.lab_fk
where trunc(release_date_time) = trunc(sysdate - 3)
and result_test_code = '525'
and patient_account_state ='NY'
and patient_account_city = 'NEW YORK'
and result_status = 'F';
