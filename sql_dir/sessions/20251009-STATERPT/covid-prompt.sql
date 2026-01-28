select * from asr_process_run
where activitydate = trunc(sysdate)
and complete = 'N'
order by source,order_number;

update asr_process_run
set complete = 'R'
where order_number IN
(select order_number from asr_process_run
where activitydate not IN (trunc(sysdate - 1))
and complete = 'N');

select * from results_sent_log
where last_update_time > sysdate - .9;

select ethnic_group from gtt_results_extract
group by ethnic_group;
order by patient_race;

update asr_process_run
set complete = 
where complete = 'N'
select order_number,result_test_code,textual_result_full,patient_account_state from gtt_results_extract
where regexp_like(order_test_code,'^(332|311|318|336)$')
and regexp_like(textual_result_full, '^(Not Detected|Negative|Non Reactive|Nonreactive|Non-reactive)$','i')
order by patient_account_state;

update asr_process_run
set complete = 'Q'
where complete = 'N'
and regexp_like(order_test_code,'^(110|111|113)$') ;


update asr_process_run
set complete = 'Q'
where complete = 'N'
and regexp_like(textual_result_full, '^(Not Detected|Negative|Non Reactive|Nonreactive|Non-reactive)$','i');


select * from asr_process_run
where activitydate = trunc(sysdate-1)
and complete = 'N'
order by source;





select result_test_code,textual_result_full from asr_process_run
where regexp_like(textual_result_full, '^(Not Detected|Negative|Nonreactive)','i')
and complete = 'N';
group by result_test_code,textual_result_full
order by result_test_code;


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
